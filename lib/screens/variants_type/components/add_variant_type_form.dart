// import 'package:admin/screens/variants_type/provider/variant_type_provider.dart';
// import 'package:flutter/material.dart';
//
// import '../../../models/variant_type.dart';
// import '../../../utility/constants.dart';
// import '../../../utility/extensions.dart';
// import '../../../widgets/custom_text_field.dart';
//
// // class VariantTypeSubmitForm extends StatelessWidget {
// //   final VariantType? variantType;
// //
// //   const VariantTypeSubmitForm({super.key, this.variantType});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     context.variantTypeProvider.setDataForUpdateVariantTYpe(variantType);
// //
// //     return SingleChildScrollView(
// //       child: Form(
// //         key: context.variantTypeProvider.addVariantsTypeFormKey,
// //         child: Container(
// //           padding: EdgeInsets.all(defaultPadding),
// //           width: MediaQuery.of(context).size.width * 0.5,
// //           decoration: BoxDecoration(
// //             color: bgColor,
// //             borderRadius: BorderRadius.circular(12.0),
// //           ),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               SizedBox(height: defaultPadding),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: CustomTextField(
// //                       controller: context.variantTypeProvider.variantNameCtrl,
// //                       labelText: 'Variant Name',
// //                       onSave: (val) {},
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'Please enter a variant name';
// //                         }
// //                         return null;
// //                       },
// //                     ),
// //                   ),
// //                   Expanded(
// //                     child: CustomTextField(
// //                       controller: context.variantTypeProvider.variantTypeCtrl,
// //                       labelText: 'Variant Type',
// //                       onSave: (val) {},
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'Please enter a type name';
// //                         }
// //                         return null;
// //                       },
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               SizedBox(height: defaultPadding * 2),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       foregroundColor: Colors.white,
// //                       backgroundColor: secondaryColor,
// //                     ),
// //                     onPressed: () {
// //                       Navigator.of(context).pop(); // Close the popup
// //                     },
// //                     child: Text('Cancel'),
// //                   ),
// //                   SizedBox(width: defaultPadding),
// //                   ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       foregroundColor: Colors.white,
// //                       backgroundColor: primaryColor,
// //                     ),
// //                     onPressed: () {
// //                       // Validate and save the form
// //                       if (context.variantTypeProvider.addVariantsTypeFormKey
// //                           .currentState!
// //                           .validate()) {
// //                         context.variantTypeProvider.addVariantsTypeFormKey
// //                             .currentState!
// //                             .save();
// //                         context.variantTypeProvider.submitVariantType();
// //
// //                         Navigator.of(context).pop();
// //                       }
// //                     },
// //                     child: Text('Submit'),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // How to show the category popup
// // void showAddVariantsTypeForm(BuildContext context, VariantType? variantType) {
// //   showDialog(
// //     context: context,
// //     builder: (BuildContext context) {
// //       return AlertDialog(
// //         backgroundColor: bgColor,
// //         title: Center(
// //             child: Text('Add Variant Type'.toUpperCase(),
// //                 style: TextStyle(color: primaryColor))),
// //         content: VariantTypeSubmitForm(variantType: variantType),
// //       );
// //     },
// //   );
// // }
//
//
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../../../models/variant_type.dart';
// // import '../../../utility/constants.dart';
// // import '../../../utility/extensions.dart';
// // import '../../../widgets/custom_text_field.dart';
// //
// // class VariantTypeSubmitForm extends StatelessWidget {
// //   final VariantType? variantType;
// //   const VariantTypeSubmitForm({super.key, this.variantType});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       context.variantTypeProvider.setDataForUpdateVariantType(variantType);
// //     });
// //
// //     return SingleChildScrollView(
// //       child: Form(
// //         key: context.variantTypeProvider.formKey,
// //         child: Container(
// //           width: MediaQuery.of(context).size.width * 0.35,
// //           decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
// //           padding: const EdgeInsets.all(defaultPadding),
// //           child: Column(mainAxisSize: MainAxisSize.min, children: [
// //             Row(children: [
// //               Expanded(
// //                 child: CustomTextField(
// //                   controller: context.variantTypeProvider.variantNameCtrl,
// //                   labelText: 'Variant Name',
// //                   validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
// //                   onSave: (_) {},
// //                 ),
// //               ),
// //               const SizedBox(width: defaultPadding),
// //               Expanded(
// //                 child: CustomTextField(
// //                   controller: context.variantTypeProvider.variantTypeCtrl,
// //                   labelText: 'Variant Type',
// //                   validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
// //                   onSave: (_) {},
// //                 ),
// //               ),
// //             ]),
// //             const SizedBox(height: defaultPadding * 2),
// //             Row(mainAxisAlignment: MainAxisAlignment.center, children: [
// //               ElevatedButton(
// //                 onPressed: () {
// //                   context.variantTypeProvider.clearFields();
// //                   Navigator.pop(context);
// //                 },
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: secondaryColor,
// //                   foregroundColor: Colors.white,
// //                 ),
// //                 child: const Text('Cancel'),
// //               ),
// //               const SizedBox(width: defaultPadding),
// //               Consumer<VariantsTypeProvider>(
// //                 builder: (_, p, __) => ElevatedButton(
// //                   onPressed: p.isSubmitting
// //                       ? null
// //                       : () async {
// //                     final ok = await p.submit();
// //                     if (!context.mounted) return;
// //                     if (ok) Navigator.pop(context);
// //                   },
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: primaryColor,
// //                     foregroundColor: Colors.white,
// //                   ),
// //                   child: p.isSubmitting
// //                       ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
// //                       : const Text('Submit'),
// //                 ),
// //               ),
// //             ]),
// //           ]),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // void showAddVariantTypeForm(BuildContext context, VariantType? item, String title) {
// //   showDialog(
// //     context: context,
// //     barrierDismissible: false,
// //     builder: (_) => AlertDialog(
// //       backgroundColor: bgColor,
// //       title: Center(child: Text(title.toUpperCase(), style: const TextStyle(color: primaryColor))),
// //       content: VariantTypeSubmitForm(variantType: item),
// //     ),
// //   ).then((_) => context.variantTypeProvider.clearFields());
// // }
//
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../models/variant_type.dart';
// import '../../../utility/constants.dart';
// import '../../../utility/extensions.dart';
// import '../../../widgets/custom_text_field.dart';
// import '../provider/variant_type_provider.dart';
//
// class VariantTypeSubmitForm extends StatelessWidget {
//   final VariantType? item;
//   const VariantTypeSubmitForm({super.key, this.item});
//
//   @override
//   Widget build(BuildContext context) {
//     // مقداردهی فرم بعد از mount
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.variantTypeProvider.setDataForUpdate(item);
//     });
//
//     final p = context.variantTypeProvider;
//
//     return SingleChildScrollView(
//       child: Form(
//         key: p.formKey,
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.35,
//           decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
//           padding: const EdgeInsets.all(defaultPadding),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(children: [
//                 Expanded(
//                   child: CustomTextField(
//                     controller: p.nameCtrl,
//                     labelText: 'Name',
//                     validator: (v) => (v==null || v.isEmpty) ? 'Required' : null,
//                     onSave: (_) {},
//                   ),
//                 ),
//                 const SizedBox(width: defaultPadding),
//                 Expanded(
//                   child: CustomTextField(
//                     controller: p.typeCtrl,
//                     labelText: 'Type',
//                     validator: (v) => (v==null || v.isEmpty) ? 'Required' : null,
//                     onSave: (_) {},
//                   ),
//                 ),
//               ]),
//               const SizedBox(height: defaultPadding * 2),
//               Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(backgroundColor: secondaryColor, foregroundColor: Colors.white),
//                   child: const Text('Cancel'),
//                 ),
//                 const SizedBox(width: defaultPadding),
//                 Consumer<VariantsTypeProvider>(
//                   builder: (_, prov, __) => ElevatedButton(
//                     onPressed: prov.isSubmitting ? null : () async {
//                       final ok = await prov.submit();
//                       if (!context.mounted) return;
//                       if (ok) Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
//                     child: prov.isSubmitting
//                         ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
//                         : const Text('Submit'),
//                   ),
//                 ),
//               ]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // امضای استاندارد (سه پارامتر)
// void showAddVariantTypeForm(BuildContext context, VariantType? item, String title) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) => AlertDialog(
//       backgroundColor: bgColor,
//       title: Center(child: Text(title.toUpperCase(), style: const TextStyle(color: primaryColor))),
//       content: VariantTypeSubmitForm(item: item),
//     ),
//   ).then((_) => context.variantTypeProvider.clearFields());
// }
//
// // برای سازگاری با کال‌های قبلی (اگر جایی با s صدا زده‌ای):
// void showAddVariantsTypeForm(BuildContext context, [VariantType? item]) {
//   final title = (item == null) ? 'Add Variant Type' : 'Edit Variant Type';
//   showAddVariantTypeForm(context, item, title);
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/variant_type.dart';
import '../../../utility/constants.dart';
import '../../../utility/extensions.dart';
import '../../../widgets/custom_text_field.dart';
import '../provider/variant_type_provider.dart';

