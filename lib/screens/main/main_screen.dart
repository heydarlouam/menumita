import 'package:admin/screens/dashboard/components/side_menu_card.dart';
import 'package:admin/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utility/extensions.dart';

import 'provider/main_screen_provider.dart';


class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.dataProvider; // warm-up
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;

        if (isDesktop) {
          return Scaffold(
            body: SafeArea(
              child:


              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 260,
                    child: Column(
                      children: const [
                        Expanded(child: SideMenuCard()),
                      ],
                    ),
                  ),
                 // const SizedBox(width: defaultPadding / 9), // 👈 فقط این عدد رو کم کن
                  Expanded(
                    child: Consumer<MainScreenProvider>(
                      builder: (context, provider, _) => provider.selectedScreen,
                    ),
                  ),
                ],
              ),

            ),
          );
        }

        // 📱 موبایل/تبلت: Drawer هم مثل کارت
        return Scaffold(
          appBar: AppBar(title: const Text('menumita',style: const TextStyle(fontFamily: FONTS_STYLE_FAMILY)),),
          drawer: Drawer(
            child: SafeArea(
              // Drawer خودش ارتفاع محدود می‌دهد؛ کارت همون استایل دسکتاپ
              child: const SideMenuCard(),
            ),
          ),
          body: SafeArea(
            child: Consumer<MainScreenProvider>(
              builder: (context, provider, _) => provider.selectedScreen,
            ),
          ),
        );
      },
    );
  }
}

