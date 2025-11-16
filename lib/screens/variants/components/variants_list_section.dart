

import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/variant.dart';
import '../../../utility/constants.dart';
import 'add_variant_form.dart';

class VariantsListSection extends StatelessWidget {
  const VariantsListSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // لیست ویژگی‌ها فقط هنگام تغییر خودش ری‌بیلد می‌شود

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),

      width: double.infinity,
      child: LayoutBuilder(
        builder: (_, cons) {
          final w = cons.maxWidth; // عرض در دسترس کارت

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,      // 👈 اگر ستون‌ها زیاد شدند، اسکرول افقی
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: w), // 👈 حداقل عرض = کل عرض کارت
              child: SingleChildScrollView(            // 👈 اسکرول عمودی جدول
                child: Selector<DataProvider, List<Variant>>(
                  selector: (_, dp) => dp.variants,
                  builder: (_, items, __) => DataTable(
                    columnSpacing: defaultPadding,
                    columns: const [
                      DataColumn(label: Text('نام ویژگی')),
                      DataColumn(label: Text('نوع ویژگی')),
                      DataColumn(label: Text('ویرایش')),
                      DataColumn(label: Text('حذف')),
                    ],
                    rows: List.generate(
                      items.length,
                          (i) {
                        final Variant item = items[i];
                        return DataRow(
                          cells: [
                            DataCell(Text(item.name ?? '')),
                            DataCell(Text(item.variantTypeId?.name ?? '')),
                            DataCell(
                              IconButton(
                                onPressed: () async {
                                  if (await UserSaveHelper.isExpired()) {
                                    DialogHelper.showExpiredDialog(context);
                                    return;
                                  }
                                  showAddVariantForm(context, item);
                                },
                                icon: const Icon(Icons.edit, color: Colors.white),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                onPressed: () async {
                                  if (await UserSaveHelper.isExpired()) {
                                    DialogHelper.showExpiredDialog(context);
                                    return;
                                  }
                                  context.variantProvider.deleteVariant(item);
                                },
                                icon: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),

    );
  }
}
