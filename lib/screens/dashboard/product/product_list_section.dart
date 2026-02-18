
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

import 'package:shimmer_animation/shimmer_animation.dart';

class ProductListSection extends StatefulWidget {
  const ProductListSection({Key? key}) : super(key: key);

  @override
  State<ProductListSection> createState() => _ProductListSectionState();
}

class _ProductListSectionState extends State<ProductListSection> {
  final ScrollController _innerCtrl = ScrollController();
  ScrollPosition? _parentPos;

  @override
  void initState() {
    super.initState();
    _innerCtrl.addListener(_maybeLoadMoreFromInner);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newParentPos = Scrollable.maybeOf(context)?.position;
    if (_parentPos != newParentPos) {
      _parentPos?.removeListener(_maybeLoadMoreFromParent);
      _parentPos = newParentPos;
      _parentPos?.addListener(_maybeLoadMoreFromParent);
    }
  }

  void _maybeLoadMoreCommon({required double pixels, required double maxExtent}) {
    if (!mounted) return;

    final dp = context.read<DataProvider>();
    if (!dp.hasMoreProducts || dp.isProductsLoading || dp.isProductsLoadingMore) return;

    if (pixels >= maxExtent - 220) {
      dp.loadMoreProducts(); // ✅
    }
  }

  void _maybeLoadMoreFromInner() {
    if (!_innerCtrl.hasClients) return;
    final p = _innerCtrl.position;
    _maybeLoadMoreCommon(pixels: p.pixels, maxExtent: p.maxScrollExtent);
  }

  void _maybeLoadMoreFromParent() {
    final p = _parentPos;
    if (p == null) return;
    _maybeLoadMoreCommon(pixels: p.pixels, maxExtent: p.maxScrollExtent);
  }

  @override
  void dispose() {
    _innerCtrl.removeListener(_maybeLoadMoreFromInner);
    _innerCtrl.dispose();
    _parentPos?.removeListener(_maybeLoadMoreFromParent);
    _parentPos = null;
    super.dispose();
  }

