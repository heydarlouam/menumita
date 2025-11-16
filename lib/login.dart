import 'dart:convert';

import 'package:admin/screens/dashboard/mainscreen/main_screen.dart';
import 'package:admin/services/auth_api.dart';
import 'package:admin/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:get/get.dart';

import 'utility/extensions.dart';

// class _AuthClient extends GetConnect {
//   _AuthClient() {
//     httpClient.baseUrl = MAIN_URL;
//     httpClient.timeout = const Duration(seconds: 15);
//   }
//
//   Future<({String? error, Map<String, dynamic>? data})> login({
//     required String phoneNumber,
//     required String password,
//   }) async {
//     try {
//       final res = await post(
//         '/api/auth/login',
//         { 'phone_number': phoneNumber.trim(), 'password': password },
//         contentType: 'application/json',
//       );
//
//       final body = res.body;
//       if (res.statusCode == 200 && body is Map && body['success'] == true) {
//         return (error: null, data: (body['data'] as Map?)?.cast<String, dynamic>());
//       }
//
//       final msg = (body is Map && body['message'] is String)
//           ? body['message'] as String
//           : 'خطای نامشخص هنگام ورود';
//       return (error: msg, data: null);
//     } catch (_) {
//       return (error: 'عدم دسترسی به سرور', data: null);
//     }
//   }
// }

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
        title: 'ورود',
        onLogin: _onLogin,
        onSubmitAnimationCompleted: () async {
          await context.dataProvider.initAfterLogin();
          Get.offAll(() => MainScreen());
        },
        hideForgotPasswordButton: true,
        userType: LoginUserType.text,
        userValidator: (value) {
          if (value == null || value.trim().isEmpty)
            return 'نام کاربری را وارد کنید';
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
                borderRadius: BorderRadius.all(Radius.circular(16))),
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

class AfterLoginPage extends StatelessWidget {
  const AfterLoginPage({super.key});

  Future<Map<String, dynamic>> _loadUser() async {
    final data = await PrefsService.readMap('user');
    return data;
  }

  // برچسب‌های فارسی برای کلیدهای مهم
  static const Map<String, String> _faLabels = {
    'name': 'نام',
    'family': 'نام خانوادگی',
    'phone_number': 'شماره تماس',
    'name_bizi': 'نام کسب‌وکار',
    'address': 'آدرس',
    'address_neshan': 'نشانی نشانه',
    'address_balad': 'نشانی بلد',
    'address_waze': 'نشانی Waze',
    'address_googlemap': 'نشانی گوگل‌مپ',
    'menu_type': 'نوع منو',
    'expirydate': 'تاریخ انقضا',
    'created': 'ایجاد شده',
    'updated': 'به‌روزشده',
    'id': 'شناسه',
    'collectionId': 'شناسه کالکشن',
    'collectionName': 'نام کالکشن',
    'icon_logo': 'نام فایل لوگو',
    'icon_logo_url': 'آدرس لوگو',
    'icon_location': 'نام فایل لوکیشن',
    'icon_location_url': 'آدرس لوکیشن',
  };

  String _labelOf(String key) => _faLabels[key] ?? key;

  Widget _valueWidget(dynamic v) {
    if (v == null)
      return const SelectableText('—', style: TextStyle(color: Colors.white70));
    if (v is String)
      return SelectableText(v, style: const TextStyle(color: Colors.white));
    return SelectableText(jsonEncode(v),
        style: const TextStyle(color: Colors.white));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151924),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2430),
        title: const Text('بعد از ورود'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadUser(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snap.data ?? {};
          if (user.isEmpty) {
            return const Center(
              child: Text('اطلاعات کاربر یافت نشد',
                  style: TextStyle(color: Colors.white70)),
            );
          }

          final name = (user['name'] ?? '').toString();
          final family = (user['family'] ?? '').toString();
          final phone = (user['phone_number'] ?? '').toString();

          final logoUrl = (user['icon_logo_url'] ?? '').toString().trim();
          final locationUrl =
              (user['icon_location_url'] ?? '').toString().trim();

          // اول کلیدهای مهم را بالای لیست نشان بده
          final List<String> primaryKeys = [
            'name',
            'family',
            'phone_number',
            'name_bizi',
            'address',
            'menu_type',
            'created',
            'updated',
            'icon_logo_url',
            'icon_location_url'
          ];

          // بقیهٔ کلیدها
          final Set<String> allKeys =
              user.keys.map((e) => e.toString()).toSet();
          final List<String> otherKeys = allKeys
              .where((k) => !primaryKeys.contains(k))
              .toList()
            ..sort((a, b) => a.compareTo(b));

          return Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header card
                Card(
                  color: const Color(0xFF1E2430),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // آواتار
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white10,
                          backgroundImage: (logoUrl.isNotEmpty)
                              ? NetworkImage(logoUrl)
                              : null,
                          child: (logoUrl.isEmpty)
                              ? Text(
                                  (name.isNotEmpty ? name[0] : '؟'),
                                  style: const TextStyle(
                                      fontSize: 24, color: Colors.white70),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$name ${family.isNotEmpty ? family : ''}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  )),
                              const SizedBox(height: 6),
                              Text(phone,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                        // دکمه کپی کل JSON
                        IconButton(
                          tooltip: 'کپی JSON کاربر',
                          onPressed: () async {
                            // await Clipboard.setData(ClipboardData(text: jsonEncode(user)));
                            // if (context.mounted) {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     const SnackBar(content: Text('JSON کاربر کپی شد')),
                            //   );
                            // }
                          },
                          icon: const Icon(Icons.copy, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // اگر آدرس لوکیشن تصویر هم هست، یک کارت کوچک نشان بده
                if (locationUrl.isNotEmpty)
                  Card(
                    color: const Color(0xFF1E2430),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Image.network(locationUrl,
                              fit: BoxFit.cover, height: 160),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'لوکیشن/تصویر ثانویه',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // لیست کلیدهای مهم
                _SectionTitle('اطلاعات اصلی'),
                ...primaryKeys.where((k) => user.containsKey(k)).map((k) =>
                    _KVTile(
                        label: _labelOf(k),
                        value: user[k],
                        fullKey: 'user.$k')),

                const SizedBox(height: 16),

                // بقیهٔ آیتم‌ها
                _SectionTitle('سایر اطلاعات'),
                if (otherKeys.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('موردی ندارد',
                        style: TextStyle(color: Colors.white54)),
                  ),
                ...otherKeys.map(
                  (k) => _KVTile(
                      label: _labelOf(k), value: user[k], fullKey: 'user.$k'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

class _KVTile extends StatelessWidget {
  final String label;
  final dynamic value;
  final String fullKey; // برای کپی

  const _KVTile({
    super.key,
    required this.label,
    required this.value,
    required this.fullKey,
  });

  @override
  Widget build(BuildContext context) {
    final String textValue =
        value == null ? '—' : (value is String ? value : jsonEncode(value));

    return Card(
      color: const Color(0xFF1E2430),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(label, style: const TextStyle(color: Colors.white70)),
        subtitle: SelectableText(
          textValue,
          style: const TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
        ),
        trailing: IconButton(
          tooltip: 'کپی مقدار',
          icon: const Icon(Icons.copy, color: Colors.white54),
          onPressed: () async {
            // await Clipboard.setData(ClipboardData(text: textValue));
            // if (context.mounted) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(content: Text('مقدار «$label» کپی شد')),
            //   );
            // }
          },
        ),
      ),
    );
  }
}
