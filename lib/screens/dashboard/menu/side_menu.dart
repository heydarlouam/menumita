import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/constants.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utility/extensions.dart';

// class SideMenu extends StatelessWidget {
//   const SideMenu({Key? key, this.controller}) : super(key: key);
//
//   final ScrollController? controller; // 👈 اضافه شد
//
//   // void _go(BuildContext context, String name) {
//   //   context.mainScreenProvider.navigateToScreen(name);
//   //   if (Scaffold.maybeOf(context)?.isDrawerOpen == true) {
//   //     Navigator.of(context).pop();
//   //   }
//   // }
//   // داخل کلاس SideMenu
//   void _go(BuildContext context, String name) async {
//     if (await UserSaveHelper.isExpired()) {
//       DialogHelper.showExpiredDialog(context);
//       return;
//     }
//
//     context.mainScreenProvider.navigateToScreen(name);
//
//     // بستن دراور اگر باز است
//     if (Scaffold.maybeOf(context)?.isDrawerOpen == true) {
//       Navigator.of(context).pop();
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       controller: controller,     // 👈 وصل به ListView
//       primary: false,             // 👈 مهم: از PrimaryScrollController استفاده نکن
//       padding: EdgeInsets.zero, // ⬅️ مهم برای چسبیدن هدر به کارت
//       children: [
//         DrawerHeader(
//           child: Center(
//             child: SizedBox(
//               width: 100, height: 100,
//               child: Image.asset("assets/images/logo.png", color: Colors.white54),
//             ),
//           ),
//         ),
//         DrawerListTile(title: "داشبورد",  svgSrc: "assets/icons/menu_dashboard.svg", press: () => _go(context, 'داشبورد')),
//         DrawerListTile(title: "سفارش در جریان",  svgSrc: "assets/icons/order_in_progress.svg", press: () => _go(context, 'سفارش در جریان')),
//         DrawerListTile(title: "دسته‌بندی", svgSrc: "assets/icons/menu_tran.svg",       press: () => _go(context, 'دسته‌بندی')),
//         DrawerListTile(title: "زیر‌دسته", svgSrc: "assets/icons/menu_task.svg",       press: () => _go(context, 'زیر‌دسته')),
//         DrawerListTile(title: "برندها",   svgSrc: "assets/icons/menu_doc.svg",        press: () => _go(context, 'برندها')),
//         DrawerListTile(title: "نوع ویژگی",svgSrc: "assets/icons/menu_store.svg",      press: () => _go(context, 'نوع ویژگی')),
//         DrawerListTile(title: "ویژگی‌ها",  svgSrc: "assets/icons/menu_notification.svg",press: () => _go(context, 'ویژگی‌ها')),
//         DrawerListTile(title: "سفارشات",  svgSrc: "assets/icons/menu_profile.svg",    press: () => _go(context, 'سفارشات')),
//         DrawerListTile(title: "کد تخفیف", svgSrc: "assets/icons/menu_setting.svg",    press: () => _go(context, 'کد تخفیف')),
//         DrawerListTile(title: "پوسترها",  svgSrc: "assets/icons/menu_doc.svg",        press: () => _go(context, 'پوسترها')),
//       ],
//     );
//   }
// }
//
// class DrawerListTile extends StatelessWidget {
//   const DrawerListTile({Key? key, required this.title, required this.svgSrc, required this.press}) : super(key: key);
//   final String title, svgSrc;
//   final VoidCallback press;
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: press,
//
//       horizontalTitleGap: 8.0,
//       leading: SvgPicture.asset(
//         svgSrc,
//         // colorFilter: const ColorFilter.mode(Colors.white54, BlendMode.srcIn),
//         colorFilter: const ColorFilter.mode(Colors.white54, BlendMode.srcIn),
//
//         height: 20,
//       ),
//       title: Text(title, style: const TextStyle(color: Colors.white54, fontSize: 16.0,fontFamily: FONTS_STYLE_FAMILY)),
//     );
//   }
// }


import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/constants.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utility/extensions.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key, this.controller}) : super(key: key);

  final ScrollController? controller;

  void _go(BuildContext context, String name) async {
    if (await UserSaveHelper.isExpired()) {
      DialogHelper.showExpiredDialog(context);
      return;
    }
    context.mainScreenProvider.navigateToScreen(name);
    if (Scaffold.maybeOf(context)?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: UserSaveHelper.getUserInfo(showError: false),
      builder: (context, snap) {
        final menuType = (snap.data?['menu_type'] ?? '').toString().trim().toLowerCase();
        final hideOrdersAndCoupons = menuType == 'menu_one';

        // در حال لود: می‌تونیم موقتاً همه رو نشان بدهیم یا شِل ساده
        if (snap.connectionState == ConnectionState.waiting) {
          return ListView(
            controller: controller,
            primary: false,
            padding: EdgeInsets.zero,
            children: const [
              DrawerHeader(child: Center(child: SizedBox(width: 100, height: 100))),
              _DrawerSkeleton(),
              _DrawerSkeleton(),
              _DrawerSkeleton(),
            ],
          );
        }

        return ListView(
          controller: controller,
          primary: false,
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset("assets/images/logo.png", color: Colors.white54),
                ),
              ),
            ),
            DrawerListTile(
              title: "داشبورد",
              svgSrc: "assets/icons/menu_dashboard.svg",
              press: () => _go(context, 'داشبورد'),
            ),

            // ↓↓↓ این‌ها فقط وقتی menu_type != menu_one هستند نمایش داده می‌شوند
            if (!hideOrdersAndCoupons)
              DrawerListTile(
                title: "سفارش در جریان",
                svgSrc: "assets/icons/order_in_progress.svg",
                press: () => _go(context, 'سفارش در جریان'),
              ),

            DrawerListTile(
              title: "دسته‌بندی",
              svgSrc: "assets/icons/menu_tran.svg",
              press: () => _go(context, 'دسته‌بندی'),
            ),
            DrawerListTile(
              title: "زیر‌دسته",
              svgSrc: "assets/icons/menu_task.svg",
              press: () => _go(context, 'زیر‌دسته'),
            ),
            DrawerListTile(
              title: "برندها",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () => _go(context, 'برندها'),
            ),
            DrawerListTile(
              title: "نوع ویژگی",
              svgSrc: "assets/icons/menu_store.svg",
              press: () => _go(context, 'نوع ویژگی'),
            ),
            DrawerListTile(
              title: "ویژگی‌ها",
              svgSrc: "assets/icons/menu_notification.svg",
              press: () => _go(context, 'ویژگی‌ها'),
            ),

            if (!hideOrdersAndCoupons)
              DrawerListTile(
                title: "سفارشات",
                svgSrc: "assets/icons/menu_profile.svg",
                press: () => _go(context, 'سفارشات'),
              ),

            if (!hideOrdersAndCoupons)
              DrawerListTile(
                title: "کد تخفیف",
                svgSrc: "assets/icons/menu_setting.svg",
                press: () => _go(context, 'کد تخفیف'),
              ),

            DrawerListTile(
              title: "پوسترها",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () => _go(context, 'پوسترها'),
            ),
          ],
        );
      },
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 8.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: const ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 20,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 16.0,
          fontFamily: FONTS_STYLE_FAMILY,
        ),
      ),
    );
  }
}

/// شِل ساده برای حالت لود
class _DrawerSkeleton extends StatelessWidget {
  const _DrawerSkeleton();

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: SizedBox(width: 20, height: 20, child: DecoratedBox(decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle))),
      title: SizedBox(height: 16, child: DecoratedBox(decoration: BoxDecoration(color: Colors.white24))),
    );
  }
}
