import 'package:flutter/material.dart';

/// کوچک‌ترین اسپینر ممکن برای دکمه‌های ثبت/ویرایش که حتی اگر
/// [TickerMode] والد غیرفعال شده باشد باز هم انیمیشن را اجرا می‌کند.
class SubmissionSpinner extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const SubmissionSpinner({
    super.key,
    this.size = 20,
    this.strokeWidth = 2,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final spinnerColor = color ?? Theme.of(context).colorScheme.onPrimary;
    return SizedBox(
      height: size,
      width: size,
      child: TickerMode(
        enabled: true,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
        ),
      ),
    );
  }
}

