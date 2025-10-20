import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../utility/constants.dart';
import '../../../utility/functions.dart';
import 'add_category_form.dart';

class CategoryListSection extends StatelessWidget {
  const CategoryListSection({Key? key}) : super(key: key);

  String _imgUrl(String? u) {
    if (u == null || u.isEmpty) return '';
    if (u.startsWith('http')) return u;
    if (u.startsWith('/')) return MAIN_URL + u;
    return '$MAIN_URL/$u';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Consumer<DataProvider>(
          builder: (context, dataProvider, child) {
            return DataTable(
              columnSpacing: defaultPadding,
              columns: const [
                DataColumn(label: Text("Category Name")),
                DataColumn(label: Text("Added Date")),
                DataColumn(label: Text("Edit")),
                DataColumn(label: Text("Delete")),
              ],
              rows: List.generate(
                dataProvider.categories.length,
                    (index) => categoryDataRow(
                  context,
                  dataProvider.categories[index],
                  delete: () {
                    context.categoryProvider
                        .deleteCategory(dataProvider.categories[index]);
                  },
                  edit: () {
                    showAddCategoryForm(
                      context,
                      dataProvider.categories[index],
                      'Edit Category',
                    );
                  },
                  buildImageUrl: _imgUrl,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

DataRow categoryDataRow(
    BuildContext context,
    Category catInfo, {
      required String Function(String?) buildImageUrl,
      Function? edit,
      Function? delete,
    }) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            Image.network(
              buildImageUrl(catInfo.image),
              height: 30,
              width: 30,
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                return const Icon(Icons.error);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(catInfo.name ?? ''),
            ),
          ],
        ),
      ),
      DataCell(Text(formatTimestamp(context, catInfo.createdAt))),
      DataCell(IconButton(
        onPressed: () => edit?.call(),
        icon: const Icon(Icons.edit, color: Colors.white),
      )),
      DataCell(IconButton(
        onPressed: () => delete?.call(),
        icon: const Icon(Icons.delete, color: Colors.red),
      )),
    ],
  );
}


