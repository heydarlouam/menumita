// import 'package:admin/utility/constants.dart';
// import 'package:flutter/material.dart';
//
// class CustomDropdown<T> extends StatelessWidget {
//   final T? initialValue;
//   final List<T> items;
//   final void Function(T?) onChanged;
//   final String? Function(T?)? validator;
//   final String hintText;
//   final String Function(T) displayItem;
//
//   const CustomDropdown({
//     Key? key,
//     this.initialValue,
//     required this.items,
//     required this.onChanged,
//     this.validator,
//     this.hintText = 'ایتم هارو انتخاب کنید',
//     required this.displayItem,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: DropdownButtonFormField<T>(
//         decoration: InputDecoration(
//           suffixStyle: TextStyle(fontFamily: FONTS_STYLE_FAMILY),
//
//           labelText: hintText,
//           hintText: hintText,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//         ),
//         value: initialValue,
//         items: items.map((T value) {
//           return DropdownMenuItem<T>(
//             value: value,
//             child: Text(displayItem(value),style: TextStyle(fontFamily: FONTS_STYLE_FAMILY),), // Use displayItem to get the text
//           );
//         }).toList(),
//         onChanged: onChanged,
//         validator: validator,
//       ),
//     );
//   }
// }

import 'package:admin/utility/constants.dart';
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? initialValue;
  final List<T> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final String hintText;
  final String Function(T) displayItem;

  const CustomDropdown({
    Key? key,
    this.initialValue,
    required this.items,
    required this.onChanged,
    this.validator,
    this.hintText = 'ایتم هارو انتخاب کنید',
    required this.displayItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontFamily: FONTS_STYLE_FAMILY);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<T>(
        // استایل مقدار انتخاب‌شده داخل فیلد
        style: textStyle,

        decoration: InputDecoration(
          labelText: hintText,
          hintText: hintText,

          // 👇 همه‌ی متن‌های دکوریشن با فونت پروژه
          labelStyle: textStyle,                  // وقتی لیبل داخل فیلد است
          floatingLabelStyle: textStyle,          // وقتی لیبل می‌رود بالا
          hintStyle: textStyle,
          errorStyle: textStyle.copyWith(color: Colors.redAccent, fontSize: 13),
          suffixStyle: textStyle,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),

        value: initialValue,

        // آیتم‌های منو
        items: items.map((T value) {
          return DropdownMenuItem<T>(
            value: value,
            child: Text(

              displayItem(value),
              style: textStyle.copyWith(color: Colors.white), // 👈
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),

        onChanged: onChanged,
        validator: validator,

        // (اختیاری) راست‌چین کردن محتوای منو و فیلد
        isDense: true,
        alignment: AlignmentDirectional.centerStart,
      ),
    );
  }
}
