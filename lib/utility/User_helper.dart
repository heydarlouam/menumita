

import 'package:admin/services/auth_api.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';


class UserSaveHelper {
  static String? _cache;
  static Map<String, dynamic>? _userCache;

  /// فقط phone_number را از SharedPreferences می‌خواند (با کش)
  static Future<String?> getPhoneNumber({bool showError = true}) async {
    if (_cache != null && _cache!.isNotEmpty) return _cache;
    final phone = await PrefsService.get<String>('user.phone_number');
    if ((phone == null || phone.isEmpty) && showError) {
      SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
      return null;
    }
    _cache = phone;
    return phone;
  }

  /// 🧩 اطلاعات کاربر برای پروفایل
  /// keys: name, family, name_bizi, icon_logo_url, expirydate, menu_type
  ///  - expirydate: مثل "1404-12-29" (جلالی)
  ///  - menu_type: از کلید 'user.menu_type'
  static Future<Map<String, dynamic>?> getUserInfo(
      {bool showError = true}) async {
    if (_userCache != null && _userCache!.isNotEmpty) return _userCache;

    final name = await PrefsService.get<String>('user.name');
    final family = await PrefsService.get<String>('user.family');
    final nameBizi = await PrefsService.get<String>('user.name_bizi');
    final iconUrl = await PrefsService.get<String>('user.icon_logo_url');
    final expiry =
        await PrefsService.get<String>('user.expirydate'); // مثلاً "1404-12-29"
    final menuType =
        await PrefsService.get<String>('user.menu_type'); // 👈 اضافه شد

    final allNullOrEmpty = [name, family, nameBizi, iconUrl, expiry, menuType]
        .every((v) => v == null || (v is String && v.isEmpty));

    if (allNullOrEmpty && showError) {
      SnackBarHelper.showErrorSnackBar('اطلاعات کاربر در حافظه یافت نشد!');
      return null;
    }

    _userCache = {
      'name': name ?? '',
      'family': family ?? '',
      'name_bizi': nameBizi ?? '',
      'icon_logo_url': iconUrl ?? '',
      'expirydate': expiry ?? '',
      'menu_type': menuType ?? '', // 👈 اضافه شد
    };
    return _userCache;
  }

  /// 🔹 بررسی اینکه اشتراک منقضی شده یا نه (بر اساس expirydate جلالی)
  static Future<bool> isExpired() async {
    final info = await getUserInfo(showError: false);
    if (info == null) return true;

    final expiryJalali = info['expirydate'] ?? '';
    if (expiryJalali.isEmpty) return true;

    try {
      final norm = _normalizeDigits(expiryJalali);
      final parts = norm.split('-');
      if (parts.length != 3) return true;

      final jy = int.parse(parts[0]);
      final jm = int.parse(parts[1]);
      final jd = int.parse(parts[2]);

      final j = Jalali(jy, jm, jd);
      final g = j.toDateTime(); // تبدیل به میلادی
      final expiryDate = DateTime(g.year, g.month, g.day, 23, 59, 59);
      final now = DateTime.now();

      return now.isAfter(expiryDate);
    } catch (_) {
      return true;
    }
  }

  /// 🔹 نرمال‌سازی ارقام فارسی/عربی
  static String _normalizeDigits(String s) {
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(fa[i], i.toString()).replaceAll(ar[i], i.toString());
    }
    return s;
  }
}
