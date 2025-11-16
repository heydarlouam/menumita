import 'package:admin/screens/dashboard/menu/side_menu_card.dart';
import 'package:admin/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utility/extensions.dart';

import '../../main/provider/main_screen_provider.dart';


class PeekDrawerButton extends StatefulWidget {
  final String assetPath;
  final double peekPx; // چند پیکسل بیرون باشد
  final Color? color;
  final double size;

  const PeekDrawerButton({
    Key? key,
    required this.assetPath,
    this.peekPx = 5,
    this.color,
    this.size = 28,
  }) : super(key: key);

  @override
  State<PeekDrawerButton> createState() => _PeekDrawerButtonState();
}

class _PeekDrawerButtonState extends State<PeekDrawerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _offset; // از +peekPx تا 0

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 9000),
    );
    _offset = Tween<double>(begin: widget.peekPx, end: 0).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOut, reverseCurve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    // 1) آیکن وارد کادر شود
    await _c.forward();

    // 2) Drawer باز شود
    if (mounted) {
      Scaffold.of(context).openDrawer();
    }

    // 3) وقتی Drawer بسته شد، دوباره کمی بیرون بایستد (اختیاری)
    // برای ساده‌سازی با تاخیر کوتاه برمی‌گردانیم. اگر خواستی
    // می‌تونی روی Navigator.popListener دقیق‌ترش کنی.
    await Future.delayed(const Duration(milliseconds: 950));
    if (mounted) {
      _c.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (btnContext) {
        return AnimatedBuilder(
          animation: _offset,
          builder: (context, child) {
            return Transform.translate(
              // +X یعنی به سمت راست — کمی بیرون می‌رود
              offset: Offset(_offset.value, 0),
              child: IconButton(
                onPressed: _handleTap,
                tooltip: 'menumita',
                icon: Image.asset(
                  widget.assetPath,
                  width: widget.size,
                  height: widget.size,
                  color: widget.color,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

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



        return Scaffold(
          appBar: AppBar(
            backgroundColor: secondaryColor,
            automaticallyImplyLeading: false, // دکمهٔ پیش‌فرض حذف
            title: const Text('menumita', style: TextStyle(fontFamily: FONTS_STYLE_FAMILY)),
            leadingWidth: 65, // کمی جا بده تا بیرون‌زدگی بهتر دیده شود
            leading: PeekDrawerButton(
              assetPath: 'assets/images/menumita_menu.png',
              peekPx: 27,      // مثلا 15px از چپ بیرون بزند
              size: 65,
              color: Colors.white,

              // openEndDrawer: false, // اگر endDrawer داشتی، اینو true کن
            ),
          ),
          drawer: const Drawer(
            child: SafeArea(child: SideMenuCard()),
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

