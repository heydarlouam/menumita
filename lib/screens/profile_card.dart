




import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/constants.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:slide_countdown/slide_countdown.dart';


class ProfileCard extends StatefulWidget {
  const ProfileCard({Key? key}) : super(key: key);

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  String name = '';
  String family = '';
  String nameBizi = '';
  String iconUrl = '';
  String expiryJalali = ''; // مثل "1404-12-29"

  Duration? remaining;      // مدت‌زمان باقی‌مانده تا انقضا
  bool expired = false;     // اگر گذشته باشد

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = await UserSaveHelper.getUserInfo();
    if (user == null) {
      SnackBarHelper.showErrorSnackBar('اطلاعات کاربر یافت نشد');
      return;
    }

    name         = user['name'] ?? '';
    family       = user['family'] ?? '';
    nameBizi     = user['name_bizi'] ?? '';
    iconUrl      = user['icon_logo_url'] ?? '';
    expiryJalali = user['expirydate'] ?? '';

    remaining = _calcRemaining(expiryJalali);
    expired   = remaining == null || remaining!.inSeconds <= 0;

    setState(() {});
  }

  /// نرمال‌سازی ارقام فارسی/عربی به لاتین
  String _normalizeDigits(String s) {
    const fa = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
    const ar = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(fa[i], i.toString()).replaceAll(ar[i], i.toString());
    }
    return s;
  }

  /// ورودی: "1404-12-29" (Jalali) → خروجی: مدت تا 23:59:59 همان روز (محلی)
  Duration? _calcRemaining(String jalaliStr) {
    if (jalaliStr.isEmpty) return null;

    try {
      final norm = _normalizeDigits(jalaliStr);
      final parts = norm.split('-'); // [yyyy, mm, dd]
      if (parts.length != 3) return null;

      final jy = int.parse(parts[0]);
      final jm = int.parse(parts[1]);
      final jd = int.parse(parts[2]);

      final j = Jalali(jy, jm, jd);
      final g = j.toDateTime(); // به DateTime میلادی (محلی)

      // پایان روز انقضا
      final expiryAtEndOfDay = DateTime(g.year, g.month, g.day, 23, 59, 59);

      final now = DateTime.now();
      final diff = expiryAtEndOfDay.difference(now);

      if (diff.isNegative) return Duration.zero; // منقضی
      return diff;
    } catch (_) {
      return null;
    }
  }