class VariantTypeSubmitForm extends StatelessWidget {
  final VariantType? item;
  const VariantTypeSubmitForm({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    // مقداردهی فرم بعد از mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.variantTypeProvider.setDataForUpdate(item);
    });

    final p = context.variantTypeProvider;

    return SingleChildScrollView(
      child: Form(
        key: p.formKey,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.35,
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Expanded(
                  child: CustomTextField(
                    controller: p.nameCtrl,
                    labelText: 'نام',
                    validator: (v) => (v==null || v.isEmpty) ? 'اجباری' : null,
                    onSave: (_) {},
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: CustomTextField(
                    controller: p.typeCtrl,
                    labelText: 'نوع',
                    validator: (v) => (v==null || v.isEmpty) ? 'اجباری' : null,
                    onSave: (_) {},
                  ),
                ),
              ]),
              const SizedBox(height: defaultPadding * 2),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: secondaryColor, foregroundColor: Colors.white),
                  child: const Text('انصراف'),
                ),
                const SizedBox(width: defaultPadding),
                Consumer<VariantsTypeProvider>(
                  builder: (_, prov, __) => ElevatedButton(
                    onPressed: prov.isSubmitting ? null : () async {
                      final ok = await prov.submit();
                      if (!context.mounted) return;
                      if (ok) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                    child: prov.isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('ثبت'),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// امضای استاندارد (سه پارامتر)
void showAddVariantTypeForm(BuildContext context, VariantType? item, String title) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: bgColor,
      title: Center(child: Text(title.toUpperCase(), style: const TextStyle(color: primaryColor))),
      content: VariantTypeSubmitForm(item: item),
    ),
  ).then((_) => context.variantTypeProvider.clearFields());
}

// سازگاری با کال‌های قبلی
void showAddVariantsTypeForm(BuildContext context, [VariantType? item]) {
  final title = (item == null) ? 'افزودن نوع ویژگی' : 'ویرایش نوع ویژگی';
  showAddVariantTypeForm(context, item, title);
}
