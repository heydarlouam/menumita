// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:provider/provider.dart';
//
// import '../../../models/category.dart';
// import '../../../utility/constants.dart';
// import '../../../utility/extensions.dart';
// import '../../../widgets/category_image_card.dart';
// import '../../../widgets/custom_text_field.dart';
// import '../provider/category_provider.dart';
//
//
// class CategorySubmitForm extends StatelessWidget {
//   final Category? category;
//
//   const CategorySubmitForm({super.key, this.category});
//
//   @override
//   Widget build(BuildContext context) {
//     // تنظیم داده‌ها برای آپدیت هنگام build
//     _initializeCategoryData(context);
//
//     return SingleChildScrollView(
//       child: Form(
//         key: context.categoryProvider.addCategoryFormKey,
//         child: Container(
//           padding: EdgeInsets.all(defaultPadding),
//           width: MediaQuery.of(context).size.width * 0.3,
//           decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Gap(defaultPadding),
//               Consumer<CategoryProvider>(
//                 builder: (context, catProvider, child) {
//                   return CategoryImageCard(
//                     labelText: "Image",
//                     imageFile: catProvider.selectedImage,
//                     imageUrlForUpdateImage: category?.image,
//                     onTap: () {
//                       catProvider.pickImage();
//                     },
//                   );
//                 },
//               ),
//               Gap(defaultPadding),
//               CustomTextField(
//                 controller: context.categoryProvider.categoryNameCtrl,
//                 labelText: 'Category Name',
//                 onSave: (val) {},
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a category name';
//                   }
//                   return null;
//                 },
//               ),
//               Gap(defaultPadding * 2),
//               _buildActionButtons(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // متد برای تنظیم اولیه داده‌ها
//   void _initializeCategoryData(BuildContext context) {
//     final categoryProvider = context.categoryProvider;
//
//     // فقط در صورتی که category تغییر کرده باشد، داده‌ها را تنظیم کن
//     if (category != categoryProvider.currentEditingCategory) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         print('🔄 CategorySubmitForm init - category: ${category?.toJson()}');
//         if (category != null) {
//           print('🔄 Has valid category with ID: ${category!.sId}');
//         } else {
//           print('🔄 No category provided - creating new one');
//         }
//         categoryProvider.setDataForUpdateCategory(category);
//       });
//     }
//   }
//
//
//   Widget _buildActionButtons(BuildContext context) {
//     final provider = context.categoryProvider;
//
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             foregroundColor: Colors.white,
//             backgroundColor: secondaryColor,
//           ),
//           onPressed: () {
//             provider.clearFields();
//             Navigator.of(context).pop();
//           },
//           child: const Text('Cancel'),
//         ),
//         const Gap(defaultPadding),
//         Consumer<CategoryProvider>(
//           builder: (context, p, _) {
//             final isBusy = p.isSubmitting;
//             return ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 backgroundColor: primaryColor,
//               ),
//               onPressed: isBusy
//                   ? null
//                   : () async {
//                 // اعتبارسنجی فرم
//                 final form = provider.addCategoryFormKey.currentState;
//                 if (form == null) return;
//                 if (!form.validate()) return;
//                 form.save();
//
//                 final ok = await provider.submitCategory(); // ✅ نتیجه را بگیر
//                 if (!context.mounted) return;
//                 if (ok) Navigator.of(context).pop(); // ✅ بستن دیالوگ روی موفقیت
//               },
//               child: isBusy
//                   ? const SizedBox(
//                   height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
//                   : const Text('Submit'),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//
// }
//
// // تابع showAddCategoryForm بدون تغییر باقی می‌ماند
// void showAddCategoryForm(
//     BuildContext context, Category? category, String buttonText) {
//   showDialog(
//     context: context,
//     barrierDismissible: false, // ⬅️ اضافه شود
//     builder: (BuildContext context) {
//       return AlertDialog(
//         backgroundColor: bgColor,
//         title: Center(
//           child: Text(
//             buttonText.toUpperCase(),
//             style: TextStyle(color: primaryColor),
//           ),
//         ),
//         content: CategorySubmitForm(category: category),
//       );
//     },
//   ).then((val) {
//     context.categoryProvider.clearFields();
//   });
// }

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../models/category.dart';
import '../../../utility/constants.dart';
import '../../../utility/extensions.dart';
import '../../../widgets/category_image_card.dart';
import '../../../widgets/custom_text_field.dart';
import '../provider/category_provider.dart';

class CategorySubmitForm extends StatelessWidget {
  final Category? category;

  const CategorySubmitForm({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    // تنظیم داده‌ها برای آپدیت هنگام build
    _initializeCategoryData(context);

    return SingleChildScrollView(
      child: Form(
        key: context.categoryProvider.addCategoryFormKey,
        child: Container(
          padding: EdgeInsets.all(defaultPadding),
          width: MediaQuery.of(context).size.width * 0.3,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(defaultPadding),
              Consumer<CategoryProvider>(
                builder: (context, catProvider, child) {
                  return CategoryImageCard(
                    labelText: "تصویر",
                    imageFile: catProvider.selectedImage,
                    imageUrlForUpdateImage: category?.image,
                    onTap: () {
                      catProvider.pickImage();
                    },
                  );
                },
              ),
              Gap(defaultPadding),
              CustomTextField(
                controller: context.categoryProvider.categoryNameCtrl,
                labelText: 'نام دسته‌بندی',
                onSave: (val) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً نام دسته‌بندی را وارد کنید';
                  }
                  return null;
                },
              ),
              Gap(defaultPadding * 2),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // متد برای تنظیم اولیه داده‌ها
  void _initializeCategoryData(BuildContext context) {
    final categoryProvider = context.categoryProvider;

    // فقط در صورتی که category تغییر کرده باشد، داده‌ها را تنظیم کن
    if (category != categoryProvider.currentEditingCategory) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('🔄 CategorySubmitForm init - category: ${category?.toJson()}');
        if (category != null) {
          print('🔄 Has valid category with ID: ${category!.sId}');
        } else {
          print('🔄 No category provided - creating new one');
        }
        categoryProvider.setDataForUpdateCategory(category);
      });
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    final provider = context.categoryProvider;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: secondaryColor,
          ),
          onPressed: () {
            provider.clearFields();
            Navigator.of(context).pop();
          },
          child: const Text('انصراف'),
        ),
        const Gap(defaultPadding),
        Consumer<CategoryProvider>(
          builder: (context, p, _) {
            final isBusy = p.isSubmitting;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
              ),
              onPressed: isBusy
                  ? null
                  : () async {
                // اعتبارسنجی فرم
                final form = provider.addCategoryFormKey.currentState;
                if (form == null) return;
                if (!form.validate()) return;
                form.save();

                final ok = await provider.submitCategory(); // ✅ نتیجه را بگیر
                if (!context.mounted) return;
                if (ok) Navigator.of(context).pop(); // ✅ بستن دیالوگ روی موفقیت
              },
              child: isBusy
                  ? const SizedBox(
                  height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('ثبت'),
            );
          },
        ),
      ],
    );
  }
}

// تابع showAddCategoryForm بدون تغییر باقی می‌ماند
void showAddCategoryForm(
    BuildContext context, Category? category, String buttonText) {
  showDialog(
    context: context,
    barrierDismissible: false, // ⬅️ اضافه شود
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: bgColor,
        title: Center(
          child: Text(
            buttonText.toUpperCase(),
            style: TextStyle(color: primaryColor),
          ),
        ),
        content: CategorySubmitForm(category: category),
      );
    },
  ).then((val) {
    context.categoryProvider.clearFields();
  });
}
