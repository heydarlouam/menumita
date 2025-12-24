
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/product.dart';
import '../../../utility/constants.dart';
import '../../../utility/functions.dart';
import 'add_product_form.dart';



class ProductListSection extends StatelessWidget {
  const ProductListSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Selector<DataProvider, List<Product>>(
        selector: (_, dp) => dp.products,
        builder: (context, items, _) {
          return LayoutBuilder(
            builder: (_, cons) {
              final w = cons.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: w),
                  child: DataTable(
                    columnSpacing: defaultPadding,
                    columns: const [
                      DataColumn(label: Text("نام محصول", style: TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
                      DataColumn(label: Text("دسته‌بندی", style: TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
                      DataColumn(label: Text("زیر‌دسته", style: TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
                      DataColumn(label: Text("قیمت", style: TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
                      DataColumn(label: Text("ویرایش", style: TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
                      DataColumn(label: Text("حذف", style: TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
                    ],
                    rows: List.generate(items.length, (index) {
                      final p = items[index];
                      return _productDataRow(context, p);
                    }),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  DataRow _productDataRow(BuildContext context, Product productInfo) {
    final String? imageUrl = (productInfo.imageUrls.isNotEmpty) ? productInfo.imageUrls.first : null;

    // این دو فیلد را در DataProvider hydrate می‌کنیم (پایین‌تر کدش را می‌دهم)
    final String categoryName = productInfo.resolvedCategoryName ?? '';
    final String subCategoryName = productInfo.resolvedSubCategoryName ?? '';

    final double? price = double.tryParse((productInfo.price ?? '').toString());

    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            if (imageUrl != null && imageUrl.trim().isNotEmpty)
              Image.network(
                imageUrl,
                height: 30,
                width: 30,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 30),
              )
            else
              const Icon(Icons.image, size: 30),
            const SizedBox(width: defaultPadding),
            Text(productInfo.name ?? 'بدون نام', style: const TextStyle(fontFamily: FONTS_STYLE_FAMILY)),
          ],
        )),
        DataCell(Text(categoryName, style: const TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
        DataCell(Text(subCategoryName, style: const TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
        DataCell(Text(formatCurrency(context, price), style: const TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
        DataCell(IconButton(
          onPressed: ()async {
    if (await UserSaveHelper.isExpired()) {
    DialogHelper.showExpiredDialog(context);
    return;
    }
    showAddProductForm(context, productInfo);
    }

         ,
          icon: const Icon(Icons.edit, color: Colors.white),
        )),
        DataCell(IconButton(

        onPressed: ()async {
    if (await UserSaveHelper.isExpired()) {
    DialogHelper.showExpiredDialog(context);
    return;
    }
    context.dashBoardProvider.deleteProduct(productInfo);
    }
     ,
          icon: const Icon(Icons.delete, color: Colors.red),
        )),
      ],
    );
  }
}
