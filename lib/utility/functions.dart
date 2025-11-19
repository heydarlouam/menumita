import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import 'constants.dart';

String formatTimestamp(BuildContext context, String? timestamp) {
  if (timestamp == null) {
    return 'N/A';
  }
  try {
    DateTime dateTime = DateTime.parse(timestamp);
    bool use24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    String formatString =
        use24HourFormat ? 'dd/MM/yyyy, HH:mm' : 'dd/MM/yyyy, hh:mm a';
    return DateFormat(formatString).format(dateTime.toLocal());
  } catch (e) {
    return 'Invalid Date';
  }
}

String formatCurrency(BuildContext context, double? price) {
  return price == null
      ? '${currency_symbol}0.0'
      : currency_symbol +
          NumberFormat.decimalPattern(
                  Localizations.localeOf(context).toString())
              .format(price);
}
const CURRENCY_SYMBOL =  " ریال ";


String formatCurrencyReal(BuildContext context, double? price) {
  return price == null
      ? ' ${CURRENCY_SYMBOL} '
      : CURRENCY_SYMBOL +
      NumberFormat.decimalPattern(
          Localizations.localeOf(context).toString())
          .format(price);
}


String formatToJalali(String timestamp) {
  try {
    DateTime dateTime = DateTime.parse(timestamp);
    Jalali jalali = Jalali.fromDateTime(dateTime.toLocal());

    String monthName = _getJalaliMonthName(jalali.month);
    String time = _formatTime(dateTime);

    return '${jalali.day} $monthName ${jalali.year} - $time';
  } catch (e) {
    return 'تاریخ نامعتبر';
  }
}

// تابع گرفتن نام ماه شمسی
String _getJalaliMonthName(int month) {
  final months = [
    '',
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند'
  ];
  return months[month];
}

// تابع فرمت زمان
String _formatTime(DateTime dateTime) {
  String hour = dateTime.hour.toString().padLeft(2, '0');
  String minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

// تابع محاسبه زمان گذشته
String getTimeAgo(String timestamp) {
  try {
    DateTime dateTime = DateTime.parse(timestamp);
    DateTime now = DateTime.now().toLocal();
    Duration difference = now.difference(dateTime.toLocal());

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} ثانیه پیش';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} دقیقه پیش';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ساعت پیش';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} روز پیش';
    } else if (difference.inDays < 365) {
      int months = (difference.inDays / 30).floor();
      return '$months ماه پیش';
    } else {
      int years = (difference.inDays / 365).floor();
      return '$years سال پیش';
    }
  } catch (e) {
    return 'زمان نامعتبر';
  }
}


String money(BuildContext ctx, double? v) =>
    v == null ? '-' : formatCurrencyReal(ctx, v);
