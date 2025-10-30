
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/sub_category.dart';
import '../../../utility/color_list.dart';
import '../../../utility/constants.dart';
import '../../../utility/functions.dart';
import 'add_sub_category_form.dart';

class SubCategoryListSection extends StatelessWidget {
  const SubCategoryListSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      // child: SizedBox(
      //   width: double.infinity,
      //   child: Consumer<DataProvider>(
      //     builder: (context, dataProvider, child) {
      //       return DataTable(
      //         columnSpacing: defaultPadding,
      //         columns: [
      //           DataColumn(
      //             label: Text("نام زیر‌دسته"),
      //           ),
      //           DataColumn(
      //             label: Text("دسته‌بندی"),
      //           ),
      //           DataColumn(
      //             label: Text("تاریخ افزودن"),
      //           ),
      //           DataColumn(
      //             label: Text("ویرایش"),
      //           ),
      //           DataColumn(
      //             label: Text("حذف"),
      //           ),
      //         ],
      //         rows: List.generate(
      //           dataProvider.subCategories.length,
      //               (index) => subCategoryDataRow(
      //             context,
      //             dataProvider.subCategories[index],
      //             index + 1,
      //             edit: () {
      //               showAddSubCategoryForm(
      //                   context, dataProvider.subCategories[index]);
      //             },
      //             delete: () {
      //               context.subCategoryProvider
      //                   .deleteSubCategory(dataProvider.subCategories[index]);
      //             },
      //           ),
      //         ),
      //       );
      //     },
      //   ),
      // ),
      child: SizedBox(
        width: double.infinity,
        child: LayoutBuilder(
          builder: (_, cons) {
            final w = cons.maxWidth;
            return Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,           // 👈 اسکرول افقی در صورت کمبود فضا
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: w), // 👈 حداقل عرض = کل عرض کارت
                    child: SingleChildScrollView(             // 👈 اسکرول عمودی مثل قبل
                      child: DataTable(
                        columnSpacing: defaultPadding,
                        columns: const [
                          DataColumn(label: Text("نام زیر‌دسته")),
                          DataColumn(label: Text("دسته‌بندی")),
                          DataColumn(label: Text("تاریخ افزودن")),
                          DataColumn(label: Text("ویرایش")),
                          DataColumn(label: Text("حذف")),
                        ],
                        rows: List.generate(
                          dataProvider.subCategories.length,
                              (index) => subCategoryDataRow(
                            context,
                            dataProvider.subCategories[index],
                            index + 1,
                            edit: () {
                              showAddSubCategoryForm(
                                context,
                                dataProvider.subCategories[index],
                              );
                            },
                            delete: () {
                              context.subCategoryProvider
                                  .deleteSubCategory(dataProvider.subCategories[index]);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

DataRow subCategoryDataRow(
    BuildContext context, SubCategory subCatInfo, int index,
    {Function? edit, Function? delete}) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            Container(
              height: 24,
              width: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
              child: Text(
                index.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(subCatInfo.name ?? ''),
            ),
          ],
        ),
      ),
      DataCell(Text(subCatInfo.categoryId?.name ?? '')),
      DataCell(Text(formatTimestamp(context, subCatInfo.createdAt))),
      DataCell(IconButton(
        onPressed: () async {
          if (await UserSaveHelper.isExpired()) {
            DialogHelper.showExpiredDialog(context);
            return;
          }
          if (edit != null) edit();
        },

        icon: Icon(
          Icons.edit,
          color: Colors.white,
        ),
      )),
      DataCell(IconButton(
        onPressed: () async {
          if (await UserSaveHelper.isExpired()) {
            DialogHelper.showExpiredDialog(context);
            return;
          }
          if (delete != null) delete();
        },

        icon: Icon(
          Icons.delete,
          color: Colors.red,
        ),
      )),
    ],
  );
}
