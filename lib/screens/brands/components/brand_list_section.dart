
import 'package:admin/screens/brands/provider/brand_provider.dart';
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/brand.dart';
import '../../../utility/constants.dart';
import 'add_brand_form.dart';

class BrandListSection extends StatefulWidget {
  const BrandListSection({Key? key}) : super(key: key);

  @override
  State<BrandListSection> createState() => _BrandListSectionState();
}

class _BrandListSectionState extends State<BrandListSection> {
  ScrollableState? _pageScrollable;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ نزدیک‌ترین اسکرول والد (همون SingleChildScrollView صفحه)
    final s = Scrollable.of(context);
    if (s == _pageScrollable) return;

    _pageScrollable?.position.removeListener(_onPageScroll);
    _pageScrollable = s;

    // ممکنه بعضی وقتا هنوز position attach نشده باشه
    try {
      _pageScrollable?.position.addListener(_onPageScroll);
    } catch (_) {}
  }

  void _onPageScroll() {
    if (!mounted) return;

    final dp = context.read<DataProvider>();
    if (!dp.hasMoreBrands || dp.isBrandsLoading || dp.isBrandsLoadingMore) return;

    final pos = _pageScrollable?.position;
    if (pos == null) return;

    // اگر هنوز اسکرول واقعی نداریم (لیست کوتاهه)، لود بیشتر رو خودکار تریگر نکن
    if (!pos.hasPixels || !pos.hasContentDimensions) return;
    if (pos.maxScrollExtent <= 0) return;

    const threshold = 240.0;
    if (pos.pixels >= (pos.maxScrollExtent - threshold)) {
      dp.loadMoreBrands();
    }
  }

  @override
  void dispose() {
    _pageScrollable?.position.removeListener(_onPageScroll);
    super.dispose();
  }



  String _subName(Brand b) {
    final name = (b.subCategoryId?.name ?? '').trim();
    return name.isNotEmpty ? name : '-';
  }

  // String _subName(Brand b) {
  //   final scObj = b.subCategoryId;
  //   if (scObj != null) {
  //     final name = scObj.name;
  //     if (name != null && name.isNotEmpty) return name;
  //
  //     final id = scObj.sId;
  //     if (id != null && id.isNotEmpty) return 'شناسه: $id';
  //   }
  //   final idStr = b.subcategory;
  //   if (idStr != null && idStr.isNotEmpty) return 'شناسه: $idStr';
  //   return '-';
  // }
  Widget _shimmerBox({double w = 120, double h = 14}) {
    return Shimmer(
      // اگر پکیجت پارامترهای دیگه داشت هم اوکیه
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  List<DataRow> _buildShimmerRows(int count) {
    return List.generate(count, (_) {
      return DataRow(
        cells: [
          DataCell(_shimmerBox(w: 140)),
          DataCell(_shimmerBox(w: 160)),
          DataCell(_shimmerBox(w: 28, h: 28)),
          DataCell(_shimmerBox(w: 28, h: 28)),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
              child: Selector<DataProvider, _BrandListVm>(
                selector: (_, dp) => _BrandListVm(
                  brands: dp.brands,
                  loading: dp.isBrandsLoading,
                  loadingMore: dp.isBrandsLoadingMore,
                  hasMore: dp.hasMoreBrands,
                ),
                builder: (_, vm, __) {
                  final brands = vm.brands;

                  return DataTable(
                    columnSpacing: defaultPadding,
                    columns: const [
                      DataColumn(label: Text('نام برند')),
                      DataColumn(label: Text('زیر‌دسته')),
                      DataColumn(label: Text('ویرایش')),
                      DataColumn(label: Text('حذف')),
                    ],
                    rows: [
                      // ✅ لود اولیه: shimmer
                      if (vm.loading && brands.isEmpty) ..._buildShimmerRows(10),

                      // ✅ دیتا
                      if (!(vm.loading && brands.isEmpty))
                        ...List.generate(
                          brands.length,
                              (index) => _brandRow(context, brands[index]),
                        ),

                      // ✅ لود بیشتر: shimmer پایین جدول
                      if (vm.loadingMore) ..._buildShimmerRows(1),

                      // ✅ پایان لیست (اختیاری)
                      if (!vm.hasMore && !vm.loading && brands.isNotEmpty)
                        const DataRow(
                          cells: [
                            DataCell(Text('')),
                            DataCell(Center(child: Text('پایان لیست'))),
                            DataCell(Text('')),
                            DataCell(Text('')),
                          ],
                        ),
                    ],
                  );
                },
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

class _BrandListVm {
  final List<Brand> brands;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;

  const _BrandListVm({
    required this.brands,
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
  });
}