//   @override
//   Widget build(BuildContext context) {
//     print('now');
//     print(expired);
//     final fullName =
//         '${name.isNotEmpty ? name : '-'} ${family.isNotEmpty ? family : ''}';
//
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: defaultPadding,
//         vertical: defaultPadding / 2,
//       ),
//       decoration: BoxDecoration(
//         color: secondaryColor,
//         borderRadius: const BorderRadius.all(Radius.circular(10)),
//         border: Border.all(color: Colors.white10),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // آواتار با بوردر 3px
//           // Container(
//           //   decoration: BoxDecoration(
//           //     border: Border.all(color: primaryColor, width: 3),
//           //     borderRadius: BorderRadius.circular(30),
//           //   ),
//           //   child: ClipRRect(
//           //     borderRadius: BorderRadius.circular(7),
//           //     child: iconUrl.isNotEmpty
//           //         ? Image.network(
//           //       iconUrl,
//           //       height: 48,
//           //       width: 48,
//           //       fit: BoxFit.cover,
//           //       errorBuilder: (_, __, ___) => Image.asset(
//           //         'assets/images/profile_pic.png',
//           //         height: 48,
//           //         width: 48,
//           //         fit: BoxFit.cover,
//           //       ),
//           //     )
//           //         : Image.asset(
//           //       'assets/images/profile_pic.png',
//           //       height: 48,
//           //       width: 48,
//           //       fit: BoxFit.cover,
//           //     ),
//           //   ),
//           // ),
// // آواتار دایره‌ای با بوردر دایره‌ای
//           Container(
//             padding: const EdgeInsets.all(2), // فاصله‌ی کوچک بین تصویر و بوردر
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: primaryColor, width: 3),
//             ),
//             child: ClipOval(
//               child: SizedBox(
//                 width: 48,
//                 height: 48,
//                 child: iconUrl.isNotEmpty
//                     ? Image.network(
//                   iconUrl,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Image.asset(
//                     'assets/images/profile_pic.png',
//                     fit: BoxFit.cover,
//                   ),
//                 )
//                     : Image.asset(
//                   'assets/images/profile_pic.png',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//
//           const SizedBox(width: defaultPadding / 2),
//
//           // ستون نام و نام برند (زیر هم)
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // نام و نام خانوادگی
//                 Text(
//                   fullName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: Colors.white,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//
//                 const SizedBox(height: 3),
//
//                 // نام برند (بولد)
//                 Text(
//                   nameBizi.isNotEmpty ? 'نام برند: $nameBizi' : 'نام برند: —',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 13,
//                     color: Colors.white,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//
//           // شمارش‌گر تا انقضا
//           // ───────── اینجا SlideCountdown ─────────
//           if (!expired && (remaining != null && remaining!.inSeconds > 0))
//
//             Directionality(
//               textDirection: TextDirection.ltr,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // 🔹 شمارشگر با استایل باکس برای هر عدد
//                   SlideCountdownSeparated(
//                     duration: remaining!,
//                     separator: ':',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     separatorStyle: const TextStyle(color: Colors.white70),
//                     decoration: BoxDecoration(
//                       color: primaryColor,            // رنگ پس‌زمینه‌ی هر عدد
//                       borderRadius: BorderRadius.circular(8), // کرو شدن باکس
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 6,
//                       vertical: 4,
//                     ),
//                     separatorPadding: const EdgeInsets.symmetric(horizontal: 2),
//                     onDone: () => setState(() => expired = true),
//                   ),
//
//                   const SizedBox(height: 6),
//
//                   // 🔹 نمایش تاریخ انقضا به صورت شمسی
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.date_range, size: 14, color: Colors.white70),
//                       const SizedBox(width: 4),
//                       Text(
//                         'انقضا: ${expiryJalali.isNotEmpty ? expiryJalali : '—'}',
//                         style: const TextStyle(
//                           color: Colors.white70,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             )
//
//           else
//             const Text(
//               'منقضی',
//               style: TextStyle(color: Colors.redAccent, fontSize: 12),
//             ),
//
//
//         ],
//       ),
//     );
//   }
  @override
  Widget build(BuildContext context) {
    final fullName = '${name.isNotEmpty ? name : '-'} ${family.isNotEmpty ? family : ''}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // نقاط شکست ساده
        final bool isScrollable = w < 420; // هر وقت عرض کمتر از 420 شد، اسکرول افقی بده

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: defaultPadding / 2,
          ),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: Colors.white10),
          ),

          // حالت 1: نرمال (بدون اسکرول افقی)
          // حالت 2: اسکرولی (SingleChildScrollView افقی + Row بدون Expanded)
          child: isScrollable
              ? _buildScrollableRow(context, fullName, constraints)
              : _buildNormalRow(context, fullName),
        );
      },
    );
  }

  /// حالت نرمال: همون Row قبلی با Expanded (هیچ تغییری در دیزاین)
  Widget _buildNormalRow(BuildContext context, String fullName) {
    final avatar = _Avatar(iconUrl: iconUrl);
    final info = _InfoTexts(fullName: fullName, nameBizi: nameBizi);

    final countdown = (!expired && (remaining != null && remaining!.inSeconds > 0))
        ? _ExpiryCountdown(expiryJalali: expiryJalali, remaining: remaining!)
        : const Text('منقضی', style: TextStyle(color: Colors.redAccent, fontSize: 12));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        avatar,
        const SizedBox(width: defaultPadding / 2),
        Expanded(child: info),
        countdown,
      ],
    );
  }

  /// حالت اسکرولی: اسکرول افقی + کنترل عرض‌ها (بدون Expanded)
  Widget _buildScrollableRow(BuildContext context, String fullName, BoxConstraints cons) {
    // اندازه‌های کوچکتر برای حالت باریک
    const double gap = 10;
    const double minInfoWidth = 160; // حداقل عرض متن‌ها
    const double maxCountdownWidth = 160;

    final avatar = _Avatar(iconUrl: iconUrl, size: 40, borderWidth: 2);
    final info = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: minInfoWidth),
      child: _InfoTexts(
        fullName: fullName,
        nameBizi: nameBizi,
        nameFont: 12,
        brandFont: 11,
      ),
    );

    final countdown = (!expired && (remaining != null && remaining!.inSeconds > 0))
        ? ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxCountdownWidth),
      child: _ExpiryCountdown(
        expiryJalali: expiryJalali,
        remaining: remaining!,
        fontSize: 12,
        compact: true, // padding کمتر
      ),
    )
        : const Text('منقضی', style: TextStyle(color: Colors.redAccent, fontSize: 11));

    return ScrollConfiguration(
      behavior: const _NoGlow(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            avatar,
            const SizedBox(width: gap),
            info,
            const SizedBox(width: gap),
            countdown,
          ],
        ),
      ),
    );
  }


}
class _Avatar extends StatelessWidget {
  final String iconUrl;
  final double size;
  final double borderWidth;
  const _Avatar({required this.iconUrl, this.size = 48, this.borderWidth = 3});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primaryColor, width: borderWidth),
      ),
      child: ClipOval(
        child: SizedBox(
          width: size, height: size,
          child: iconUrl.isNotEmpty
              ? Image.network(iconUrl, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset('assets/images/profile_pic.png', fit: BoxFit.cover))
              : Image.asset('assets/images/profile_pic.png', fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _InfoTexts extends StatelessWidget {
  final String fullName;
  final String nameBizi;
  final double nameFont;
  final double brandFont;
  const _InfoTexts({
    required this.fullName,
    required this.nameBizi,
    this.nameFont = 14,
    this.brandFont = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fullName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: nameFont, color: Colors.white),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          nameBizi.isNotEmpty ? 'نام برند: $nameBizi' : 'نام برند: —',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: brandFont, color: Colors.white),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ExpiryCountdown extends StatelessWidget {
  final String expiryJalali;
  final Duration remaining;
  final double fontSize;
  final bool compact;
  const _ExpiryCountdown({
    required this.expiryJalali,
    required this.remaining,
    this.fontSize = 15,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SlideCountdownSeparated(
            duration: remaining,
            separator: ':',
            style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),
            separatorStyle: const TextStyle(color: Colors.white70),
            decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 6, vertical: compact ? 3 : 4),
            separatorPadding: const EdgeInsets.symmetric(horizontal: 2),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.date_range, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                'انقضا: ${expiryJalali.isNotEmpty ? expiryJalali : '—'}',
                style: TextStyle(color: Colors.white70, fontSize: fontSize - 2, fontWeight: FontWeight.w500),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoGlow extends ScrollBehavior {
  const _NoGlow();
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) => child;
}

