// import 'package:admin/utility/extensions.dart';
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../core/data/data_provider.dart';
// import '../../../models/brand.dart';
//
// import '../../../utility/constants.dart';
// import 'add_brand_form.dart';
//
//
//
// class BrandListSection extends StatelessWidget {
//   const BrandListSection({Key? key}) : super(key: key);
//
//   // نام ساب‌کتگوری با اولویت: expand شده → فقط ID → '-'
//   String _subName(Brand b) {
//     final scObj = b.subCategoryId;
//     if (scObj != null) {
//       final name = scObj.name;
//       if (name != null && name.isNotEmpty) return name;
//
//       final id = scObj.sId;
//       if (id != null && id.isNotEmpty) return 'ID: $id';
//     }
//     final idStr = b.subcategory;
//     if (idStr != null && idStr.isNotEmpty) return 'ID: $idStr';
//     return '-';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // ⬅️ از watch استفاده می‌کنیم تا با notifyListeners ریبیلد شود
//     final data = context.watch<DataProvider>();
//
//     return Container(
//       padding: const EdgeInsets.all(defaultPadding),
//       decoration: const BoxDecoration(
//         color: secondaryColor,
//         borderRadius: BorderRadius.all(Radius.circular(10)),
//       ),
//       width: double.infinity,
//       child: DataTable(
//         columnSpacing: defaultPadding,
//         columns: const [
//           DataColumn(label: Text('Brand Name')),
//           DataColumn(label: Text('Sub Category')),
//           DataColumn(label: Text('Edit')),
//           DataColumn(label: Text('Delete')),
//         ],
//         rows: List.generate(
//           data.brands.length,
//               (index) => _brandRow(context, data.brands[index]),
//         ),
//       ),
//     );
//   }
//
//   DataRow _brandRow(BuildContext context, Brand b) {
//     return DataRow(
//       cells: [
//         DataCell(Text(b.name ?? '')),
//         DataCell(Text(_subName(b))),
//         DataCell(
//           IconButton(
//             onPressed: () {
//               showAddBrandForm(context, b); // Edit
//             },
//             icon: const Icon(Icons.edit, color: Colors.white),
//           ),
//         ),
//         DataCell(
//           IconButton(
//             onPressed: () async {
//               final ok = await context.brandProvider.deleteBrand(b);
//               // NOTE: _dataProvider.getAllBrands داخل provider فراخوانی می‌شود
//               // و به خاطر استفاده از watch در این ویجت، جدول ریبیلد خواهد شد.
//             },
//             icon: const Icon(Icons.delete, color: Colors.red),
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/brand.dart';
import '../../../utility/constants.dart';
import 'add_brand_form.dart';

class BrandListSection extends StatelessWidget {
  const BrandListSection({Key? key}) : super(key: key);

  // نام ساب‌کتگوری با اولویت: expand شده → فقط ID → '-'
  String _subName(Brand b) {
    final scObj = b.subCategoryId;
    if (scObj != null) {
      final name = scObj.name;
      if (name != null && name.isNotEmpty) return name;

      final id = scObj.sId;
      if (id != null && id.isNotEmpty) return 'شناسه: $id';
    }
    final idStr = b.subcategory;
    if (idStr != null && idStr.isNotEmpty) return 'شناسه: $idStr';
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    //
    // return Container(
    //   padding: const EdgeInsets.all(defaultPadding),
    //   decoration: const BoxDecoration(
    //     color: secondaryColor,
    //     borderRadius: BorderRadius.all(Radius.circular(10)),
    //   ),
    //   width: double.infinity,
    //   child: DataTable(
    //     columnSpacing: defaultPadding,
    //     columns: const [
    //       DataColumn(label: Text('نام برند')),
    //       DataColumn(label: Text('زیر‌دسته')),
    //       DataColumn(label: Text('ویرایش')),
    //       DataColumn(label: Text('حذف')),
    //     ],
    //     rows: List.generate(
    //       data.brands.length,
    //           (index) => _brandRow(context, data.brands[index]),
    //     ),
    //   ),
    // );
    //

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      width: double.infinity,
      child: LayoutBuilder(
        builder: (_, cons) {
          final w = cons.maxWidth; // عرض واقعی همین کارت
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: w), // حداقل = عرض کارت
              child: DataTable(
                columnSpacing: defaultPadding,
                columns: const [
                  DataColumn(label: Text('نام برند')),
                  DataColumn(label: Text('زیر‌دسته')),
                  DataColumn(label: Text('ویرایش')),
                  DataColumn(label: Text('حذف')),
                ],
                rows: List.generate(
                  data.brands.length,
                      (index) => _brandRow(context, data.brands[index]),
                ),
              ),
            ),
          );
        },
      ),

    );

  }

  DataRow _brandRow(BuildContext context, Brand b) {
    return DataRow(
      cells: [
        DataCell(Text(b.name ?? '')),
        DataCell(Text(_subName(b))),

        DataCell(
          IconButton(
            onPressed: () async {
              if (await UserSaveHelper.isExpired()) {
                DialogHelper.showExpiredDialog(context);
                return;
              }
              showAddBrandForm(context, b);
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
              await context.brandProvider.deleteBrand(b);
            },
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ),

      ],
    );
  }
}
