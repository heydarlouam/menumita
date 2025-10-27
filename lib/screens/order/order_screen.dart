

import 'package:admin/screens/profile_card.dart';
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utility/constants.dart';
import '../../widgets/custom_dropdown.dart';
import 'components/order_header.dart';
import 'components/order_list_section.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with AutomaticKeepAliveClientMixin {
  bool _bootstrapped = false;
  late final ScrollController _ordersScrollCtrl;

  @override
  void initState() {
    super.initState();

    _ordersScrollCtrl = ScrollController();
    _ordersScrollCtrl.addListener(() {
      final provider = context.dataProvider;
      if (!_ordersScrollCtrl.hasClients) return;

      final position = _ordersScrollCtrl.position;
      final nearBottom = position.pixels >= position.maxScrollExtent - 80;

      if (nearBottom && provider.hasMoreOrders && !provider.isOrdersLoading) {
        provider.loadMoreOrders(); // ← پیج بعدی ۵۰تایی و append
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_bootstrapped) {
        context.dataProvider.loadInitialOrders();
        _bootstrapped = true;
      }
    });
  }

  @override
  void dispose() {
    _ordersScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: SingleChildScrollView(
        controller: _ordersScrollCtrl,
        primary: false,
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const OrderHeader(),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: 'بروزرسانی و بازنشانی فیلترها',

                            onPressed: () async {
                              if (await UserSaveHelper.isExpired()) {
                                DialogHelper.showExpiredDialog(context);
                                return;
                              }
                              await context.dataProvider
                                  .loadInitialOrders(showSnack: true);
                              context.dataProvider
                                  .filterOrders(ORDER_STATUS_ALL);
                            },

                            icon: const Icon(Icons.refresh),
                          ),
                          // const Gap(20),
                          SizedBox(
                            width: 280,
                            child: CustomDropdown(
                              hintText: 'فیلتر سفارش بر اساس وضعیت',
                              initialValue: ORDER_STATUS_ALL,
                              items: const [
                                ORDER_STATUS_ALL,
                                ORDER_STATUS_PENDING,
                                ORDER_STATUS_PROCESSING,
                                ORDER_STATUS_SHIPPED,
                                ORDER_STATUS_DELIVERED,
                                ORDER_STATUS_CANCELLED
                              ],
                              displayItem: _statusLabel,
                              onChanged: (v) async {
                                if (await UserSaveHelper.isExpired()) {
                                  DialogHelper.showExpiredDialog(context);
                                  return;
                                }
                                if (v != null) {
                                  context.dataProvider.filterOrders(v);
                                }
                              },

                              validator: (_) => null,
                            ),
                          ),
                          // const Gap(40),

                          const SizedBox(width: 12),
                          const Expanded(child: ProfileCard()),
                        ],
                      ),
                      const Gap(defaultPadding),
                      const OrderListSection(),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case ORDER_STATUS_ALL:
        return 'همه سفارش‌ها';
      case ORDER_STATUS_PENDING:
        return 'در انتظار بررسی';
      case ORDER_STATUS_PROCESSING:
        return 'در حال پردازش';
      case ORDER_STATUS_SHIPPED:
        return 'ارسال شده';
      case ORDER_STATUS_DELIVERED:
        return 'تحویل داده شده';
      case ORDER_STATUS_CANCELLED:
        return 'لغو شده';
      default:
        return status;
    }
  }

  @override
  bool get wantKeepAlive => true;
}
