// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../models/variant.dart';
// import '../../../models/variant_type.dart';
// import '../../../utility/constants.dart';
// import '../../../utility/extensions.dart';
// import '../../../widgets/custom_dropdown.dart';
// import '../../../widgets/custom_text_field.dart';
// import '../../../core/data/data_provider.dart';
//
//
// // class VariantSubmitForm extends StatelessWidget {
// //   final Variant? variant;
// //   const VariantSubmitForm({super.key, this.variant});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // مقداردهی از روی آیتم برای حالت ویرایش
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       context.variantProvider.setDataForUpdateVariant(variant);
// //     });
// //
// //     final p = context.variantProvider;
// //
// //     return SingleChildScrollView(
// //       child: Form(
// //         key: p.addVariantsFormKey,
// //         child: Container(
// //           padding: const EdgeInsets.all(defaultPadding),
// //           width: MediaQuery.of(context).size.width * 0.5,
// //           decoration: BoxDecoration(
// //             color: bgColor,
// //             borderRadius: BorderRadius.circular(12.0),
// //           ),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               const SizedBox(height: defaultPadding),
// //               Row(
// //                 children: [
// //                   // Dropdown VariantType
// //                   Expanded(
// //                     child: Consumer<DataProvider>(
// //                       builder: (context, dataProvider, child) {
// //                         // اگر در حالت ویرایش هستیم و هنوز انتخاب ست نشده، الان با لیست لودشده هیدراته کن
// //                         final vtId = variant?.variantTypeId?.sId;
// //                         if (p.selectedVariantType == null && vtId != null && dataProvider.variantTypes.isNotEmpty) {
// //                           p.hydrateSelectedType(vtId);
// //                         }
// //
// //                         final List<VariantType> items =
// //                         List.from(dataProvider.variantTypes)
// //                           ..sort((a, b) =>
// //                               (a.name ?? '').compareTo(b.name ?? ''));
// //
// //                         return CustomDropdown<VariantType>(
// //                           initialValue: p.selectedVariantType,
// //                           items: items,
// //                           hintText: 'Select Variant Type',
// //                           displayItem: (VariantType it) => it.name ?? '',
// //                           onChanged: (newValue) {
// //                             p.selectedVariantType = newValue;
// //                             p.updateUI();
// //                           },
// //                           // در حالت Add اجباریست؛ در حالت Edit اختیاری (اگر کاربر تغییر نداد)
// //                           validator: (value) {
// //                             final isEditing = p.variantForUpdate != null;
// //                             if (!isEditing && value == null) {
// //                               return 'Please select a Variant Type';
// //                             }
// //                             return null;
// //                           },
// //                         );
// //                       },
// //                     ),
// //                   ),
// //                   const SizedBox(width: defaultPadding),
// //                   // TextField Variant Name
// //                   Expanded(
// //                     child: CustomTextField(
// //                       controller: p.variantCtrl,
// //                       labelText: 'Variant Name',
// //                       onSave: (_) {},
// //                       validator: (value) =>
// //                       (value == null || value.isEmpty)
// //                           ? 'Please enter a variant name'
// //                           : null,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: defaultPadding * 2),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       foregroundColor: Colors.white,
// //                       backgroundColor: secondaryColor,
// //                     ),
// //                     onPressed: () => Navigator.of(context).pop(),
// //                     child: const Text('Cancel'),
// //                   ),
// //                   const SizedBox(width: defaultPadding),
// //                   ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       foregroundColor: Colors.white,
// //                       backgroundColor: primaryColor,
// //                     ),
// //                     onPressed: () async {
// //                       await p.submitVariant();
// //                       if (!context.mounted) return;
// //                       Navigator.of(context).pop();
// //                     },
// //                     child: const Text('Submit'),
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
// // // امضای دو آرگومانی مطابق صفحه‌ی فعلی
// // void showAddVariantForm(BuildContext context, Variant? variant) async {
// //   // اطمینان از اینکه VariantTypes قبل از باز شدن دیالوگ لود شده‌اند (مثل پوستر/کتگوری)
// //   if (context.read<DataProvider>().variantTypes.isEmpty) {
// //     await context.read<DataProvider>().getAllVariantTypes();
// //   }
// //
// //   final title = (variant == null) ? 'Add Variant' : 'Edit Variant';
// //   showDialog(
// //     context: context,
// //     builder: (BuildContext context) {
// //       return AlertDialog(
// //         backgroundColor: bgColor,
// //         title: Center(
// //           child: Text(
// //             title.toUpperCase(),
// //             style: const TextStyle(color: primaryColor),
// //           ),
// //         ),
// //         content: VariantSubmitForm(variant: variant),
// //       );
// //     },
// //   ).then((_) => context.variantProvider.clearFields());
// // }
// //
//
//
// // lib/screens/variants/components/add_variant_form.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../core/data/data_provider.dart';
// import '../../../models/variant.dart';
// import '../../../models/variant_type.dart';
// import '../../../utility/constants.dart';
// import '../../../utility/extensions.dart';
// import '../../../widgets/custom_dropdown.dart';
// import '../../../widgets/custom_text_field.dart';
// import '../provider/variant_provider.dart';
//
// class VariantSubmitForm extends StatelessWidget {
//   final Variant? variant;
//   const VariantSubmitForm({super.key, this.variant});
//
//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.variantProvider.setDataForUpdateVariant(variant);
//     });
//
//     final p = context.variantProvider;
//
//     return SingleChildScrollView(
//       child: Form(
//         key: p.addVariantsFormKey,
//         child: Container(
//           padding: const EdgeInsets.all(defaultPadding),
//           width: MediaQuery.of(context).size.width * 0.5,
//           decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: defaultPadding),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Consumer<DataProvider>(
//                       builder: (context, dataProvider, child) {
//                         final vtId = variant?.variantTypeId?.sId;
//                         if (p.selectedVariantType == null && vtId != null && dataProvider.variantTypes.isNotEmpty) {
//                           p.hydrateSelectedType(vtId);
//                         }
//
//                         final List<VariantType> items = List<VariantType>.from(dataProvider.variantTypes)
//                           ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
//
//                         return CustomDropdown<VariantType>(
//                           initialValue: p.selectedVariantType,
//                           items: items,
//                           hintText: 'Select Variant Type',
//                           displayItem: (VariantType it) => it.name ?? '',
//                           onChanged: (newValue) {
//                             p.selectedVariantType = newValue;
//                             p.updateUI();
//                           },
//                           validator: (value) {
//                             final isEditing = p.variantForUpdate != null;
//                             if (!isEditing && value == null) return 'Please select a Variant Type';
//                             return null;
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: defaultPadding),
//                   Expanded(
//                     child: CustomTextField(
//                       controller: p.variantCtrl,
//                       labelText: 'Variant Name',
//                       onSave: (_) {},
//                       validator: (value) =>
//                       (value == null || value.isEmpty) ? 'Please enter a variant name' : null,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: defaultPadding * 2),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.white,
//                       backgroundColor: secondaryColor,
//                     ),
//                     onPressed: () => Navigator.of(context).pop(),
//                     child: const Text('Cancel'),
//                   ),
//                   const SizedBox(width: defaultPadding),
//                   // ✅ دکمه Submit با قفل isSubmitting
//                   Consumer<VariantsProvider>(
//                     builder: (_, vp, __) => ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         backgroundColor: primaryColor,
//                       ),
//                       onPressed: vp.isSubmitting
//                           ? null
//                           : () async {
//                         await p.submitVariant();
//                         if (!context.mounted) return;
//                         Navigator.of(context).pop();
//                       },
//                       child: vp.isSubmitting
//                           ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
//                           : const Text('Submit'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ✅ barrierDismissible: false و pre-load لیست VariantTypes
// Future<void> showAddVariantForm(BuildContext context, Variant? variant) async {
//   if (context.read<DataProvider>().variantTypes.isEmpty) {
//     await context.read<DataProvider>().getAllVariantTypes();
//   }
//   final title = (variant == null) ? 'Add Variant' : 'Edit Variant';
//   showDialog(
//     context: context,
//     barrierDismissible: false, // مثل الگوی مرجع
//     builder: (BuildContext context) {
//       return AlertDialog(
//         backgroundColor: bgColor,
//         title: Center(
//           child: Text(
//             title.toUpperCase(),
//             style: const TextStyle(color: primaryColor),
//           ),
//         ),
//         content: VariantSubmitForm(variant: variant),
//       );
//     },
//   ).then((_) => context.variantProvider.clearFields());
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/variant.dart';
import '../../../models/variant_type.dart';
import '../../../utility/constants.dart';
import '../../../utility/extensions.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../core/data/data_provider.dart';

