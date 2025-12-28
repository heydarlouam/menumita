// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:provider/provider.dart';
//
// import '../../../models/category.dart';
// import '../../../models/coupon.dart';
// import '../../../models/product.dart';
// import '../../../models/sub_category.dart';
// import '../../../utility/constants.dart';
// import '../../../utility/extensions.dart';
// import '../../../widgets/custom_date_picker.dart';
// import '../../../widgets/custom_dropdown.dart';
// import '../../../widgets/custom_text_field.dart';
// import '../../../widgets/submission_spinner.dart';
// import '../provider/coupon_code_provider.dart';
//
//
// class CouponSubmitForm extends StatefulWidget {
//   final Coupon? coupon;
//   const CouponSubmitForm({Key? key, this.coupon}) : super(key: key);
//
//   @override
//   State<CouponSubmitForm> createState() => _CouponSubmitFormState();
// }
//
// class _CouponSubmitFormState extends State<CouponSubmitForm> {
//   @override
//   void initState() {
//     super.initState();
//     // یک‌بار مقداردهی
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.couponCodeProvider.setDataForUpdateCoupon(widget.coupon);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.couponCodeProvider;
//
//     return SingleChildScrollView(
//       child: Form(
//         key: provider.addCouponFormKey,
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.7,
//           padding: const EdgeInsets.all(defaultPadding),
//           decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Gap(defaultPadding),
//               Row(
//                 children: [
//                   Expanded(
//                     child: CustomTextField(
//                       controller: provider.couponCodeCtrl,
//                       labelText: 'کد کوپن',
//                       onSave: (_) {},
//                       validator: (v) {
//                         if (v == null || v.isEmpty) return 'لطفاً کد کوپن را وارد کنید';
//                         if (v.length < 3) return 'کد کوپن باید حداقل ۳ کاراکتر باشد';
//                         return null;
//                       },
//                     ),
//                   ),
//                   Expanded(
//                     child: Consumer<CouponCodeProvider>(
//                       builder: (_, p, __) {
//                         return CustomDropdown(
//                           key: GlobalKey(),
//                           hintText: 'نوع تخفیف',
//                           items: const ['fixed', 'percentage'],
//                           initialValue: p.selectedDiscountType,
//                           onChanged: (val) {
//                             p.selectedDiscountType = val ?? 'fixed';
//                             p.updateUi();
//                           },
//                           validator: (value) => (value == null || value.isEmpty)
//                               ? 'لطفاً نوع تخفیف را انتخاب کنید'
//                               : null,
//                           // فقط متن نمایش فارسی می‌شود؛ مقادیر داخلی همان 'fixed' و 'percentage' می‌ماند
//                           displayItem: (val) => val == 'percentage' ? 'درصدی' : 'مبلغ ثابت',
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const Gap(defaultPadding),
//               Row(
//                 children: [
//                   Expanded(
//                     child: CustomTextField
//                       (
//                       controller: provider.discountAmountCtrl,
//                       labelText: 'مقدار تخفیف',
//                       inputType: const TextInputType.numberWithOptions(decimal: true),
//                       onSave: (_) {},
//                       validator: (v) {
//                         if (v == null || v.isEmpty) return 'لطفاً مقدار تخفیف را وارد کنید';
//                         final d = double.tryParse(v);
//                         if (d == null) return 'لطفاً یک عدد معتبر وارد کنید';
//                         if (d <= 0) return 'مقدار تخفیف باید بزرگ‌تر از صفر باشد';
//                         if (provider.selectedDiscountType == 'percentage' && d > 100) {
//                           return 'تخفیف درصدی نمی‌تواند بیش از ۱۰۰٪ باشد';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   Expanded(
//                     child: CustomTextField(
//                       controller: provider.minimumPurchaseAmountCtrl,
//                       labelText: 'حداقل مبلغ خرید (اختیاری)',
//                       inputType: const TextInputType.numberWithOptions(decimal: true),
//                       onSave: (_) {},
//                       validator: (v) {
//                         if (v != null && v.isNotEmpty) {
//                           final d = double.tryParse(v);
//                           if (d == null) return 'لطفاً یک عدد معتبر وارد کنید';
//                           if (d < 0) return 'مقدار نمی‌تواند منفی باشد';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const Gap(defaultPadding),
//               Row(
//                 children: [
//                   Expanded(
//                     child: CustomDatePicker(
//                       labelText: 'تاریخ پایان',
//                       controller: provider.endDateCtrl,
//                       initialDate: DateTime.now().add(const Duration(days: 30)),
//                       firstDate: DateTime.now(),
//                       lastDate: DateTime(2100),
//                       onDateSelected: (_) {},
//                     ),
//                   ),
//                   Expanded(
//                     child: Consumer<CouponCodeProvider>(
//                       builder: (_, p, __) {
//                         return CustomDropdown(
//                           key: GlobalKey(),
//                           hintText: 'وضعیت',
//                           initialValue: p.selectedCouponStatus,
//                           items: const ['active', 'inactive'],
//                           displayItem: (val) => val == 'inactive' ? 'غیرفعال' : 'فعال',
//                           onChanged: (val) {
//                             p.selectedCouponStatus = val ?? 'active';
//                             p.updateUi();
//                           },
//                           validator: (v) => (v == null || v.isEmpty)
//                               ? 'لطفاً وضعیت را انتخاب کنید'
//                               : null,
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const Gap(defaultPadding),
//               Consumer<CouponCodeProvider>(
//                 builder: (context, p, _) {
//                   return Column(
//                     children: [
//                       Text(
//                         'محدودیت‌ها (اختیاری - برای اعمال روی تمام محصولات، همه را خالی بگذارید)',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey[700],
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(child: _categoryDropdown(context, p)),
//                           Expanded(child: _subCategoryDropdown(context, p)),
//                           Expanded(child: _productDropdown(context, p)),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               ),
//               const Gap(defaultPadding * 2),
//               Consumer<CouponCodeProvider>(
//                 builder: (_, p, __) {
//                   return Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           foregroundColor: Colors.white,
//                           backgroundColor: Colors.grey,
//                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                         ),
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: const Text('انصراف'),
//                       ),
//                       const SizedBox(width: defaultPadding),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           foregroundColor: Colors.white,
//                           backgroundColor: primaryColor,
//                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                         ),
//                         onPressed: () async {
//                           if (p.isSubmitting) return;
//                           final form = p.addCouponFormKey.currentState;
//                           if (form == null) return;
//                           if (!form.validate()) return;
//                           form.save();
//
//                           final ok = await p.submitCoupon();
//                           if (!context.mounted) return;
//                           if (ok) Navigator.of(context).pop();
//                         },
//                         child: AnimatedSwitcher(
//                           duration: const Duration(milliseconds: 200),
//                           transitionBuilder: (child, anim) =>
//                               FadeTransition(opacity: anim, child: child),
//                           child: p.isSubmitting
//                               ? const SubmissionSpinner(
//                                   key: ValueKey('coupon_loading'),
//                                 )
//                               : Text(
//                                   widget.coupon != null ? 'بروزرسانی کوپن' : 'ایجاد کوپن',
//                                   key: const ValueKey('coupon_submit_text'),
//                                   style: const TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _categoryDropdown(BuildContext context, CouponCodeProvider p) {
//     final list = List<Category>.from(context.dataProvider.categories)
//       ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
//
//     return CustomDropdown<Category>(
//       initialValue: p.selectedCategory,
//       hintText: 'انتخاب دسته‌بندی',
//       items: list,
//       displayItem: (c) => c.name ?? 'بدون دسته‌بندی',
//       onChanged: (val) {
//         p.selectedCategory = val;
//         p.selectedSubCategory = null;
//         p.selectedProduct = null;
//         p.updateUi();
//       },
//     );
//   }
//
//   Widget _subCategoryDropdown(BuildContext context, CouponCodeProvider p) {
//     final list = List<SubCategory>.from(context.dataProvider.subCategories)
//       ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
//
//     return CustomDropdown<SubCategory>(
//       initialValue: p.selectedSubCategory,
//       hintText: 'انتخاب زیر‌دسته',
//       items: list,
//       displayItem: (s) => s.name ?? 'بدون زیر‌دسته',
//       onChanged: (val) {
//         p.selectedSubCategory = val;
//         p.selectedCategory = null;
//         p.selectedProduct = null;
//         p.updateUi();
//       },
//     );
//   }
//
//   Widget _productDropdown(BuildContext context, CouponCodeProvider p) {
//     final list = List<Product>.from(context.dataProvider.products)
//       ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
//
//     return CustomDropdown<Product>(
//       initialValue: p.selectedProduct,
//       hintText: 'انتخاب محصول',
//       items: list,
//       displayItem: (pr) => pr.name ?? 'بدون محصول',
//       onChanged: (val) {
//         p.selectedProduct = val;
//         p.selectedCategory = null;
//         p.selectedSubCategory = null;
//         p.updateUi();
//       },
//     );
//   }
// }
//
// // Popup helper بدون تغییر ظاهر
// void showAddCouponForm(BuildContext context, Coupon? coupon) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         backgroundColor: bgColor,
//         title: Center(
//           child: Text(
//             coupon != null ? 'بروزرسانی کوپن' : 'ایجاد کوپن جدید',
//             style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
//           ),
//         ),
//         content: CouponSubmitForm(coupon: coupon),
//       );
//     },
//   ).then((_) {
//     context.couponCodeProvider.clearFields();
//   });
// }


