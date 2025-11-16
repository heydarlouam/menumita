
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

      child: SizedBox(
        width: double.infinity,
        child: LayoutBuilder(
          builder: (_, cons) {
            final w = cons.maxWidth;
            return Selector<DataProvider, List<SubCategory>>(
              selector: (_, dp) => dp.subCategories,
              builder: (context, subs, child) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: w),
                    child: SingleChildScrollView(
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
                          subs.length,
                              (index) => subCategoryDataRow(
                            context,
                            subs[index],
                            index + 1,
                            edit: () {
                              showAddSubCategoryForm(
                                context,
                                subs[index],
                              );
                            },
                            delete: () {
                              context.subCategoryProvider
                                  .deleteSubCategory(subs[index]);
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
