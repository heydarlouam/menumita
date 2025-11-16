import 'package:admin/screens/profile_card.dart';
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utility/constants.dart';
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
  bool _ordersEnabled = true; // 👈 بر اساس menu_type تعیین می‌شود
  late final ScrollController _ordersScrollCtrl;

  @override
  void initState() {
    super.initState();

    _ordersScrollCtrl = ScrollController();
    _ordersScrollCtrl.addListener(() {
      if (!_ordersScrollCtrl.hasClients) return;

      // اگر سفارش‌ها غیرفعال باشد، پیجینگ را هم غیرفعال کن
      if (!_ordersEnabled) return;

      final provider = context.dataProvider;
      final position = _ordersScrollCtrl.position;
      final nearBottom = position.pixels >= position.maxScrollExtent - 80;

      if (nearBottom && provider.hasMoreOrders && !provider.isOrdersLoading) {
        provider.loadMoreOrders(); // ← پیج بعدی ۵۰تایی و append
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted && !_bootstrapped) {
        await _resolveOrdersEnabled(); // 👈 اول تعیین می‌کنیم فعال است یا نه
        if (_ordersEnabled) {
          await context.dataProvider.loadInitialOrders();
        }
        _bootstrapped = true;
      }
    });
  }

  /// تعیین فعال/غیرفعال بودن ماژول سفارش‌ها با توجه به menu_type
  Future<void> _resolveOrdersEnabled() async {
    try {
      final info = await UserSaveHelper.getUserInfo(showError: false);
      final menuType =
          (info?['menu_type'] ?? '').toString().trim().toLowerCase();
      final enabled = menuType != 'menu_one';

      if (mounted) {
        setState(() => _ordersEnabled = enabled);
      }

      if (!enabled) {
        // پیام دوستانه برای شفافیت UX
        SnackBarHelper.showErrorSnackBar(
            'ماژول سفارش‌ها برای این نوع منو غیرفعال است');
      }
    } catch (_) {
      // اگر خطا در خواندن تنظیمات رخ دهد، محافظه‌کارانه فعال بماند
      if (mounted) setState(() => _ordersEnabled = true);
    }
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

            // اگر سفارش‌ها غیرفعال باشد، بجای لیست، Placeholder نشان بده
            if (!_ordersEnabled)
              _OrdersDisabledCard(onOpenSettings: () async {
                // اگر جایی در اپ تنظیمات منو دارید، ناوبری بده؛ در غیر اینصورت همین بماند.
                // Navigator.pushNamed(context, '/settings');
              }),

            if (_ordersEnabled)
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
                              onPressed: !_ordersEnabled
                                  ? null // وقتی غیرفعاله، دکمه هم غیرفعال
                                  : () async {
                                      if (await UserSaveHelper.isExpired()) {
                                        DialogHelper.showExpiredDialog(context);
                                        return;
                                      }
                                      await context.dataProvider
                                          .loadInitialOrders(showSnack: true);
                                    },
                              icon: const Icon(Icons.refresh),
                            ),
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
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// ویجت نمایش وقتی سفارش‌ها غیرفعال است
class _OrdersDisabledCard extends StatelessWidget {
  final VoidCallback? onOpenSettings;

  const _OrdersDisabledCard({this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'نمایش و دریافت سفارش‌ها برای این نوع منو (menu_one) غیرفعال است.',
                textDirection: TextDirection.rtl,
              ),
            ),
            if (onOpenSettings != null)
              TextButton(
                onPressed: onOpenSettings,
                child: const Text('تنظیمات'),
              ),
          ],
        ),
      ),
    );
  }
}