  // ---------- Shimmer helpers ----------
  Widget _shimmerBox({double w = 120, double h = 14, BorderRadius? r}) {
    return Shimmer(
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: r ?? BorderRadius.circular(6),
        ),
      ),
    );
  }

  List<DataRow> _buildShimmerRows(int count) {
    return List.generate(count, (i) {
      return DataRow(
        cells: [
          DataCell(_shimmerBox(w: 220, h: 14)),
          DataCell(_shimmerBox(w: 140, h: 14)),
          DataCell(_shimmerBox(w: 140, h: 14)),
          DataCell(_shimmerBox(w: 90, h: 14)),
          DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
          DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
        ],
      );
    });
  }

  _ProductsViewState _selectState(DataProvider dp) => _ProductsViewState(
    dp.products,
    dp.isProductsLoading,
    dp.isProductsLoadingMore,
    dp.hasMoreProducts,
  );

  @override
  Widget build(BuildContext context) {
    return Selector<DataProvider, _ProductsViewState>(
      selector: (_, dp) => _selectState(dp),
      builder: (_, st, __) {
        final items = st.items;
        final loading = st.loading;
        final loadingMore = st.loadingMore;
        final hasMore = st.hasMore;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(defaultPadding),
          decoration: const BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: LayoutBuilder(
            builder: (_, cons) {
              final w = cons.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: w),
                  child: SingleChildScrollView(
                    controller: _innerCtrl,
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
                      rows: [
                        // ✅ لود اولیه: shimmer
                        if (loading && items.isEmpty) ..._buildShimmerRows(10),

                        // ✅ دیتا
                        if (!(loading && items.isEmpty))
                          ...List.generate(items.length, (index) {
                            final p = items[index];
                            return _productDataRow(context, p);
                          }),

                        // ✅ لود بیشتر: shimmer row پایین
                        if (loadingMore)
                          DataRow(
                            cells: [
                              DataCell(_shimmerBox(w: 220, h: 14)),
                              DataCell(_shimmerBox(w: 140, h: 14)),
                              DataCell(_shimmerBox(w: 140, h: 14)),
                              DataCell(_shimmerBox(w: 90, h: 14)),
                              DataCell(_shimmerBox(w: 28, h: 28)),
                              DataCell(_shimmerBox(w: 28, h: 28)),
                            ],
                          ),

                        // ✅ پایان لیست
                        if (!hasMore && !loading && items.isNotEmpty)
                          const DataRow(
                            cells: [
                              DataCell(Text('')),
                              DataCell(Center(child: Text('پایان لیست'))),
                              DataCell(Text('')),
                              DataCell(Text('')),
                              DataCell(Text('')),
                              DataCell(Text('')),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  DataRow _productDataRow(BuildContext context, Product productInfo) {
    final String? imageUrl = (productInfo.imageUrls.isNotEmpty) ? productInfo.imageUrls.first : null;
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
          onPressed: () async {
            if (await UserSaveHelper.isExpired()) {
              DialogHelper.showExpiredDialog(context);
              return;
            }
            showAddProductForm(context, productInfo);
          },
          icon: const Icon(Icons.edit, color: Colors.white),
        )),
        DataCell(IconButton(
          onPressed: () async {
            if (await UserSaveHelper.isExpired()) {
              DialogHelper.showExpiredDialog(context);
              return;
            }
            context.dashBoardProvider.deleteProduct(productInfo);
          },
          icon: const Icon(Icons.delete, color: Colors.red),
        )),
      ],
    );
  }
}

class _ProductsViewState {
  final List<Product> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;

  const _ProductsViewState(this.items, this.loading, this.loadingMore, this.hasMore);

  @override
  bool operator ==(Object other) {
    return other is _ProductsViewState &&
        identical(items, other.items) &&
        loading == other.loading &&
        loadingMore == other.loadingMore &&
        hasMore == other.hasMore;
  }

  @override
  int get hashCode => Object.hash(items, loading, loadingMore, hasMore);
}

//
// class ProductListSection extends StatelessWidget {
//   const ProductListSection({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(defaultPadding),
//       decoration: const BoxDecoration(
//         color: secondaryColor,
//         borderRadius: BorderRadius.all(Radius.circular(10)),
//       ),
//       child: Selector<DataProvider, List<Product>>(
//         selector: (_, dp) => dp.products,
//         builder: (context, items, _) {
//           return LayoutBuilder(
//             builder: (_, cons) {
//               final w = cons.maxWidth;
//               return SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(minWidth: w),
//                   child: DataTable(
//                     columnSpacing: defaultPadding,
//                     columns: const [
//                       DataColumn(label: Text("نام محصول", style: TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
//                       DataColumn(label: Text("دسته‌بندی", style: TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
//                       DataColumn(label: Text("زیر‌دسته", style: TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
//                       DataColumn(label: Text("قیمت", style: TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
//                       DataColumn(label: Text("ویرایش", style: TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
//                       DataColumn(label: Text("حذف", style: TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
//                     ],
//                     rows: List.generate(items.length, (index) {
//                       final p = items[index];
//                       return _productDataRow(context, p);
//                     }),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   DataRow _productDataRow(BuildContext context, Product productInfo) {
//     final String? imageUrl = (productInfo.imageUrls.isNotEmpty) ? productInfo.imageUrls.first : null;
//
//     // این دو فیلد را در DataProvider hydrate می‌کنیم (پایین‌تر کدش را می‌دهم)
//     final String categoryName = productInfo.resolvedCategoryName ?? '';
//     final String subCategoryName = productInfo.resolvedSubCategoryName ?? '';
//
//     final double? price = double.tryParse((productInfo.price ?? '').toString());
//
//     return DataRow(
//       cells: [
//         DataCell(Row(
//           children: [
//             if (imageUrl != null && imageUrl.trim().isNotEmpty)
//               Image.network(
//                 imageUrl,
//                 height: 30,
//                 width: 30,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 30),
//               )
//             else
//               const Icon(Icons.image, size: 30),
//             const SizedBox(width: defaultPadding),
//             Text(productInfo.name ?? 'بدون نام', style: const TextStyle(fontFamily: FONTS_STYLE_FAMILY)),
//           ],
//         )),
//         DataCell(Text(categoryName, style: const TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
//         DataCell(Text(subCategoryName, style: const TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
//         DataCell(Text(formatCurrency(context, price), style: const TextStyle(fontFamily: FONTS_STYLE_FAMILY))),
//         DataCell(IconButton(
//           onPressed: ()async {
//     if (await UserSaveHelper.isExpired()) {
//     DialogHelper.showExpiredDialog(context);
//     return;
//     }
//     showAddProductForm(context, productInfo);
//     }
//
//          ,
//           icon: const Icon(Icons.edit, color: Colors.white),
//         )),
//         DataCell(IconButton(
//
//         onPressed: ()async {
//     if (await UserSaveHelper.isExpired()) {
//     DialogHelper.showExpiredDialog(context);
//     return;
//     }
//     context.dashBoardProvider.deleteProduct(productInfo);
//     }
//      ,
//           icon: const Icon(Icons.delete, color: Colors.red),
//         )),
//       ],
//     );
//   }
// }
