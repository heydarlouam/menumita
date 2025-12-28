

import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/variant.dart';
import '../../../utility/constants.dart';
import 'add_variant_form.dart';

// class VariantsListSection extends StatelessWidget {
//   const VariantsListSection({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // لیست ویژگی‌ها فقط هنگام تغییر خودش ری‌بیلد می‌شود
//
//     return Container(
//       padding: const EdgeInsets.all(defaultPadding),
//       decoration: const BoxDecoration(
//         color: secondaryColor,
//         borderRadius: BorderRadius.all(Radius.circular(10)),
//       ),
//
//       width: double.infinity,
//       child: LayoutBuilder(
//         builder: (_, cons) {
//           final w = cons.maxWidth; // عرض در دسترس کارت
//
//           return SingleChildScrollView(
//             scrollDirection: Axis.horizontal,      // 👈 اگر ستون‌ها زیاد شدند، اسکرول افقی
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minWidth: w), // 👈 حداقل عرض = کل عرض کارت
//               child: SingleChildScrollView(            // 👈 اسکرول عمودی جدول
//                 child: Selector<DataProvider, List<Variant>>(
//                   selector: (_, dp) => dp.variants,
//                   builder: (_, items, __) => DataTable(
//                     columnSpacing: defaultPadding,
//                     columns: const [
//                       DataColumn(label: Text('نام ویژگی')),
//                       DataColumn(label: Text('نوع ویژگی')),
//                       DataColumn(label: Text('ویرایش')),
//                       DataColumn(label: Text('حذف')),
//                     ],
//                     rows: List.generate(
//                       items.length,
//                           (i) {
//                         final Variant item = items[i];
//                         return DataRow(
//                           cells: [
//                             DataCell(Text(item.name ?? '')),
//                             DataCell(Text(item.variantTypeId?.name ?? '')),
//                             DataCell(
//                               IconButton(
//                                 onPressed: () async {
//                                   if (await UserSaveHelper.isExpired()) {
//                                     DialogHelper.showExpiredDialog(context);
//                                     return;
//                                   }
//                                   showAddVariantForm(context, item);
//                                 },
//                                 icon: const Icon(Icons.edit, color: Colors.white),
//                               ),
//                             ),
//                             DataCell(
//                               IconButton(
//                                 onPressed: () async {
//                                   if (await UserSaveHelper.isExpired()) {
//                                     DialogHelper.showExpiredDialog(context);
//                                     return;
//                                   }
//                                   context.variantProvider.deleteVariant(item);
//                                 },
//                                 icon: const Icon(Icons.delete, color: Colors.red),
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//
//     );
//   }
// }


import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/variant.dart';
import '../../../utility/constants.dart';
import 'add_variant_form.dart';

class VariantsListSection extends StatefulWidget {
  const VariantsListSection({Key? key}) : super(key: key);

  @override
  State<VariantsListSection> createState() => _VariantsListSectionState();
}

class _VariantsListSectionState extends State<VariantsListSection> {
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
    final loading = dp.isVariantsLoading;
    final loadingMore = dp.isVariantsLoadingMore;
    final hasMore = dp.hasMoreVariants;

    if (!hasMore || loading || loadingMore) return;

    if (pixels >= maxExtent - 220) {
      dp.loadMoreVariants();
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
          DataCell(_shimmerBox(w: 180, h: 14)),
          DataCell(_shimmerBox(w: 140, h: 14)),
          DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
          DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
        ],
      );
    });
  }

  _VariantsViewState _select(DataProvider dp) => _VariantsViewState(
    dp.variants,
    dp.isVariantsLoading,
    dp.isVariantsLoadingMore,
    dp.hasMoreVariants,
  );

  @override
  Widget build(BuildContext context) {
    return Selector<DataProvider, _VariantsViewState>(
      selector: (_, dp) => _select(dp),
      builder: (_, st, __) {
        final items = st.items;
        final loading = st.loading;
        final loadingMore = st.loadingMore;
        final hasMore = st.hasMore;

        return Container(
          padding: const EdgeInsets.all(defaultPadding),
          decoration: const BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          width: double.infinity,
          child: LayoutBuilder(
            builder: (_, cons) {
              final w = cons.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: w),
                  child: SingleChildScrollView(
                    controller: _innerCtrl, // ✅ فقط کنترلر اضافه شد
                    child: DataTable(
                      columnSpacing: defaultPadding,
                      columns: const [
                        DataColumn(label: Text('نام ویژگی')),
                        DataColumn(label: Text('نوع ویژگی')),
                        DataColumn(label: Text('ویرایش')),
                        DataColumn(label: Text('حذف')),
                      ],
                      rows: [
                        // ✅ لود اولیه: shimmer
                        if (loading && items.isEmpty) ..._buildShimmerRows(10),

                        // ✅ دیتا
                        if (!(loading && items.isEmpty))
                          ...List.generate(items.length, (i) {
                            final Variant item = items[i];
                            return DataRow(
                              cells: [
                                DataCell(Text(item.name ?? '')),
                                DataCell(Text(item.variantTypeId?.name ?? '')),
                                DataCell(
                                  IconButton(
                                    onPressed: () async {
                                      if (await UserSaveHelper.isExpired()) {
                                        DialogHelper.showExpiredDialog(context);
                                        return;
                                      }
                                      showAddVariantForm(context, item);
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
                                      context.variantProvider.deleteVariant(item);
                                    },
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          }),

                        // ✅ لود بیشتر: shimmer row پایین
                        if (loadingMore)
                          DataRow(
                            cells: [
                              DataCell(_shimmerBox(w: 180, h: 14)),
                              DataCell(_shimmerBox(w: 140, h: 14)),
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
}

class _VariantsViewState {
  final List<Variant> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;

  const _VariantsViewState(this.items, this.loading, this.loadingMore, this.hasMore);

  @override
  bool operator ==(Object other) {
    return other is _VariantsViewState &&
        identical(items, other.items) &&
        loading == other.loading &&
        loadingMore == other.loadingMore &&
        hasMore == other.hasMore;
  }

  @override
  int get hashCode => Object.hash(items, loading, loadingMore, hasMore);
}
