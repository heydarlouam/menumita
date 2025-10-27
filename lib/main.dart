import 'package:admin/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';
import 'dart:async';

import 'core/data/data_provider.dart';
import 'core/routes/app_pages.dart';
import 'screens/brands/provider/brand_provider.dart';
import 'screens/category/provider/category_provider.dart';
import 'screens/coupon_code/provider/coupon_code_provider.dart';
import 'screens/dashboard/provider/dash_board_provider.dart';
import 'screens/dashboard/mainscreen/main_screen.dart';
import 'screens/main/provider/main_screen_provider.dart';

import 'screens/order/provider/order_provider.dart';
import 'screens/posters/provider/poster_provider.dart';
import 'screens/sub_category/provider/sub_category_provider.dart';
import 'screens/variants/provider/variant_provider.dart';
import 'screens/variants_type/provider/variant_type_provider.dart';
import 'utility/constants.dart';
import 'utility/extensions.dart';

// void main() {
//
//   runZonedGuarded(() {
//     WidgetsFlutterBinding.ensureInitialized();
//
//     FlutterError.onError = (FlutterErrorDetails details) {
//       FlutterError.dumpErrorToConsole(details);
//     };
//
//     runApp(
//       MultiProvider(
//         providers: [
//           ChangeNotifierProvider(create: (_) => DataProvider()),
//           ChangeNotifierProvider(create: (_) => MainScreenProvider()),
//           ChangeNotifierProvider(create: (context) => CategoryProvider(context.dataProvider)),
//           ChangeNotifierProvider(create: (context) => SubCategoryProvider(context.dataProvider)),
//           ChangeNotifierProvider(create: (context) => BrandProvider(context.dataProvider)),
//           ChangeNotifierProvider(create: (context) => PosterProvider(context.dataProvider)),
//           ChangeNotifierProvider(create: (context) => OrderProvider(context.dataProvider)),
//           ChangeNotifierProvider(create: (context) => VariantsTypeProvider(context.dataProvider)),
//           ChangeNotifierProvider(create: (context) => VariantsProvider(context.dataProvider)),
//           ChangeNotifierProvider(create: (context) => DashBoardProvider(context.dataProvider)),
//           ChangeNotifierProvider(create: (context) => CouponCodeProvider(context.dataProvider)),
//         ],
//         child: MyApp(),
//       ),
//     );
//
//   }, (error, stack) {
//     // TODO: گزارش خطا (Sentry/Logger)
//   });
// }
//
// // در همان فایل main.dart شما:
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'menumita',
//       locale: const Locale('fa'),
//       theme: ThemeData(
//         brightness: Brightness.dark,
//         fontFamily: FONTS_STYLE_FAMILY,
//         scaffoldBackgroundColor: bgColor,
//         canvasColor: secondaryColor,
//         textTheme: Theme.of(context).textTheme.apply(
//           bodyColor: Colors.white,
//           displayColor: Colors.white,
//         ),
//         // ✅ اضافه کن: تغییر رنگ تمام ProgressIndicatorها (دایره‌های لودینگ)
//         progressIndicatorTheme: const ProgressIndicatorThemeData(
//           color: Colors.grey, // 👈 رنگ لودینگ دلخواهت
//         ),
//
//         // ✅ اگه نسخه‌ی flutter_login از ColorScheme.secondary استفاده می‌کنه:
//         colorScheme: const ColorScheme.dark().copyWith(
//           secondary: Colors.grey, // 👈 رنگ لودینگ و Accent سراسری
//         ),
//       ),
//
//       // ✅ به‌جای initialRoute و AppPages.HOME از RootDecider استفاده کن:
//       home: const RootDecider(),
//
//       // اگر خواستی نگه دار، ولی در این حالت اجباری نیست:
//       unknownRoute: GetPage(name: '/notFound', page: () =>  MainScreen()),
//       defaultTransition: Transition.cupertino,
//       getPages: AppPages.routes,
//     );
//   }
// }

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // ⬅️ اینجا وضعیت لاگین رو از SharedPreferences می‌خونیم
    final userMap = await PrefsService.readMap('user');
    final isLoggedIn = userMap.isNotEmpty;

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DataProvider()),
          ChangeNotifierProvider(create: (_) => MainScreenProvider()),
          ChangeNotifierProvider(create: (context) => CategoryProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => SubCategoryProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => BrandProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => PosterProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => OrderProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => VariantsTypeProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => VariantsProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => DashBoardProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => CouponCodeProvider(context.dataProvider)),
        ],
        child: MyApp(isLoggedIn: isLoggedIn), // ⬅️ پاس دادن وضعیت
      ),
    );
  }, (error, stack) {
    // TODO: گزارش خطا (Sentry/Logger)
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedIn});
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'menumita',
      locale: const Locale('fa'),
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: FONTS_STYLE_FAMILY,
        scaffoldBackgroundColor: bgColor,
        canvasColor: secondaryColor,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        // رنگ لودینگ‌ها
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.grey),
        colorScheme: const ColorScheme.dark().copyWith(secondary: Colors.grey),
      ),

      // ⬅️ اینجا دیگه RootDecider نداریم
      home: isLoggedIn ?  MainScreen() : LoginScreen(),

      unknownRoute: GetPage(name: '/notFound', page: () =>  MainScreen()),
      defaultTransition: Transition.cupertino,
      getPages: AppPages.routes,
    );
  }
}



// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//
//       debugShowCheckedModeBanner: false,
//       title: 'menumita',
//       locale: const Locale('fa'), // 👈 زبان پیش‌فرض
//
//       theme: ThemeData(
//         brightness: Brightness.dark, // چون تم تاریک داری
//         fontFamily: FONTS_STYLE_FAMILY,
//         scaffoldBackgroundColor: bgColor,
//         canvasColor: secondaryColor,
//         textTheme: Theme.of(context).textTheme.apply(
//           bodyColor: Colors.white,
//           displayColor: Colors.white,
//         ),
//       ),
//
//       initialRoute: AppPages.HOME,
//       unknownRoute: GetPage(name: '/notFound', page: () => MainScreen()),
//       defaultTransition: Transition.cupertino,
//
//       getPages: AppPages.routes,
//     );
//   }
// }




class RootDecider extends StatelessWidget {
  const RootDecider({super.key});

  Future<bool> _hasUser() async {
    final m = await PrefsService.readMap('user');
    return m.isNotEmpty; // اگر خالی نبود یعنی لاگین شده‌ایم
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasUser(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final loggedIn = snap.data ?? false;
        // مهم: از GetX برای جایگزینی کامل استفاده کن تا نت برنگرده
        if (loggedIn) {
          // کاربر داریم ⇒ مستقیم به Main
          // از همون‌جا که RootDecider خودش یک صفحه است، ویجت مقصد رو برمی‌گردونیم:
          return  MainScreen();
        } else {
          // کاربر نداریم ⇒ صفحه لاگین
          return  LoginScreen(); // صفحهٔ لاگینِ خودت
        }
      },
    );
  }
}


class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final Duration _anim = const Duration(milliseconds: 900);
  final _auth = AuthApi();

  Future<String?> _onLogin(LoginData data) async {
    final phone = (data.name ?? '').trim();
    final pass  = data.password ?? '';

    if (phone.isEmpty) return 'نام کاربری را وارد کنید';
    if (phone.length < 3) return 'حداقل ۳ کاراکتر';
    if (pass.isEmpty) return 'رمز عبور را وارد کنید';

    final res = await _auth.login(phoneNumber: phone, password: pass);

    // ✅ اگر موفق بود: همهٔ فیلدها را در SharedPreferences ذخیره کن
    if (res.error == null && res.data != null) {
      // اگر سرور URL فایل‌ها را داده، همان‌ها هم ذخیره می‌شوند:
      // icon_logo_url, icon_location_url, و ...
      await PrefsService.saveMap('user', res.data!);
    }

    // هماهنگ با انیمیشن
    await Future.delayed(_anim);

    // اگر خطا داریم، متنش را بده تا FlutterLogin انیمیشن موفق را اجرا نکند
    if (res.error != null) return res.error;

    // موفق: اجازه بده انیمیشن کامل شود
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: FlutterLogin(
        title: 'ورود',
        onLogin: _onLogin,
        // onSubmitAnimationCompleted: () {
        //   Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (_) => const AfterLoginPage()),
        //   );
        // },
        onSubmitAnimationCompleted: () {
          // به جای AfterLoginPage:
          Get.offAll(() =>  MainScreen()); // یا Get.offAllNamed(AppPages.HOME);
        },
        hideForgotPasswordButton: true,
        userType: LoginUserType.text,
        userValidator: (value) {
          if (value == null || value.trim().isEmpty) return 'نام کاربری را وارد کنید';
          if (value.trim().length < 3) return 'حداقل ۳ کاراکتر';
          return null;
        },
        validateUserImmediately: true,
        messages:  LoginMessages(
          userHint: 'نام کاربری',
          passwordHint: 'رمز عبور',
          loginButton: 'ورود',
        ),
        theme:  LoginTheme(

          primaryColor: Color(0xFF151924),

          accentColor: primaryColor,
          pageColorDark: Color(0xFF151924),
          pageColorLight: Color(0xFF151924),
          cardTheme: CardTheme(
            color: Color(0xFF1E2430),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          ),
          textFieldStyle: TextStyle(color: Colors.grey),
          inputTheme: InputDecorationTheme(
            hintStyle: TextStyle(color: Colors.grey),
            labelStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Color(0xFF1E2430),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          buttonTheme: LoginButtonTheme(
            backgroundColor: primaryColor,
            elevation: 0,
          ),
          titleStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
          bodyStyle: TextStyle(color: Colors.white70),

        ),
        onRecoverPassword: (_) async => null,
      ),
    );
  }
}

