
import 'package:admin/utility/constants.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';



class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  void _go(BuildContext context, String name) {
    context.mainScreenProvider.navigateToScreen(name);
    if (Scaffold.maybeOf(context)?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        DrawerHeader(
          child: Center(
            child: SizedBox(
              width: 100, height: 100,
              child: Image.asset("assets/images/logo.png", color: Colors.white54),
            ),
          ),
        ),
        DrawerListTile(title: "داشبورد",  svgSrc: "assets/icons/menu_dashboard.svg", press: () => _go(context, 'داشبورد')),
        DrawerListTile(title: "دسته‌بندی", svgSrc: "assets/icons/menu_tran.svg",       press: () => _go(context, 'دسته‌بندی')),
        DrawerListTile(title: "زیر‌دسته", svgSrc: "assets/icons/menu_task.svg",       press: () => _go(context, 'زیر‌دسته')),
        DrawerListTile(title: "برندها",   svgSrc: "assets/icons/menu_doc.svg",        press: () => _go(context, 'برندها')),
        DrawerListTile(title: "نوع ویژگی",svgSrc: "assets/icons/menu_store.svg",      press: () => _go(context, 'نوع ویژگی')),
        DrawerListTile(title: "ویژگی‌ها",  svgSrc: "assets/icons/menu_notification.svg",press: () => _go(context, 'ویژگی‌ها')),
        DrawerListTile(title: "سفارشات",  svgSrc: "assets/icons/menu_profile.svg",    press: () => _go(context, 'سفارشات')),
        DrawerListTile(title: "کد تخفیف", svgSrc: "assets/icons/menu_setting.svg",    press: () => _go(context, 'کد تخفیف')),
        DrawerListTile(title: "پوسترها",  svgSrc: "assets/icons/menu_doc.svg",        press: () => _go(context, 'پوسترها')),
      ],
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({Key? key, required this.title, required this.svgSrc, required this.press}) : super(key: key);
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
      title: Text(title, style: const TextStyle(color: Colors.white54, fontSize: 15.0,fontFamily: FONTS_STYLE_FAMILY)),
    );
  }
}
