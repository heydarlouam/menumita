//
// import 'package:admin/config/network/services/auth_api.dart';
// import 'package:admin/screens/dashboard/mainscreen/main_screen.dart';
//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_login/flutter_login.dart';
// import 'package:get/get.dart';
//
// import '../utility/extensions.dart';
//
//
// class LoginScreen extends StatelessWidget {
//   LoginScreen({super.key});
//
//   final Duration _anim = const Duration(milliseconds: 900);
//   final _auth = AuthApi();
//
//   Future<String?> _onLogin(LoginData data) async {
//     final phone = (data.name ?? '').trim();
//     final pass = data.password ?? '';
//
//     if (phone.isEmpty) return 'نام کاربری را وارد کنید';
//     if (phone.length < 3) return 'حداقل ۳ کاراکتر';
//     if (pass.isEmpty) return 'رمز عبور را وارد کنید';
//
//     final res = await _auth.login(phoneNumber: phone, password: pass);
//
//     // ✅ اگر موفق بود: همهٔ فیلدها را در SharedPreferences ذخیره کن
//     if (res.error == null && res.data != null) {
//       // اگر سرور URL فایل‌ها را داده، همان‌ها هم ذخیره می‌شوند:
//       // icon_logo_url, icon_location_url, و ...
//       await PrefsService.saveMap('user', res.data!);
//     }
//
//     // هماهنگ با انیمیشن
//     await Future.delayed(_anim);
//
//     // اگر خطا داریم، متنش را بده تا FlutterLogin انیمیشن موفق را اجرا نکند
//     if (res.error != null) return res.error;
//
//     // موفق: اجازه بده انیمیشن کامل شود
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: FlutterLogin(
//         title: 'ورود',
//         onLogin: _onLogin,
//         // onSubmitAnimationCompleted: () async {
//         //   await context.dataProvider.initAfterLogin();
//         //   Get.offAll(() => MainScreen());
//         // },
//         onSubmitAnimationCompleted: () async {
//           // 1) اول ناوبری به پنل (تا هیچوقت روی صفحه خالی گیر نکنه)
//           Get.offAll(() => MainScreen());
//
//           // 2) بعدا دیتا رو لود کن (بدون await)
//           context.dataProvider.initAfterLogin().catchError((e, st) {
//             debugPrint("❌ initAfterLogin failed: $e");
//           });
//         },
//
//         hideForgotPasswordButton: true,
//         userType: LoginUserType.text,
//         userValidator: (value) {
//           if (value == null || value.trim().isEmpty)
//             return 'نام کاربری را وارد کنید';
//           if (value.trim().length < 3) return 'حداقل ۳ کاراکتر';
//           return null;
//         },
//         validateUserImmediately: true,
//         messages: LoginMessages(
//           userHint: 'نام کاربری',
//           passwordHint: 'رمز عبور',
//           loginButton: 'ورود',
//         ),
//         theme: LoginTheme(
//           primaryColor: Color(0xFF151924),
//           accentColor: Color(0xFFE91E63),
//           pageColorDark: Color(0xFF151924),
//           pageColorLight: Color(0xFF151924),
//           cardTheme: CardTheme(
//             color: Color(0xFF1E2430),
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(16))),
//           ),
//           textFieldStyle: TextStyle(color: Colors.grey),
//           inputTheme: InputDecorationTheme(
//             hintStyle: TextStyle(color: Colors.grey),
//             labelStyle: TextStyle(color: Colors.grey),
//             filled: true,
//             fillColor: Color(0xFF1E2430),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(10)),
//               borderSide: BorderSide(color: Colors.white24),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(10)),
//               borderSide: BorderSide(color: Color(0xFFE91E63), width: 2),
//             ),
//           ),
//           buttonTheme: LoginButtonTheme(
//             backgroundColor: Color(0xFFE91E63),
//             elevation: 0,
//           ),
//           titleStyle: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//             fontSize: 22,
//           ),
//           bodyStyle: TextStyle(color: Colors.white70),
//         ),
//         onRecoverPassword: (_) async => null,
//       ),
//     );
//   }
// }
//
//

import 'package:admin/config/network/services/auth_api.dart';
import 'package:admin/screens/dashboard/mainscreen/main_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:get/get.dart';

import '../utility/extensions.dart';
import '../core/routes/app_pages.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final Duration _anim = const Duration(milliseconds: 900);
  final _auth = AuthApi();

  Future<String?> _onLogin(LoginData data) async {
    final phone = (data.name ?? '').trim();
    final pass = data.password ?? '';

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
        disableCustomPageTransformer: true, // ✅ مهم
        title: 'ورود',
        onLogin: _onLogin,
        // onSubmitAnimationCompleted: () async {
        //   await context.dataProvider.initAfterLogin();
        //   Get.offAll(() => MainScreen());
        // },
        onSubmitAnimationCompleted: () async {
          // 1) اول ناوبری به پنل (تا هیچوقت روی صفحه خالی گیر نکنه)
          Get.offAllNamed(AppPages.main);

          // 2) بعدا دیتا رو لود کن (بدون await)
          context.dataProvider.initAfterLogin().catchError((e, st) {
            debugPrint("❌ initAfterLogin failed: $e");
          });
        },

        hideForgotPasswordButton: true,
        userType: LoginUserType.text,
        userValidator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'نام کاربری را وارد کنید';
          }
          if (value.trim().length < 3) return 'حداقل ۳ کاراکتر';
          return null;
        },
        validateUserImmediately: true,
        messages: LoginMessages(
          userHint: 'نام کاربری',
          passwordHint: 'رمز عبور',
          loginButton: 'ورود',
        ),
        theme: LoginTheme(
          primaryColor: Color(0xFF151924),
          accentColor: Color(0xFFE91E63),
          pageColorDark: Color(0xFF151924),
          pageColorLight: Color(0xFF151924),
          cardTheme: CardTheme(
            color: Color(0xFF1E2430),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
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
              borderSide: BorderSide(color: Color(0xFFE91E63), width: 2),
            ),
          ),
          buttonTheme: LoginButtonTheme(
            backgroundColor: Color(0xFFE91E63),
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
