// ================================
// lib/services/auth_api.dart
// ================================
import 'dart:convert';
import 'package:get/get.dart';
import 'http_services.dart';



// lib/services/prefs_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static Future<SharedPreferences> get _p async => SharedPreferences.getInstance();

  /// همهٔ فیلدهای Map را با پیشوند ذخیره می‌کند + خود JSON کامل
  static Future<void> saveMap(String prefix, Map<String, dynamic> data) async {
    final prefs = await _p;
    // پاک‌سازی کلیدهای قدیمی این prefix (اختیاری اما تمیز)
    final oldKeys = prefs.getKeys().where((k) => k.startsWith('$prefix.')).toList();
    for (final k in oldKeys) { await prefs.remove(k); }

    for (final entry in data.entries) {
      final key = '$prefix.${entry.key}';
      final v = entry.value;

      if (v == null) {
        await prefs.remove(key);
      } else if (v is String) {
        await prefs.setString(key, v);
      } else if (v is int) {
        await prefs.setInt(key, v);
      } else if (v is double) {
        await prefs.setDouble(key, v);
      } else if (v is bool) {
        await prefs.setBool(key, v);
      } else {
        // برای List/Map و هر نوع سفارشی
        await prefs.setString(key, jsonEncode(v));
      }
    }

    // JSON کاملِ کاربر
    await prefs.setString(prefix, jsonEncode(data));
  }

  static Future<Map<String, dynamic>> readMap(String prefix) async {
    final prefs = await _p;
    final raw = prefs.getString(prefix);
    if (raw == null) return {};
    try { return (jsonDecode(raw) as Map).cast<String, dynamic>(); } catch (_) { return {}; }
  }

  static Future<T?> get<T>(String fullKey) async {
    final prefs = await _p;
    final v = prefs.get(fullKey);
    if (v is T) return v;
    return null;
  }

  static Future<void> clearPrefix(String prefix) async {
    final prefs = await _p;
    final keys = prefs.getKeys().where((k) => k.startsWith('$prefix.')).toList();
    for (final k in keys) { await prefs.remove(k); }
    await prefs.remove(prefix);
  }
}

class AuthApi {
  final HttpService _http = HttpService();

  /// لاگین با phone_number و password
  /// خروجی:
  ///  - null => موفق (برای FlutterLogin)
  ///  - String => متن خطا (برای نمایش)
  ///  - در صورت نیاز می‌تونی data رو برگردونی؛ الان با Get.arguments پاسش می‌دیم.
  Future<({String? error, Map<String, dynamic>? data})> login({
    required String phoneNumber,
    required String password,
  }) async {
    final Response res = await _http.postItem(
      endpointUrl: '/api/auth/login',
      body: {
        'phone_number': phoneNumber.trim(),
        'password': password,
      },
    );

    // ممکنه body String باشه یا Map
    dynamic body = res.body;
    if (body is String) {
      try { body = json.decode(body); } catch (_) {}
    }

    // اگر سرور کد برگردونده اما JSON تهی بود
    body ??= {};

    // موفق
    if (res.statusCode == 200 && (body is Map) && (body['success'] == true)) {
      final data = (body['data'] as Map?)?.cast<String, dynamic>();
      return (error: null, data: data);
    }

    // خطاهای رایج: 400, 401, 404, 422, 500...
    final msg = (body is Map && body['message'] is String)
        ? body['message'] as String
        : 'خطای نامشخص هنگام ورود';

    return (error: msg, data: null);
  }
}

