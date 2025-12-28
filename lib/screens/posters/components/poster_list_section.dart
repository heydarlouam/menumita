
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/poster.dart';
import '../../../utility/constants.dart';
import 'add_poster_form.dart';

// class PosterListSection extends StatelessWidget {
//   const PosterListSection({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // لیست پوسترها فقط هنگام تغییر خود لیست، باعث ریبیلد می‌شود
//
//     return Container(
//       padding: const EdgeInsets.all(defaultPadding),
//       decoration: const BoxDecoration(
//         color: secondaryColor,
//         borderRadius: BorderRadius.all(Radius.circular(10)),
//       ),
//       width: double.infinity,
//
//       child: LayoutBuilder(
//         builder: (_, cons) {
//           final w = cons.maxWidth; // عرض واقعی کارت/کنتینر
//           return SingleChildScrollView(
//             scrollDirection: Axis.horizontal,                  // 👈 اسکرول افقی در صورت نیاز
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minWidth: w),        // 👈 جدول حداقل = کل عرض
//               child: SingleChildScrollView(                    // 👈 اسکرول عمودی مثل قبل
//                 child: Selector<DataProvider, List<Poster>>(
//                   selector: (_, dp) => dp.posters,
//                   builder: (_, posters, __) => DataTable(
//                     columnSpacing: defaultPadding,
//                     columns: const [
//                       DataColumn(label: Text('عنوان پوستر')),
//                       DataColumn(label: Text('تصویر')),
//                       DataColumn(label: Text('ویرایش')),
//                       DataColumn(label: Text('حذف')),
//                     ],
//                     rows: List.generate(
//                       posters.length,
//                           (index) => _row(context, posters[index]),
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
//
//   DataRow _row(BuildContext context, Poster p) {
//     return DataRow(
//       cells: [
//         DataCell(Text(p.posterName ?? '')),
//         DataCell(
//           p.imageUrl != null && p.imageUrl!.isNotEmpty
//               ? Image.network(
//             p.imageUrl!,
//             height: 40,
//             width: 60,
//             fit: BoxFit.cover,
//             errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
//           )
//               : const Text('-'),
//         ),
//         DataCell(
//           IconButton(
//             onPressed: () async {
//               if (await UserSaveHelper.isExpired()) {
//                 DialogHelper.showExpiredDialog(context);
//                 return;
//               }
//               showAddPosterForm(context, p);
//             },
//             tooltip: 'ویرایش پوستر',
//
//             icon: const Icon(Icons.edit, color: Colors.white),
//           ),
//         ),
//         DataCell(
//           IconButton(
//             tooltip: 'حذف پوستر',
//
//             onPressed: () async {
//               if (await UserSaveHelper.isExpired()) {
//                 DialogHelper.showExpiredDialog(context);
//                 return;
//               }
//               final ok = await context.posterProvider.deletePoster(p);
//               if (ok && context.mounted) {
//                 // عملیات تازه‌سازی در provider انجام می‌شود
//               }
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
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/poster.dart';
import '../../../utility/constants.dart';
import 'add_poster_form.dart';

class PosterListSection extends StatefulWidget {
  const PosterListSection({Key? key}) : super(key: key);

  @override
  State<PosterListSection> createState() => _PosterListSectionState();
}

class _PosterListSectionState extends State<PosterListSection> {
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
    if (!dp.hasMorePosters || dp.isPostersLoading || dp.isPostersLoadingMore) return;

    if (pixels >= maxExtent - 220) {
      dp.loadMorePosters();
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
    return List.generate(count, (_) {
      return DataRow(
        cells: [
          DataCell(_shimmerBox(w: 180, h: 14)),
          DataCell(_shimmerBox(w: 60, h: 40, r: BorderRadius.circular(6))), // تصویر
          DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
          DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
        ],
      );
    });
  }

  DataRow _row(BuildContext context, Poster p) {
    return DataRow(
      cells: [
        DataCell(Text(p.posterName ?? '')),
        DataCell(
          p.imageUrl != null && p.imageUrl!.isNotEmpty
              ? Image.network(
            p.imageUrl!,
            height: 40,
            width: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          )
              : const Text('-'),
        ),
        DataCell(
          IconButton(
            onPressed: () async {
              if (await UserSaveHelper.isExpired()) {
                DialogHelper.showExpiredDialog(context);
                return;
              }
              showAddPosterForm(context, p);
            },
            tooltip: 'ویرایش پوستر',
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ),
        DataCell(
          IconButton(
            tooltip: 'حذف پوستر',
            onPressed: () async {
              if (await UserSaveHelper.isExpired()) {
                DialogHelper.showExpiredDialog(context);
                return;
              }
              await context.posterProvider.deletePoster(p);
            },
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ),
      ],
    );
  }

  _PostersViewState _select(DataProvider dp) => _PostersViewState(
    dp.posters,
    dp.isPostersLoading,
    dp.isPostersLoadingMore,
    dp.hasMorePosters,
  );

  @override
  Widget build(BuildContext context) {
    return Selector<DataProvider, _PostersViewState>(
      selector: (_, dp) => _select(dp),
      builder: (_, st, __) {
        final posters = st.items;
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
                    controller: _innerCtrl, // ✅ برای load more
                    child: DataTable(
                      columnSpacing: defaultPadding,
                      columns: const [
                        DataColumn(label: Text('عنوان پوستر')),
                        DataColumn(label: Text('تصویر')),
                        DataColumn(label: Text('ویرایش')),
                        DataColumn(label: Text('حذف')),
                      ],
                      rows: [
                        if (loading && posters.isEmpty) ..._buildShimmerRows(10),

                        if (!(loading && posters.isEmpty))
                          ...List.generate(
                            posters.length,
                                (index) => _row(context, posters[index]),
                          ),

                        if (loadingMore)
                          DataRow(
                            cells: [
                              DataCell(_shimmerBox(w: 180, h: 14)),
                              DataCell(_shimmerBox(w: 60, h: 40)),
                              DataCell(_shimmerBox(w: 28, h: 28)),
                              DataCell(_shimmerBox(w: 28, h: 28)),
                            ],
                          ),

                        if (!hasMore && !loading && posters.isNotEmpty)
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

class _PostersViewState {
  final List<Poster> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;

  const _PostersViewState(this.items, this.loading, this.loadingMore, this.hasMore);

  @override
  bool operator ==(Object other) =>
      other is _PostersViewState &&
          identical(items, other.items) &&
          loading == other.loading &&
          loadingMore == other.loadingMore &&
          hasMore == other.hasMore;

  @override
  int get hashCode => Object.hash(items, loading, loadingMore, hasMore);
}
