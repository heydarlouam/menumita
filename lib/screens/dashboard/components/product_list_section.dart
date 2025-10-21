// import 'package:admin/utility/extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../core/data/data_provider.dart';
// import '../../../models/product.dart';
// import '../../../utility/constants.dart';
// import '../../../utility/functions.dart';
// import 'add_product_form.dart';
//
// class ProductListSection extends StatelessWidget {
//   const ProductListSection({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(defaultPadding),
//       decoration: BoxDecoration(
//         color: secondaryColor,
//         borderRadius: const BorderRadius.all(Radius.circular(10)),
//       ),
//       child: SizedBox(
//         width: double.infinity,
//         child: Consumer<DataProvider>(
//           builder: (context, dataProvider, child) {
//             return DataTable(
//               columnSpacing: defaultPadding,
//               // minWidth: 600,
//               columns: [
//                 DataColumn(
//                   label: Text("Product Name"),
//                 ),
//                 DataColumn(
//                   label: Text("Category"),
//                 ),
//                 DataColumn(
//                   label: Text("Sub Category"),
//                 ),
//                 DataColumn(
//                   label: Text("Price"),
//                 ),
//                 DataColumn(
//                   label: Text("Edit"),
//                 ),
//                 DataColumn(
//                   label: Text("Delete"),
//                 ),
//               ],
//               rows: List.generate(
//                 dataProvider.products.length,
//                 (index) => productDataRow(
//                   context,
//                   dataProvider.products[index],
//                   edit: () {
//                     showAddProductForm(context, dataProvider.products[index]);
//                   },
//                   delete: () {
//                     context.dashBoardProvider
//                         .deleteProduct(dataProvider.products[index]);
//                   },
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// DataRow productDataRow(BuildContext context, Product productInfo,
//     {Function? edit, Function? delete}) {
//   return DataRow(
//     cells: [
//
//       DataCell(
//         Row(
//           children: [
//             // بررسی وجود images و اولین تصویر
//             if (productInfo.images != null &&
//                 productInfo.images!.isNotEmpty &&
//                 productInfo.images!.first.url != null)
//               Image.network(
//                 productInfo.images!.first.url!,
//                 height: 30,
//                 width: 30,
//                 errorBuilder: (BuildContext context, Object exception,
//                     StackTrace? stackTrace) {
//                   return Icon(Icons.broken_image, size: 30);
//                 },
//               )
//             else
//               Icon(Icons.image, size: 30),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
//               child: Text(productInfo.name ?? 'بدون نام'),
//             ),
//           ],
//         ),
//       ),
//       DataCell(Text(productInfo.proCategoryId?.name ?? '')),
//       DataCell(Text(productInfo.proSubCategoryId?.name ?? '')),
//       DataCell(Text(formatCurrency(context, productInfo.price))),
//       DataCell(IconButton(
//           onPressed: () {
//             if (edit != null) edit();
//           },
//           icon: Icon(
//             Icons.edit,
//             color: Colors.white,
//           ))),
//       DataCell(IconButton(
//           onPressed: () {
//             if (delete != null) delete();
//           },
//           icon: Icon(
//             Icons.delete,
//             color: Colors.red,
//           ))),
//     ],
//   );
// }

import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/product.dart';
import '../../../utility/constants.dart';
import '../../../utility/functions.dart';
import 'add_product_form.dart';

class ProductListSection extends StatelessWidget {
  const ProductListSection({
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
        child: Consumer<DataProvider>(
          builder: (context, dataProvider, child) {
            return DataTable(
              columnSpacing: defaultPadding,
              columns: [
                DataColumn(
                  label: Text("نام محصول"),
                ),
                DataColumn(
                  label: Text("دسته‌بندی"),
                ),
                DataColumn(
                  label: Text("زیر‌دسته"),
                ),
                DataColumn(
                  label: Text("قیمت"),
                ),
                DataColumn(
                  label: Text("ویرایش"),
                ),
                DataColumn(
                  label: Text("حذف"),
                ),
              ],
              rows: List.generate(
                dataProvider.products.length,
                    (index) => productDataRow(
                  context,
                  dataProvider.products[index],
                  edit: () {
                    showAddProductForm(context, dataProvider.products[index]);
                  },
                  delete: () {
                    context.dashBoardProvider
                        .deleteProduct(dataProvider.products[index]);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

DataRow productDataRow(BuildContext context, Product productInfo,
    {Function? edit, Function? delete}) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            if (productInfo.images != null &&
                productInfo.images!.isNotEmpty &&
                productInfo.images!.first.url != null)
              Image.network(
                productInfo.images!.first.url!,
                height: 30,
                width: 30,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Icon(Icons.broken_image, size: 30);
                },
              )
            else
              Icon(Icons.image, size: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(productInfo.name ?? 'بدون نام'),
            ),
          ],
        ),
      ),
      DataCell(Text(productInfo.proCategoryId?.name ?? '')),
      DataCell(Text(productInfo.proSubCategoryId?.name ?? '')),
      DataCell(Text(formatCurrency(context, productInfo.price))),
      DataCell(IconButton(
          onPressed: () {
            if (edit != null) edit();
          },
          icon: Icon(
            Icons.edit,
            color: Colors.white,
          ))),
      DataCell(IconButton(
          onPressed: () {
            if (delete != null) delete();
          },
          icon: Icon(
            Icons.delete,
            color: Colors.red,
          ))),
    ],
  );
}
