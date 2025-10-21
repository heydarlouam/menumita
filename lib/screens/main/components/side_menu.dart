// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// import '../../../utility/extensions.dart';
//
// class SideMenu extends StatelessWidget {
//   const SideMenu({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         children: [
//           DrawerHeader(
//             child: Center(child: SizedBox(width: 100,height: 100,child: Image.asset("assets/images/logo.png", color: Colors.white54,),))
//           ),
//           DrawerListTile(
//             title: "Dashboard",
//             svgSrc: "assets/icons/menu_dashboard.svg",
//             press: () {
//               context.mainScreenProvider.navigateToScreen('Dashboard');
//             },
//           ),
//           DrawerListTile(
//             title: "Category",
//             svgSrc: "assets/icons/menu_tran.svg",
//             press: () {
//               context.mainScreenProvider.navigateToScreen('Category');
//             },
//           ),
//           DrawerListTile(
//             title: "Sub Category",
//             svgSrc: "assets/icons/menu_task.svg",
//             press: () {
//               context.mainScreenProvider.navigateToScreen('SubCategory');
//             },
//           ),
//           DrawerListTile(
//             title: "Brands",
//             svgSrc: "assets/icons/menu_doc.svg",
//             press: () {
//               context.mainScreenProvider.navigateToScreen('Brands');
//             },
//           ),
//           DrawerListTile(
//             title: "Variant Type",
//             svgSrc: "assets/icons/menu_store.svg",
//             press: () {
//               context.mainScreenProvider.navigateToScreen('VariantType');
//             },
//           ),
//           DrawerListTile(
//             title: "Variants",
//             svgSrc: "assets/icons/menu_notification.svg",
//             press: () {
//               context.mainScreenProvider.navigateToScreen('Variants');
//             },
//           ),
//           DrawerListTile(
//             title: "Orders",
//             svgSrc: "assets/icons/menu_profile.svg",
//             press: () {
//               context.mainScreenProvider.navigateToScreen('Order');
//             },
//           ),
//           DrawerListTile(
//             title: "Coupons",
//             svgSrc: "assets/icons/menu_setting.svg",
//             press: () {
//               context.mainScreenProvider.navigateToScreen('Coupon');
//             },
//           ),
//           DrawerListTile(
//             title: "Posters",
//             svgSrc: "assets/icons/menu_doc.svg",
//             press: () {
//               context.mainScreenProvider.navigateToScreen('Poster');
//             },
//           ),
//           // DrawerListTile(
//           //   title: "Notifications",
//           //   svgSrc: "assets/icons/menu_notification.svg",
//           //   press: () {
//           //     context.mainScreenProvider.navigateToScreen('Notifications');
//           //   },
//           // ),
//         ],
//       ),
//     );
//   }
// }
//
// class DrawerListTile extends StatelessWidget {
//   const DrawerListTile({
//     Key? key,
//     // For selecting those three line once press "Command+D"
//     required this.title,
//     required this.svgSrc,
//     required this.press,
//   }) : super(key: key);
//
//   final String title, svgSrc;
//   final VoidCallback press;
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: press,
//       horizontalTitleGap: 8.0,
//       leading: SvgPicture.asset(
//         svgSrc,
//         colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
//         height: 16,
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//           color: Colors.white54,
//           fontSize: 15.0,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../utility/extensions.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.asset(
                  "assets/images/logo.png",
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          DrawerListTile(
            title: "داشبورد",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              context.mainScreenProvider.navigateToScreen('داشبورد');
            },
          ),
          DrawerListTile(
            title: "دسته‌بندی",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              context.mainScreenProvider.navigateToScreen('دسته‌بندی');
            },
          ),
          DrawerListTile(
            title: "زیر‌دسته",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {
              context.mainScreenProvider.navigateToScreen('زیر‌دسته');
            },
          ),
          DrawerListTile(
            title: "برندها",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.mainScreenProvider.navigateToScreen('برندها');
            },
          ),
          DrawerListTile(
            title: "نوع ویژگی",
            svgSrc: "assets/icons/menu_store.svg",
            press: () {
              context.mainScreenProvider.navigateToScreen('نوع ویژگی');
            },
          ),
          DrawerListTile(
            title: "ویژگی‌ها",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () {
              context.mainScreenProvider.navigateToScreen('ویژگی‌ها');
            },
          ),
          DrawerListTile(
            title: "سفارشات",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {
              context.mainScreenProvider.navigateToScreen('سفارشات');
            },
          ),
          DrawerListTile(
            title: "کد تخفیف",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {
              context.mainScreenProvider.navigateToScreen('کد تخفیف');
            },
          ),
          DrawerListTile(
            title: "پوسترها",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.mainScreenProvider.navigateToScreen('پوسترها');
            },
          ),
          // DrawerListTile(
          //   title: "اعلان‌ها",
          //   svgSrc: "assets/icons/menu_notification.svg",
          //   press: () {
          //     context.mainScreenProvider.navigateToScreen('Notifications');
          //   },
          // ),
        ],
      ),
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
        height: 16,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 15.0,
        ),
      ),
    );
  }
}
