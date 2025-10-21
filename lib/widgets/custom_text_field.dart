// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import '../utility/constants.dart';
//
// class CustomTextField extends StatelessWidget {
//   final String labelText;
//   final TextEditingController controller;
//   final TextInputType? inputType;
//   final int? lineNumber;
//   final void Function(String?) onSave;
//   final String? Function(String?)? validator;
//
//   const CustomTextField({
//     Key? key,
//     required this.labelText,
//     required this.onSave,
//     this.inputType = TextInputType.text,
//     this.lineNumber = 1,
//     this.validator,
//     required this.controller,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: TextFormField(
//         style: TextStyle(fontFamily: FONTS_STYLE_FAMILY),
//         controller: controller,
//         strutStyle: StrutStyle(fontFamily: FONTS_STYLE_FAMILY),
//         maxLines: lineNumber,
//         decoration: InputDecoration(
//           suffixStyle: TextStyle(fontFamily: FONTS_STYLE_FAMILY),
//
//           hintStyle: TextStyle(fontFamily: FONTS_STYLE_FAMILY),
//           labelText: labelText,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8.0),
//             borderSide: BorderSide(color: secondaryColor),
//           ),
//         ),
//         keyboardType: inputType,
//         onSaved: (value) {
//           onSave(value?.isEmpty ?? true ? null : value);
//         },
//         validator: validator,
//         inputFormatters: [
//           LengthLimitingTextInputFormatter(700),
//           if (inputType == TextInputType.number)
//             FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utility/constants.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final TextInputType? inputType;
  final int? lineNumber;
  final void Function(String?) onSave;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.labelText,
    required this.onSave,
    this.inputType = TextInputType.text,
    this.lineNumber = 1,
    this.validator,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontFamily: FONTS_STYLE_FAMILY);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        style: textStyle, // 👈 متن اصلی
        strutStyle: StrutStyle(fontFamily: FONTS_STYLE_FAMILY),
        controller: controller,
        maxLines: lineNumber,
        decoration: InputDecoration(
          labelText: labelText,
          floatingLabelStyle: TextStyle(fontFamily: FONTS_STYLE_FAMILY),      // 👈 وقتی لیبل میره بالا
          labelStyle: textStyle,          // 👈 لیبل هم با همین فونت
          hintStyle: textStyle,           // 👈 hint
          errorStyle: textStyle.copyWith( // 👈 خطا هم با همین فونت
            color: Colors.redAccent,
            fontSize: 13,
          ),
          suffixStyle: textStyle,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: secondaryColor),
          ),
        ),
        keyboardType: inputType,
        onSaved: (value) {
          onSave(value?.isEmpty ?? true ? null : value);
        },
        validator: validator,
        inputFormatters: [
          LengthLimitingTextInputFormatter(700),
          if (inputType == TextInputType.number)
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
        ],
      ),
    );
  }
}
