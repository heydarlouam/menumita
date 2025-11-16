
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
