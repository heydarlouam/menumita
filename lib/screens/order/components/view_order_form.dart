
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../models/order.dart';
import '../../../utility/constants.dart';
import '../../../utility/extensions.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_text_field.dart';
import '../provider/order_provider.dart';

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
                  Expanded(child: formRow('Name:', Text(widget.order?.userName ?? 'N/A', style: const TextStyle(fontSize: 16)))),
                  Expanded(child: formRow('Order Id:', Text(widget.order?.sId ?? 'N/A', style: const TextStyle(fontSize: 12)))),
                ],
              ),
              itemsSection(widget.order),
              addressSection(widget.order),
              const Gap(10),
              paymentDetailsSection(widget.order),
              formRow(
                'Order Status:',
                Consumer<OrderProvider>(
                  builder: (_, op, __) => CustomDropdown(
                    hintText: 'Status',
                    initialValue: op.selectedOrderStatus,
                    items: const [
                      ORDER_STATUS_PENDING,
                      ORDER_STATUS_PROCESSING,
                      ORDER_STATUS_SHIPPED,
                      ORDER_STATUS_DELIVERED,
                      ORDER_STATUS_CANCELLED
                    ],
                    displayItem: (val) => val,
                    onChanged: (newValue) {
                      op.selectedOrderStatus = newValue ?? ORDER_STATUS_PENDING;
                      op.updateUI();
                    },
                    validator: (value) => value == null ? 'Please select status' : null,
                  ),
                ),
              ),
              formRow(
                'Tracking URL:',
                CustomTextField(
                  labelText: 'Tracking Url',
                  onSave: (_) {},
                  controller: provider.trackingUrlCtrl,
                ),
              ),
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
            child: Text('Shipping Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ),
          formRow('Phone:', Text(order?.shippingAddress?.phone ?? 'N/A', style: const TextStyle(fontSize: 16))),
          formRow('Street:', Text(order?.shippingAddress?.street ?? 'N/A', style: const TextStyle(fontSize: 16))),
          formRow('City:', Text(order?.shippingAddress?.city ?? 'N/A', style: const TextStyle(fontSize: 16))),
          formRow('Postal Code:', Text(order?.shippingAddress?.postalCode ?? 'N/A', style: const TextStyle(fontSize: 16))),
          formRow('Country:', Text(order?.shippingAddress?.country ?? 'N/A', style: const TextStyle(fontSize: 16))),
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
            child: Text('Payment Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
          ),
          formRow('Payment Method:', Text(order?.paymentMethod ?? 'N/A', style: const TextStyle(fontSize: 16))),
          formRow('Coupon Code:', Text(order?.couponName ?? 'N/A', style: const TextStyle(fontSize: 16))),
          formRow('Order Sub Total:', Text('\$${order?.orderTotal?.subTotal?.toStringAsFixed(2) ?? 'N/A'}', style: const TextStyle(fontSize: 16))),
          formRow('Discount:', Text('\$${order?.orderTotal?.discount?.toStringAsFixed(2) ?? 'N/A'}', style: const TextStyle(fontSize: 16, color: Colors.red))),
          formRow('Grand Total:', Text('\$${order?.orderTotal?.total?.toStringAsFixed(2) ?? 'N/A'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget itemsSection(Order? order) {
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
            child: Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
          ),
          _buildItemsList(order),
          const SizedBox(height: defaultPadding),
          formRow('Total Price:', Text('\$${order?.totalPrice?.toStringAsFixed(2) ?? 'N/A'}', style: const TextStyle(fontSize: 16, color: Colors.green))),
        ],
      ),
    );
  }

  Widget _buildItemsList(Order? order) {
    if (order?.items == null || order!.items!.isEmpty) {
      return const Text('No items', style: TextStyle(fontSize: 16));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.items!.length,
      itemBuilder: (_, i) {
        final item = order.items![i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text('${item.productName}: ${item.quantity} x \$${item.price?.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16)),
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
          child: const Text('Cancel'),
        ),
        const Gap(defaultPadding),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: op.isSubmitting
              ? null
              : () async {
            final form = op.orderFormKey.currentState;
            if (form == null) return;
            if (!form.validate()) return;
            final ok = await op.updateOrder();
            if (!mounted) return;
            if (ok) Navigator.of(context).pop();
          },
          child: op.isSubmitting
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Update Order'),
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
          child: Text('Order Details'.toUpperCase(), style: const TextStyle(color: primaryColor)),
        ),
        content: OrderSubmitForm(order: order),
      );
    },
  );
}
