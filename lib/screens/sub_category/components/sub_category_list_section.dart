
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


import 'package:shimmer_animation/shimmer_animation.dart';

class SubCategoryListSection extends StatefulWidget {
  const SubCategoryListSection({Key? key}) : super(key: key);

  @override
  State<SubCategoryListSection> createState() => _SubCategoryListSectionState();
}

class _SubCategoryListSectionState extends State<SubCategoryListSection> {
  // کنترلر اسکرول داخلی (همین جدول) - ممکنه بعضی جاها اصلاً اسکرول نخوره
  final ScrollController _innerCtrl = ScrollController();

  // پوزیشن اسکرول والد (اسکرول صفحه)
  ScrollPosition? _parentPos;

  @override
  void initState() {
    super.initState();
    _innerCtrl.addListener(_maybeLoadMoreFromInner);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // گرفتن اسکرول والد (مثل SingleChildScrollView صفحه)
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
    final loading = dp.isSubCategoriesLoading;
    final loadingMore = dp.isSubCategoriesLoadingMore;
    final hasMore = dp.hasMoreSubCategories;

    if (!hasMore || loading || loadingMore) return;

    if (pixels >= maxExtent - 220) {
      // ✅ اسم متد را مطابق دیتاپراوایدر خودت نگه دار
      dp.loadMoreSubCategories();
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
          DataCell(
            Row(
              children: [
                _shimmerBox(w: 24, h: 24, r: BorderRadius.circular(50)),
                const SizedBox(width: defaultPadding),
                _shimmerBox(w: 160, h: 14),
              ],
            ),
          ),
          DataCell(_shimmerBox(w: 140, h: 14)),
          DataCell(_shimmerBox(w: 110, h: 14)),
          DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
          DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DataProvider>();
    final subs = dp.subCategories;

    final loading = dp.isSubCategoriesLoading;
    final loadingMore = dp.isSubCategoriesLoadingMore;
    final hasMore = dp.hasMoreSubCategories;

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

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: w),
                child: SingleChildScrollView(
                  controller: _innerCtrl, // ✅ فقط کنترلر اضافه شد (دیزاین تغییر نکرد)
                  child: DataTable(
                    columnSpacing: defaultPadding,
                    columns: const [
                      DataColumn(label: Text("نام زیر‌دسته")),
                      DataColumn(label: Text("دسته‌بندی")),
                      DataColumn(label: Text("تاریخ افزودن")),
                      DataColumn(label: Text("ویرایش")),
                      DataColumn(label: Text("حذف")),
                    ],
                    rows: [
                      // ✅ لود اولیه: shimmer
                      if (loading && subs.isEmpty) ..._buildShimmerRows(10),

                      // ✅ دیتا
                      if (!(loading && subs.isEmpty))
                        ...List.generate(
                          subs.length,
                              (index) => subCategoryDataRow(
                            context,
                            subs[index],
                            index + 1,
                            edit: () {
                              showAddSubCategoryForm(context, subs[index]);
                            },
                            delete: () {
                              context.subCategoryProvider
                                  .deleteSubCategory(subs[index]);
                            },
                          ),
                        ),

                      // ✅ لود بیشتر: shimmer row پایین
                      if (loadingMore)
                        DataRow(
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  _shimmerBox(
                                      w: 24,
                                      h: 24,
                                      r: BorderRadius.circular(50)),
                                  const SizedBox(width: defaultPadding),
                                  _shimmerBox(w: 160, h: 14),
                                ],
                              ),
                            ),
                            DataCell(_shimmerBox(w: 140, h: 14)),
                            DataCell(_shimmerBox(w: 110, h: 14)),
                            DataCell(_shimmerBox(w: 28, h: 28)),
                            DataCell(_shimmerBox(w: 28, h: 28)),
                          ],
                        ),

                      // ✅ پایان لیست
                      if (!hasMore && !loading && subs.isNotEmpty)
                        const DataRow(
                          cells: [
                            DataCell(Text('')),
                            DataCell(Center(child: Text('پایان لیست'))),
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
      ),
    );
  }
}

DataRow subCategoryDataRow(
    BuildContext context,
    SubCategory subCatInfo,
    int index, {
      Function? edit,
      Function? delete,
    }) {
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
      DataCell(
        Text(() {
          String categoryName = subCatInfo.categoryId?.name ?? '';
          if (categoryName.isEmpty && subCatInfo.category != null) {
            try {
              final cat = context.dataProvider.categories.firstWhere(
                    (c) => c.sId == subCatInfo.category,
              );
              categoryName = cat.name ?? '';
            } catch (_) {
              categoryName = '';
            }
          }
          return categoryName;
        }()),
      ),
      DataCell(Text(formatTimestamp(context, subCatInfo.createdAt))),
      DataCell(
        IconButton(
          onPressed: () async {
            if (await UserSaveHelper.isExpired()) {
              DialogHelper.showExpiredDialog(context);
              return;
            }
            edit?.call();
          },
          icon: Icon(Icons.edit, color: Colors.white),
        ),
      ),
      DataCell(
        IconButton(
          onPressed: () async {
            if (await UserSaveHelper.isExpired()) {
              DialogHelper.showExpiredDialog(context);
              return;
            }
            delete?.call();
          },
          icon: Icon(Icons.delete, color: Colors.red),
        ),
      ),
    ],
  );
}

