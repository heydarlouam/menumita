

import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/variant_type.dart';
import '../../../utility/constants.dart';
import '../../../utility/extensions.dart';
import 'add_variant_type_form.dart';

class VariantsTypeListSection extends StatelessWidget {
  const VariantsTypeListSection({super.key});

  @override
  Widget build(BuildContext context) {
    // لیست نوع ویژگی فقط هنگام تغییر خودش ری‌بیلد می‌شود

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      // width: double.infinity,
      // child: DataTable(
      //   columnSpacing: defaultPadding,
      //   columns: const [
      //     DataColumn(label: Text('نام ویژگی')),
      //     DataColumn(label: Text('نوع ویژگی')),
      //     DataColumn(label: Text('ویرایش')),
      //     DataColumn(label: Text('حذف')),
      //   ],
      //   rows: List.generate(
      //     data.variantTypes.length,
      //         (i) {
      //       final VariantType item = data.variantTypes[i];
      //       return DataRow(
      //         cells: [
      //           DataCell(Text(item.name ?? '')),
      //           DataCell(Text(item.type ?? '')),
      //           DataCell(
      //             IconButton(
      //               onPressed: () async {
      //                 if (await UserSaveHelper.isExpired()) {
      //                   DialogHelper.showExpiredDialog(context);
      //                   return;
      //                 }
      //                 showAddVariantTypeForm(
      //                   context,
      //                   item,
      //                   'ویرایش نوع ویژگی',
      //                 );
      //               },
      //               icon: const Icon(Icons.edit, color: Colors.white),
      //
      //             ),
      //           ),
      //           DataCell(
      //             IconButton(
      //               onPressed: () async {
      //                 if (await UserSaveHelper.isExpired()) {
      //                   DialogHelper.showExpiredDialog(context);
      //                   return;
      //                 }
      //                 context.variantTypeProvider.deleteVariantType(item);
      //               },
      //               icon: const Icon(Icons.delete, color: Colors.red),
      //
      //             ),
      //           ),
      //         ],
      //       );
      //     },
      //   ),
      // ),
      width: double.infinity,
      child: LayoutBuilder(
        builder: (_, cons) {
          final w = cons.maxWidth; // عرض کارت

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,          // 👈 اسکرول افقی در صورت نیاز
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: w), // 👈 حداقل = تمام عرض کارت
              child: SingleChildScrollView(             // 👈 اسکرول عمودی جدول
                child: Selector<DataProvider, List<VariantType>>(
                  selector: (_, dp) => dp.variantTypes,
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
                        final VariantType item = items[i];
                        return DataRow(
                          cells: [
                            DataCell(Text(item.name ?? '')),
                            DataCell(Text(item.type ?? '')),
                            DataCell(
                              IconButton(
                                onPressed: () async {
                                  if (await UserSaveHelper.isExpired()) {
                                    DialogHelper.showExpiredDialog(context);
                                    return;
                                  }
                                  showAddVariantTypeForm(
                                    context,
                                    item,
                                    'ویرایش نوع ویژگی',
                                  );
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
                                  context.variantTypeProvider.deleteVariantType(item);
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