// lib/screens/variants/components/add_variant_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/variant.dart';
import '../../../models/variant_type.dart';
import '../../../utility/constants.dart';
import '../../../utility/extensions.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_text_field.dart';
import '../provider/variant_provider.dart';

class VariantSubmitForm extends StatelessWidget {
  final Variant? variant;
  const VariantSubmitForm({super.key, this.variant});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.variantProvider.setDataForUpdateVariant(variant);
    });

    final p = context.variantProvider;

    return SingleChildScrollView(
      child: Form(
        key: p.addVariantsFormKey,
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          width: MediaQuery.of(context).size.width * 0.5,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: Selector<DataProvider, List<VariantType>>(
                      selector: (_, dp) => dp.variantTypes,
                      builder: (context, types, child) {
                        final vtId = variant?.variantTypeId?.sId;
                        if (p.selectedVariantType == null && vtId != null && types.isNotEmpty) {
                          p.hydrateSelectedType(vtId);
                        }

                        final List<VariantType> items = List<VariantType>.from(types)
                          ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

                        return CustomDropdown<VariantType>(
                          initialValue: p.selectedVariantType,
                          items: items,
                          hintText: 'انتخاب نوع ویژگی',
                          displayItem: (VariantType it) => it.name ?? '',
                          onChanged: (newValue) {
                            p.selectedVariantType = newValue;
                            p.updateUI();
                          },
                          validator: (value) {
                            final isEditing = p.variantForUpdate != null;
                            if (!isEditing && value == null) return 'لطفاً یک نوع ویژگی انتخاب کنید';
                            return null;
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: defaultPadding),
                  Expanded(
                    child: CustomTextField(
                      controller: p.variantCtrl,
                      labelText: 'نام ویژگی',
                      onSave: (_) {},
                      validator: (value) =>
                      (value == null || value.isEmpty) ? 'لطفاً نام ویژگی را وارد کنید' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: secondaryColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('انصراف'),
                  ),
                  const SizedBox(width: defaultPadding),
                  // ✅ دکمه Submit با قفل isSubmitting
                  Consumer<VariantsProvider>(
                    builder: (_, vp, __) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: primaryColor,
                      ),
                      onPressed: vp.isSubmitting
                          ? null
                          : () async {
                        await p.submitVariant();
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: vp.isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('ثبت'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ barrierDismissible: false و pre-load لیست VariantTypes
Future<void> showAddVariantForm(BuildContext context, Variant? variant) async {
  if (context.read<DataProvider>().variantTypes.isEmpty) {
    await context.read<DataProvider>().getAllVariantTypes();
  }
  final title = (variant == null) ? 'افزودن ویژگی' : 'ویرایش ویژگی';
  showDialog(
    context: context,
    barrierDismissible: false, // مثل الگوی مرجع
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: bgColor,
        title: Center(
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(color: primaryColor),
          ),
        ),
        content: VariantSubmitForm(variant: variant),
      );
    },
  ).then((_) => context.variantProvider.clearFields());
}
