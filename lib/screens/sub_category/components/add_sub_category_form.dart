

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../models/category.dart';
import '../../../models/sub_category.dart';
import '../../../utility/constants.dart';
import '../../../utility/extensions.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_text_field.dart';
import '../provider/sub_category_provider.dart';

class SubCategorySubmitForm extends StatefulWidget {
  final SubCategory? subCategory;

  const SubCategorySubmitForm({super.key, this.subCategory});

  @override
  State<SubCategorySubmitForm> createState() => _SubCategorySubmitFormState();
}

class _SubCategorySubmitFormState extends State<SubCategorySubmitForm> {
  @override
  void initState() {
    super.initState();
    // تنظیم اولیه فرم برای حالت ویرایش/ایجاد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.subCategoryProvider.setDataForUpdateSubCategory(widget.subCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: context.subCategoryProvider.addSubCategoryFormKey,
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          width: MediaQuery.of(context).size.width * 0.3,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(defaultPadding),

              // ---------- Dropdown: Category ----------
              Row(
                children: [
                  Expanded(
                    child: Consumer<SubCategoryProvider>(
                      builder: (context, subCatProvider, child) {
                        // لیست کتگوری‌ها مرتب شود (اختیاری)
                        final List<Category> sorted = List.from(context.dataProvider.categories)
                          ..sort((a, b) => (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));

                        return CustomDropdown<Category>(
                          hintText: 'دسته‌بندی',                       // ← ترجمه شد
                          initialValue: subCatProvider.selectedCategory,
                          items: sorted,
                          displayItem: (c) => c.name ?? '-',
                          onChanged: (val) {
                            subCatProvider.selectedCategory = val;
                            subCatProvider.updateUi();
                          },
                          validator: (val) {
                            if (val == null) return 'لطفاً یک دسته‌بندی انتخاب کنید';
                            return null;
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              const Gap(defaultPadding),

              // ---------- TextField: SubCategory Name ----------
              CustomTextField(
                controller: context.subCategoryProvider.subCategoryNameCtrl,
                labelText: 'نام زیر‌دسته',                             // ← ترجمه شد
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً نام زیر‌دسته را وارد کنید';
                  }
                  return null;
                },
                onSave: (_) {},
              ),

              const Gap(defaultPadding * 2),

              // ---------- Action Buttons ----------
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: secondaryColor,
          ),
          onPressed: () {
            context.subCategoryProvider.clearFields();
            Navigator.of(context).pop();
          },
          child: const Text('انصراف'),                                  // ← ترجمه شد
        ),
        const Gap(defaultPadding),
        Consumer<SubCategoryProvider>(
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
                final form = p.addSubCategoryFormKey.currentState;
                if (form == null) return;
                if (!form.validate()) return;
                form.save();

                final ok = await p.submitSubCategory();
                if (!context.mounted) return;
                if (ok) Navigator.of(context).pop();
              },
              child: isBusy
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('ثبت'),                                   // ← ترجمه شد
            );
          },
        ),
      ],
    );
  }
}

// نمایش دیالوگ افزودن/ویرایش SubCategory
void showAddSubCategoryForm(BuildContext context, SubCategory? subCategory) {
  showDialog(
    context: context,
    barrierDismissible: false, // اختیاری: جلوگیری از بستن با کلیک بیرون
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: SubCategorySubmitForm(subCategory: subCategory),
      );
    },
  );
}