import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../models/category.dart';
import '../../../models/coupon.dart';
import '../../../models/product.dart';
import '../../../models/sub_category.dart';
import '../../../utility/constants.dart';
import '../../../utility/extensions.dart';
import '../../../widgets/custom_date_picker.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/submission_spinner.dart';
import '../provider/coupon_code_provider.dart';

class CouponSubmitForm extends StatefulWidget {
  final Coupon? coupon;
  const CouponSubmitForm({Key? key, this.coupon}) : super(key: key);

  @override
  State<CouponSubmitForm> createState() => _CouponSubmitFormState();
}

class _CouponSubmitFormState extends State<CouponSubmitForm> {
  @override
  void initState() {
    super.initState();
    // یک‌بار مقداردهی
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.couponCodeProvider.setDataForUpdateCoupon(widget.coupon);
    });
  }

  // ---------- Responsive helpers ----------
  Widget _responsiveWrap2(List<Widget> children) {
    return LayoutBuilder(
      builder: (_, c) {
        final w = c.maxWidth;
        final isMobile = w < 600;
        final itemW = isMobile ? w : (w - defaultPadding) / 2;

        return Wrap(
          spacing: defaultPadding,
          runSpacing: defaultPadding,
          children: [
            for (final ch in children) SizedBox(width: itemW, child: ch),
          ],
        );
      },
    );
  }

  Widget _responsiveWrap3(List<Widget> children) {
    return LayoutBuilder(
      builder: (_, c) {
        final w = c.maxWidth;
        final cols = w < 600 ? 1 : (w < 1024 ? 2 : 3);
        final itemW = (w - (cols - 1) * defaultPadding) / cols;

        return Wrap(
          spacing: defaultPadding,
          runSpacing: defaultPadding,
          children: [
            for (final ch in children) SizedBox(width: itemW, child: ch),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.couponCodeProvider;

    final screenW = MediaQuery.sizeOf(context).width;

    // عرض فرم بر اساس دستگاه
    final targetW = screenW < 600
        ? screenW * 0.96 // موبایل
        : screenW < 1024
        ? screenW * 0.85 // تبلت
        : screenW * 0.70; // دسکتاپ

    final formW = math.min(targetW, 1100.0); // سقف عرض برای دسکتاپ‌های خیلی بزرگ

    return SingleChildScrollView(
      child: Form(
        key: p.addCouponFormKey,
        child: Container(
          width: formW,
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(defaultPadding),

              // --- Row 1 => Responsive (code + type) ---
              _responsiveWrap2([
                CustomTextField(
                  controller: p.couponCodeCtrl,
                  labelText: 'کد کوپن',
                  onSave: (_) {},
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'لطفاً کد کوپن را وارد کنید';
                    if (v.length < 3) return 'کد کوپن باید حداقل ۳ کاراکتر باشد';
                    return null;
                  },
                ),
                Consumer<CouponCodeProvider>(
                  builder: (_, prov, __) {
                    return CustomDropdown<String>(
                      hintText: 'نوع تخفیف',
                      items: const ['fixed', 'percentage'],
                      initialValue: prov.selectedDiscountType,
                      onChanged: (val) {
                        prov.selectedDiscountType = val ?? 'fixed';
                        prov.updateUi();
                      },
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'لطفاً نوع تخفیف را انتخاب کنید'
                          : null,
                      displayItem: (val) => val == 'percentage' ? 'درصدی' : 'مبلغ ثابت',
                    );
                  },
                ),
              ]),

              const Gap(defaultPadding),

              // --- Row 2 => Responsive (discount + min purchase) ---
              _responsiveWrap2([
                CustomTextField(
                  controller: p.discountAmountCtrl,
                  labelText: 'مقدار تخفیف',
                  inputType: const TextInputType.numberWithOptions(decimal: true),
                  onSave: (_) {},
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'لطفاً مقدار تخفیف را وارد کنید';
                    final d = double.tryParse(v);
                    if (d == null) return 'لطفاً یک عدد معتبر وارد کنید';
                    if (d <= 0) return 'مقدار تخفیف باید بزرگ‌تر از صفر باشد';
                    if (p.selectedDiscountType == 'percentage' && d > 100) {
                      return 'تخفیف درصدی نمی‌تواند بیش از ۱۰۰٪ باشد';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: p.minimumPurchaseAmountCtrl,
                  labelText: 'حداقل مبلغ خرید (اختیاری)',
                  inputType: const TextInputType.numberWithOptions(decimal: true),
                  onSave: (_) {},
                  validator: (v) {
                    if (v != null && v.isNotEmpty) {
                      final d = double.tryParse(v);
                      if (d == null) return 'لطفاً یک عدد معتبر وارد کنید';
                      if (d < 0) return 'مقدار نمی‌تواند منفی باشد';
                    }
                    return null;
                  },
                ),
              ]),

              const Gap(defaultPadding),

              // --- Row 3 => Responsive (end date + status) ---
              _responsiveWrap2([
                CustomDatePicker(
                  labelText: 'تاریخ پایان',
                  controller: p.endDateCtrl,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  onDateSelected: (_) {},
                ),
                Consumer<CouponCodeProvider>(
                  builder: (_, prov, __) {
                    return CustomDropdown<String>(
                      hintText: 'وضعیت',
                      initialValue: prov.selectedCouponStatus,
                      items: const ['active', 'inactive'],
                      displayItem: (val) => val == 'inactive' ? 'غیرفعال' : 'فعال',
                      onChanged: (val) {
                        prov.selectedCouponStatus = val ?? 'active';
                        prov.updateUi();
                      },
                      validator: (v) =>
                      (v == null || v.isEmpty) ? 'لطفاً وضعیت را انتخاب کنید' : null,
                    );
                  },
                ),
              ]),

              const Gap(defaultPadding),

              // --- محدودیت‌ها (1/2/3 ستونه ریسپانسیو) ---
              Consumer<CouponCodeProvider>(
                builder: (context, prov, _) {
                  return Column(
                    children: [
                      Text(
                        'محدودیت‌ها (اختیاری - برای اعمال روی تمام محصولات، همه را خالی بگذارید)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _responsiveWrap3([
                        _categoryDropdown(context, prov),
                        _subCategoryDropdown(context, prov),
                        _productDropdown(context, prov),
                      ]),
                    ],
                  );
                },
              ),

              const Gap(defaultPadding * 2),

              // --- Buttons (ریسپانسیو: روی موبایل زیر هم) ---
              Consumer<CouponCodeProvider>(
                builder: (_, prov, __) {
                  return Wrap(
                    spacing: defaultPadding,
                    runSpacing: defaultPadding,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('انصراف'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () async {
                          if (prov.isSubmitting) return;

                          final form = prov.addCouponFormKey.currentState;
                          if (form == null) return;
                          if (!form.validate()) return;
                          form.save();

                          final ok = await prov.submitCoupon();
                          if (!context.mounted) return;
                          if (ok) Navigator.of(context).pop();
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: prov.isSubmitting
                              ? const SubmissionSpinner(
                            key: ValueKey('coupon_loading'),
                          )
                              : Text(
                            widget.coupon != null ? 'بروزرسانی کوپن' : 'ایجاد کوپن',
                            key: const ValueKey('coupon_submit_text'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryDropdown(BuildContext context, CouponCodeProvider p) {
    final list = List<Category>.from(context.dataProvider.categories)
      ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

    return CustomDropdown<Category>(
      initialValue: p.selectedCategory,
      hintText: 'انتخاب دسته‌بندی',
      items: list,
      displayItem: (c) => c.name ?? 'بدون دسته‌بندی',
      onChanged: (val) {
        p.selectedCategory = val;
        p.selectedSubCategory = null;
        p.selectedProduct = null;
        p.updateUi();
      },
    );
  }

  Widget _subCategoryDropdown(BuildContext context, CouponCodeProvider p) {
    final list = List<SubCategory>.from(context.dataProvider.subCategories)
      ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

    return CustomDropdown<SubCategory>(
      initialValue: p.selectedSubCategory,
      hintText: 'انتخاب زیر‌دسته',
      items: list,
      displayItem: (s) => s.name ?? 'بدون زیر‌دسته',
      onChanged: (val) {
        p.selectedSubCategory = val;
        p.selectedCategory = null;
        p.selectedProduct = null;
        p.updateUi();
      },
    );
  }

  Widget _productDropdown(BuildContext context, CouponCodeProvider p) {
    final list = List<Product>.from(context.dataProvider.products)
      ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

    return CustomDropdown<Product>(
      initialValue: p.selectedProduct,
      hintText: 'انتخاب محصول',
      items: list,
      displayItem: (pr) => pr.name ?? 'بدون محصول',
      onChanged: (val) {
        p.selectedProduct = val;
        p.selectedCategory = null;
        p.selectedSubCategory = null;
        p.updateUi();
      },
    );
  }
}

// Popup helper (ریسپانسیو برای موبایل هم insetPadding بهتره)
void showAddCouponForm(BuildContext context, Coupon? coupon) {
  final w = MediaQuery.sizeOf(context).width;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: bgColor,
        insetPadding: EdgeInsets.symmetric(
          horizontal: w < 600 ? 12 : 40,
          vertical: 24,
        ),
        title: Center(
          child: Text(
            coupon != null ? 'بروزرسانی کوپن' : 'ایجاد کوپن جدید',
            style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        content: CouponSubmitForm(coupon: coupon),
      );
    },
  ).then((_) {
    context.couponCodeProvider.clearFields();
  });
}
