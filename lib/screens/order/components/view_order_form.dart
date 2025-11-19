
import 'package:admin/utility/functions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../models/order.dart';
import '../../../utility/constants.dart';
import '../../../utility/extensions.dart';
import '../../../widgets/custom_dropdown.dart';

import '../provider/order_provider.dart';
import '../../../widgets/submission_spinner.dart';

class OrderSubmitForm extends StatefulWidget {
  final Order? order;
  const OrderSubmitForm({Key? key, this.order}) : super(key: key);

  @override
  State<OrderSubmitForm> createState() => _OrderSubmitFormState();
}

class _OrderSubmitFormState extends State<OrderSubmitForm> {
  @override
  void initState() {
    super.initState();
    // مقداردهی اولیه فقط یک بار
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.order != null) {
        context.orderProvider.loadOrderForUpdate(widget.order!);
      } else {
        context.orderProvider.resetForm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.orderProvider;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Form(
          key: provider.orderFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: formRow('نام:', Text(widget.order?.userName ?? 'N/A', style: const TextStyle(fontSize: 16)))),
                  Expanded(child: formRow('شناسه سفارش:', Text(widget.order?.sId ?? 'N/A', style: const TextStyle(fontSize: 12)))),
                ],
              ),
              itemsSection(widget.order,context),
              addressSection(widget.order),
              const Gap(10),
              paymentDetailsSection(widget.order),
              formRow(
                'وضعیت سفارش:',
                Consumer<OrderProvider>(
                  builder: (_, op, __) => CustomDropdown(
                    hintText: 'وضعیت',
                    initialValue: op.selectedOrderStatus,
                    items: const [
                      ORDER_STATUS_PENDING,
                      ORDER_STATUS_PROCESSING,
                      ORDER_STATUS_SHIPPED,
                      ORDER_STATUS_DELIVERED,
                      ORDER_STATUS_CANCELLED,
                      ORDER_STATUS_PAID
                    ],
                    // فقط متن نمایش را فارسی می‌کنیم؛ مقدار داخلی تغییری نمی‌کند
                    displayItem: (val) {
                      if (val == ORDER_STATUS_PENDING) return 'در انتظار تأیید';
                      if (val == ORDER_STATUS_PROCESSING) return 'در حال آماده‌سازی';
                      if (val == ORDER_STATUS_SHIPPED) return 'ارسال شده';
                      if (val == ORDER_STATUS_DELIVERED) return 'تحویل داده شده';
                      if (val == ORDER_STATUS_CANCELLED) return 'لغو شده';
                      if (val == ORDER_STATUS_PAID) return 'پرداخت شده';
                      return val;
                    },
                    onChanged: (newValue) {
                      op.selectedOrderStatus = newValue ?? ORDER_STATUS_PENDING;
                      op.updateUI();
                    },
                    validator: (value) => value == null ? 'لطفاً وضعیت را انتخاب کنید' : null,
                  ),
                ),
              ),
              // formRow(
              //   'لینک پیگیری:',
              //   CustomTextField(
              //     labelText: 'لینک پیگیری',
              //     onSave: (_) {},
              //     controller: provider.trackingUrlCtrl,
              //   ),
              // ),
              const Gap(defaultPadding * 2),
              Consumer<OrderProvider>(
                builder: (_, op, __) => actionButtons(context, op),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget formRow(String label, Widget dataWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          Expanded(flex: 2, child: dataWidget),
        ],
      ),
    );
  }

  Widget addressSection(Order? order) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('آدرس ارسال', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ),
          formRow('تلفن :', Text(order?.shippingAddress?.phone ?? 'N/A', style: const TextStyle(fontSize: 16))),
          formRow('نام مشتری :', Text(order?.shippingAddress?.street ?? 'N/A', style: const TextStyle(fontSize: 16))),
          if(order?.shippingAddress?.tableNumber==null)
            formRow('آدرس دریافت :', Text(order?.shippingAddress?.state ?? 'N/A', style: const TextStyle(fontSize: 16))),
          if(order?.shippingAddress?.state==null)
            formRow('شماره میز :', Text(order?.shippingAddress?.tableNumber ?? 'N/A', style: const TextStyle(fontSize: 16))),

        ],
      ),
    );
  }


  Widget paymentDetailsSection(Order? order) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        border: Border.all(color: Colors.blueAccent),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1)),
        ],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('جزئیات پرداخت', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
          ),

          formRow('کد کوپن:', Text(order?.couponName ?? 'N/A', style: const TextStyle(fontSize: 16))),
          // 🔽 این سه خط را تغییر دهید
          formRow('جمع جزء سفارش:', Text(money(context, order?.orderTotal?.subTotal), style: const TextStyle(fontSize: 16))),
          formRow('تخفیف:', Text(money(context, order?.orderTotal?.discount), style: const TextStyle(fontSize: 16, color: Colors.red))),
          formRow('جمع کل:', Text(money(context, order?.orderTotal?.total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget itemsSection(Order? order, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        border: Border.all(color: Colors.blueAccent),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1)),
        ],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('آیتم‌ها', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
          ),
          _buildItemsList(order, context),
          const SizedBox(height: defaultPadding),
          // 🔽 این خط را تغییر دهید
          formRow('قیمت کل:', Text(money(context, order?.totalPrice), style: const TextStyle(fontSize: 16, color: Colors.green))),
        ],
      ),
    );
  }

  Widget _buildItemsList(Order? order, BuildContext ctx) {
    if (order?.items == null || order!.items!.isEmpty) {
      return const Text('آیتمی موجود نیست', style: TextStyle(fontSize: 16));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.items!.length,
      itemBuilder: (_, i) {
        final item = order.items![i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('${item.productName} : ${item.quantity} x ${   money(ctx, item.price)   }',
                style: const TextStyle(fontSize: 16))
              ,
              Row(children: [
                Text('توضیح سفارش: '),
                Text(' ${item.note} ')
              ],)],),
        );
      },
    );
  }

  Widget actionButtons(BuildContext context, OrderProvider op) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          onPressed: () {
            op.resetForm();
            Navigator.of(context).pop();
          },
          child: const Text('انصراف', style: TextStyle(color: Colors.white)),
        ),
        const Gap(defaultPadding),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () async {
            if (op.isSubmitting) return;
            final form = op.orderFormKey.currentState;
            if (form == null) return;
            if (!form.validate()) return;
            final ok = await op.updateOrder();
            if (!mounted) return;
            if (ok) Navigator.of(context).pop();
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
            child: op.isSubmitting
                ? const SubmissionSpinner(
                    key: ValueKey('order_loading'),
                    strokeWidth: 2,
                  )
                : const Text(
                    'بروزرسانی سفارش',

                    key: ValueKey('order_submit_text'),
                style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }
}

// Popup helper (بدون تغییر ظاهر)
void showOrderForm(BuildContext context, Order? order) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: bgColor,
        title: Center(
          child: Text('جزئیات سفارش'.toUpperCase(), style: const TextStyle(color:  Colors.white  )),
        ),
        content: OrderSubmitForm(order: order),
      );
    },
  );
}
