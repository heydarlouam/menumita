import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../models/brand.dart';
import '../../../models/sub_category.dart';
import '../../../utility/constants.dart';
import '../../../utility/extensions.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_text_field.dart';
import '../provider/brand_provider.dart';

class BrandSubmitForm extends StatefulWidget {
  final Brand? brand;

  const BrandSubmitForm({super.key, this.brand});

  @override
  State<BrandSubmitForm> createState() => _BrandSubmitFormState();
}

class _BrandSubmitFormState extends State<BrandSubmitForm> {
  @override
  void initState() {
    super.initState();

    // تنظیم داده‌ها برای ویرایش یا ایجاد جدید
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.brandProvider.setDataForUpdateBrand(widget.brand);
    });
  }

  @override
  Widget build(BuildContext context) {
    final brandProvider = context.brandProvider;

    return SingleChildScrollView(
      child: Form(
        key: brandProvider.addBrandFormKey,
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

              // ---------- Dropdown: SubCategory ----------
              Consumer<BrandProvider>(
                builder: (context, p, child) {
                  final subCategories = context.dataProvider.subCategories;

                  return CustomDropdown<SubCategory>(
                    hintText: 'Sub Category',
                    initialValue: p.selectedSubCategory,
                    items: subCategories,
                    displayItem: (sub) => sub.name ?? '-',
                    onChanged: (val) {
                      p.selectedSubCategory = val;
                      p.updateUi();
                    },
                    validator: (val) =>
                    val == null ? 'Please select a sub category' : null,
                  );
                },
              ),

              const Gap(defaultPadding),

              // ---------- Text Field: Brand Name ----------
              CustomTextField(
                controller: brandProvider.brandNameCtrl,
                labelText: 'Brand Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a brand name';
                  }
                  return null;
                },
                onSave: (_) {}, // ✅ اضافه شد
              ),

              const Gap(defaultPadding * 2),

              // ---------- Buttons ----------
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
        // Cancel
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: secondaryColor,
          ),
          onPressed: () {
            context.brandProvider.clearFields();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        const Gap(defaultPadding),

        // Submit
        Consumer<BrandProvider>(
          builder: (context, provider, _) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
              ),
              onPressed: provider.isSubmitting
                  ? null
                  : () async {
                final form = provider.addBrandFormKey.currentState;
                if (form == null) return;
                if (!form.validate()) return;
                form.save();

                final ok = await provider.submitBrand();
                if (!mounted) return;
                if (ok) Navigator.of(context).pop();
              },
              child: provider.isSubmitting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Submit'),
            );
          },
        ),
      ],
    );
  }
}

// دیالوگ Add/Edit
void showAddBrandForm(BuildContext context, Brand? brand) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: bgColor,
        title: Center(
          child: Text(
            brand == null ? 'ADD BRAND' : 'EDIT BRAND',
            style: const TextStyle(color: primaryColor),
          ),
        ),
        content: BrandSubmitForm(brand: brand),
      );
    },
  ).then((_) {
    context.brandProvider.clearFields();
  });
}

// سازگاری با کدهای قدیمی
void showBrandForm(BuildContext context, Brand? brand) =>
    showAddBrandForm(context, brand);
