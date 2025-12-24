import 'dart:convert';
import 'package:appwrite/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appwrite/appwrite.dart' as sdk;
import '../config/environment.dart';
import '../config/ network/appwrite_client.dart';

class PrefsService {
  static Future<SharedPreferences> get _p async => SharedPreferences.getInstance();

  /// همهٔ فیلدهای Map را با پیشوند ذخیره می‌کند + خود JSON کامل
  static Future<void> saveMap(String prefix, Map<String, dynamic> data) async {
    final prefs = await _p;

    // پاک‌سازی کلیدهای قدیمی این prefix (برای تمیزی)
    final oldKeys = prefs.getKeys().where((k) => k.startsWith('$prefix.')).toList();
    for (final k in oldKeys) {
      await prefs.remove(k);
    }

    // ذخیره فیلد به فیلد
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
        // برای List/Map و ...
        await prefs.setString(key, jsonEncode(v));
      }
    }

    // JSON کامل
    await prefs.setString('$prefix.__json', jsonEncode(data));
  }

  /// خواندن Map ذخیره‌شده
  static Future<Map<String, dynamic>> readMap(String prefix) async {
    final prefs = await _p;
    final raw = prefs.getString('$prefix.__json');
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return decoded.cast<String, dynamic>();
      return {};
    } catch (_) {
      return {};
    }
  }

  /// گرفتن مقدار یک کلید (برای UserSaveHelper)
  static Future<T?> get<T>(String fullKey) async {
    final prefs = await _p;
    final v = prefs.get(fullKey);
    if (v is T) return v;
    return null;
  }

  /// پاک کردن داده‌های یک prefix
  static Future<void> clearPrefix(String prefix) async {
    final prefs = await _p;
    final keys = prefs.getKeys().where((k) => k.startsWith('$prefix.')).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
    await prefs.remove('$prefix.__json');
  }
}

class AuthApi {
  /// لاگین با phone_number و password
  /// از Appwrite Function استفاده می‌کند.
  ///
  /// خروجی مثل قبل:
  /// - موفق: (error: null, data: Map)
  /// - ناموفق: (error: 'پیام', data: null)
  Future<({String? error, Map<String, dynamic>? data})> login({
    required String phoneNumber,
    required String password,
  }) async {
    final phone = phoneNumber.trim();
    final pass = password;

    if (phone.isEmpty || pass.isEmpty) {
      return (error: 'شماره تماس و رمز عبور الزامی هستند.', data: null);
    }

    try {
      final functions = sdk.Functions(AppwriteClient.instance.client);

      final payload = jsonEncode({
        'phone_number': phone,
        'password': pass,
      });

      final execution = await functions.createExecution(
        functionId: Environment.functionIdLogin,
        body: payload,
        xasync: false,
        path: '/', // یا '/api/auth/login' (هر دو رو توی Function اجازه دادی)
        method: ExecutionMethod.pOST, // ✅ این دقیقاً همون چیزی بود که ارور می‌داد
        headers: const {
          'content-type': 'application/json',
        },
      );

      final raw = (execution.responseBody ?? '').toString();

      dynamic decoded;
      try {
        decoded = jsonDecode(raw);
      } catch (_) {
        decoded = null;
      }

      if (decoded is Map && decoded['success'] == true) {
        final data = (decoded['data'] as Map?)?.cast<String, dynamic>();
        return (error: null, data: data);
      }

      final msg = (decoded is Map && decoded['message'] is String)
          ? decoded['message'] as String
          : 'خطای نامشخص هنگام ورود';

      return (error: msg, data: null);
    } catch (e) {
      return (error: 'خطای داخلی هنگام ورود', data: null);
    }
  }
}
