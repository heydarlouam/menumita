import 'package:flutter/material.dart';
import 'package:admin/utility/constants.dart';

class DialogHelper {
  /// 🔹 نمایش دیالوگ پایان اشتراک
  static void showExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // با کلیک بیرون بسته میشه
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white24, width: 1),
          ),
          title: Column(
            children: const [
              Icon(Icons.lock_clock, color: Colors.redAccent, size: 48),
              SizedBox(height: 12),
              Text(
                'اشتراک شما به پایان رسیده',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'برای ادامه استفاده از خدمات، لطفاً با پشتیبانی تماس بگیرید یا در واتساپ پیام دهید.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13.5,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '📞 تماس 💬 واتساپ : 09123456789 پشتیبان شما میلاد حیدرلو',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'باشه',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
