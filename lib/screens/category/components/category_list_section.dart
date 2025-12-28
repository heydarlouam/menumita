

import 'package:admin/config/environment.dart';
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../utility/constants.dart';
import '../../../utility/functions.dart';
import 'add_category_form.dart';

// class CategoryListSection extends StatelessWidget {
//   const CategoryListSection({Key? key}) : super(key: key);
//
//   String _imgUrl(String? u) {
//     if (u == null || u.isEmpty) return '';
//     if (u.startsWith('http')) return u;
//     if (u.startsWith('/')) return Environment.appwriteEndpoint + u;
//     return '${Environment.appwriteEndpoint}/$u';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(defaultPadding),
//       decoration: const BoxDecoration(
//         color: secondaryColor,
//         borderRadius: BorderRadius.all(Radius.circular(10)),
//       ),
//
//       child: LayoutBuilder(
//         builder: (_, cons) {
//           final w = cons.maxWidth; // عرض واقعی همین کارت
//           return SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minWidth: w), // حداقل = عرض کارت
//               child: Selector<DataProvider, List<Category>>(
//                 selector: (_, dp) => dp.categories,
//                 builder: (context, categories, child) {
//                   return DataTable(
//                     columnSpacing: defaultPadding,
//                     columns: const [
//                       DataColumn(label: Text("نام دسته‌بندی")),
//                       DataColumn(label: Text("تاریخ افزودن")),
//                       DataColumn(label: Text("ویرایش")),
//                       DataColumn(label: Text("حذف")),
//                     ],
//                     rows: List.generate(
//                       categories.length,
//                           (index) => categoryDataRow(
//                         context,
//                         categories[index],
//                         delete: () {
//                           context.categoryProvider.deleteCategory(categories[index]);
//                         },
//                         edit: () {
//                           showAddCategoryForm(
//                             context,
//                             categories[index],
//                             'ویرایش دسته‌بندی',
//                           );
//                         },
//                         buildImageUrl: _imgUrl,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//
//     );
//   }
// }
//
// DataRow categoryDataRow(
//     BuildContext context,
//     Category catInfo, {
//       required String Function(String?) buildImageUrl,
//       Function? edit,
//       Function? delete,
//     }) {
//   return DataRow(
//     cells: [
//       DataCell(
//         Row(
//           children: [
//             Image.network(
//               buildImageUrl(catInfo.image),
//               height: 30,
//               width: 30,
//               errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
//                 return const Icon(Icons.error);
//               },
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return const SizedBox(
//                   width: 30,
//                   height: 30,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 );
//               },
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
//               child: Text(catInfo.name ?? ''),
//             ),
//           ],
//         ),
//       ),
//       DataCell(Text(formatTimestamp(context, catInfo.createdAt))),
//       DataCell(IconButton(
//
//         onPressed: () async {
//           if (await UserSaveHelper.isExpired()) {
//             DialogHelper.showExpiredDialog(context);
//             return;
//           }
//           edit?.call();
//         },
//
//         icon: const Icon(Icons.edit, color: Colors.white),
//       )),
//       DataCell(IconButton(
//         onPressed: () async {
//           if (await UserSaveHelper.isExpired()) {
//             DialogHelper.showExpiredDialog(context);
//             return;
//           }
//           delete?.call();
//         },
//
//         icon: const Icon(Icons.delete, color: Colors.red),
//       )),
//     ],
//   );
// }
//
// import 'package:admin/config/environment.dart';
// import 'package:admin/utility/User_helper.dart';
// import 'package:admin/utility/dialog_helper.dart';
// import 'package:admin/utility/extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shimmer_animation/shimmer_animation.dart';
//
// import '../../../core/data/data_provider.dart';
// import '../../../models/category.dart';
// import '../../../utility/constants.dart';
// import '../../../utility/functions.dart';
// import 'add_category_form.dart';
//
// class CategoryListSection extends StatelessWidget {
//   const CategoryListSection({Key? key}) : super(key: key);
//
//   String _imgUrl(String? u) {
//     if (u == null || u.isEmpty) return '';
//     if (u.startsWith('http')) return u;
//     if (u.startsWith('/')) return Environment.appwriteEndpoint + u;
//     return '${Environment.appwriteEndpoint}/$u';
//   }
//
//   Widget _shimmerBox({double w = 120, double h = 14, BorderRadius? r}) {
//     return Shimmer(
//       child: Container(
//         width: w,
//         height: h,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade300,
//           borderRadius: r ?? BorderRadius.circular(6),
//         ),
//       ),
//     );
//   }
//
//   List<DataRow> _buildShimmerRows(int count) {
//     return List.generate(count, (_) {
//       return DataRow(
//         cells: [
//           DataCell(
//             Row(
//               children: [
//                 _shimmerBox(w: 30, h: 30, r: BorderRadius.circular(6)),
//                 const SizedBox(width: defaultPadding),
//                 _shimmerBox(w: 140, h: 14),
//               ],
//             ),
//           ),
//           DataCell(_shimmerBox(w: 110, h: 14)),
//           DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
//           DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
//         ],
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final dp = context.watch<DataProvider>();
//
//     final loading = dp.isCategoriesLoading;
//     final loadingMore = dp.isCategoriesLoadingMore;
//     final hasMore = dp.hasMoreCategories;
//
//     return Container(
//       padding: const EdgeInsets.all(defaultPadding),
//       decoration: const BoxDecoration(
//         color: secondaryColor,
//         borderRadius: BorderRadius.all(Radius.circular(10)),
//       ),
//       child: LayoutBuilder(
//         builder: (_, cons) {
//           final w = cons.maxWidth;
//
//           return NotificationListener<ScrollNotification>(
//             onNotification: (scrollInfo) {
//               final dir = scrollInfo.metrics.axisDirection;
//               final isVertical =
//                   dir == AxisDirection.down || dir == AxisDirection.up;
//
//               if (!isVertical) return false;
//
//               if (hasMore &&
//                   !loading &&
//                   !loadingMore &&
//                   scrollInfo.metrics.pixels >=
//                       scrollInfo.metrics.maxScrollExtent - 220) {
//                 dp.loadMoreCategories();
//               }
//               return false;
//             },
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minWidth: w),
//                 child: Consumer<DataProvider>(
//                   builder: (context, dp, _) {
//                     final categories = dp.categories;
//
//                     return DataTable(
//                       columnSpacing: defaultPadding,
//                       columns: const [
//                         DataColumn(label: Text("نام دسته‌بندی")),
//                         DataColumn(label: Text("تاریخ افزودن")),
//                         DataColumn(label: Text("ویرایش")),
//                         DataColumn(label: Text("حذف")),
//                       ],
//                       rows: [
//                         // ✅ لود اولیه: shimmer
//                         if (loading && categories.isEmpty) ..._buildShimmerRows(10),
//
//                         // ✅ دیتا
//                         if (!(loading && categories.isEmpty))
//                           ...List.generate(
//                             categories.length,
//                                 (index) => categoryDataRow(
//                               context,
//                               categories[index],
//                               delete: () {
//                                 context.categoryProvider.deleteCategory(categories[index]);
//                               },
//                               edit: () {
//                                 showAddCategoryForm(
//                                   context,
//                                   categories[index],
//                                   'ویرایش دسته‌بندی',
//                                 );
//                               },
//                               buildImageUrl: _imgUrl,
//                             ),
//                           ),
//
//                         // ✅ لود بیشتر: shimmer پایین جدول
//                         if (loadingMore)
//                           DataRow(
//                             cells: [
//                               DataCell(
//                                 Row(
//                                   children: [
//                                     _shimmerBox(w: 30, h: 30),
//                                     const SizedBox(width: defaultPadding),
//                                     _shimmerBox(w: 140, h: 14),
//                                   ],
//                                 ),
//                               ),
//                               DataCell(_shimmerBox(w: 110, h: 14)),
//                               DataCell(_shimmerBox(w: 28, h: 28)),
//                               DataCell(_shimmerBox(w: 28, h: 28)),
//                             ],
//                           ),
//
//                         // ✅ پایان لیست
//                         if (!hasMore && !loading && categories.isNotEmpty)
//                           const DataRow(
//                             cells: [
//                               DataCell(Text('')),
//                               DataCell(Center(child: Text('پایان لیست'))),
//                               DataCell(Text('')),
//                               DataCell(Text('')),
//                             ],
//                           ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//
//   DataRow categoryDataRow(
//       BuildContext context,
//       Category catInfo, {
//         required String Function(String?) buildImageUrl,
//         Function? edit,
//         Function? delete,
//       }) {
//     return DataRow(
//       cells: [
//         DataCell(
//           Row(
//             children: [
//               Image.network(
//                 buildImageUrl(catInfo.image),
//                 height: 30,
//                 width: 30,
//                 errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
//                   return const Icon(Icons.error);
//                 },
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return const SizedBox(
//                     width: 30,
//                     height: 30,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   );
//                 },
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
//                 child: Text(catInfo.name ?? ''),
//               ),
//             ],
//           ),
//         ),
//         DataCell(Text(formatTimestamp(context, catInfo.createdAt))),
//         DataCell(IconButton(
//
//           onPressed: () async {
//             if (await UserSaveHelper.isExpired()) {
//               DialogHelper.showExpiredDialog(context);
//               return;
//             }
//             edit?.call();
//           },
//
//           icon: const Icon(Icons.edit, color: Colors.white),
//         )),
//         DataCell(IconButton(
//           onPressed: () async {
//             if (await UserSaveHelper.isExpired()) {
//               DialogHelper.showExpiredDialog(context);
//               return;
//             }
//             delete?.call();
//           },
//
//           icon: const Icon(Icons.delete, color: Colors.red),
//         )),
//       ],
//     );
//   }
//
//
// }



import 'package:admin/config/environment.dart';
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../utility/constants.dart';
import '../../../utility/functions.dart';
import 'add_category_form.dart';

class CategoryListSection extends StatefulWidget {
  const CategoryListSection({Key? key}) : super(key: key);

  @override
  State<CategoryListSection> createState() => _CategoryListSectionState();
}

class _CategoryListSectionState extends State<CategoryListSection> {
  ScrollPosition? _outerScrollPos;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ نزدیک‌ترین اسکرولِ ancestor (همون اسکرول عمودی صفحه)
    final pos = Scrollable.of(context)?.position;

    if (pos != null && pos != _outerScrollPos) {
      _outerScrollPos?.removeListener(_onOuterScroll);
      _outerScrollPos = pos;
      _outerScrollPos?.addListener(_onOuterScroll);
    }
  }

  @override
  void dispose() {
    _outerScrollPos?.removeListener(_onOuterScroll);
    super.dispose();
  }

  void _onOuterScroll() {
    if (!mounted) return;
    final dp = context.read<DataProvider>();

    // اگر پیجینگ در حال انجامه یا بیشتر نداریم، هیچی
    if (!dp.hasMoreCategories ||
        dp.isCategoriesLoading ||
        dp.isCategoriesLoadingMore) {
      return;
    }

    final pos = _outerScrollPos;
    if (pos == null) return;

    // ✅ نزدیک انتهای اسکرول صفحه
    if (pos.pixels >= pos.maxScrollExtent - 240) {
      dp.loadMoreCategories();
    }
  }

  String _imgUrl(String? u) {
    if (u == null || u.isEmpty) return '';
    if (u.startsWith('http')) return u;
    if (u.startsWith('/')) return Environment.appwriteEndpoint + u;
    return '${Environment.appwriteEndpoint}/$u';
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
          DataCell(
            Row(
              children: [
                _shimmerBox(w: 30, h: 30, r: BorderRadius.circular(6)),
                const SizedBox(width: defaultPadding),
                _shimmerBox(w: 140, h: 14),
              ],
            ),
          ),
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
    final categories = dp.categories;

    final loading = dp.isCategoriesLoading;
    final loadingMore = dp.isCategoriesLoadingMore;
    final hasMore = dp.hasMoreCategories;

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
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
                  DataColumn(label: Text("نام دسته‌بندی")),
                  DataColumn(label: Text("تاریخ افزودن")),
                  DataColumn(label: Text("ویرایش")),
                  DataColumn(label: Text("حذف")),
                ],
                rows: [
                  // ✅ لود اولیه: shimmer
                  if (loading && categories.isEmpty) ..._buildShimmerRows(10),

                  // ✅ دیتا
                  if (!(loading && categories.isEmpty))
                    ...List.generate(
                      categories.length,
                          (index) => _categoryDataRow(
                        context,
                        categories[index],
                        buildImageUrl: _imgUrl,
                        edit: () {
                          showAddCategoryForm(
                            context,
                            categories[index],
                            'ویرایش دسته‌بندی',
                          );
                        },
                        delete: () {
                          context.categoryProvider.deleteCategory(categories[index]);
                        },
                      ),
                    ),

                  // ✅ لود بیشتر: shimmer پایین جدول
                  if (loadingMore)
                    DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              _shimmerBox(w: 30, h: 30),
                              const SizedBox(width: defaultPadding),
                              _shimmerBox(w: 140, h: 14),
                            ],
                          ),
                        ),
                        DataCell(_shimmerBox(w: 110, h: 14)),
                        DataCell(_shimmerBox(w: 28, h: 28)),
                        DataCell(_shimmerBox(w: 28, h: 28)),
                      ],
                    ),

                  // ✅ پایان لیست
                  if (!hasMore && !loading && categories.isNotEmpty)
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
          );
        },
      ),
    );
  }

  DataRow _categoryDataRow(
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
                errorBuilder: (context, exception, stackTrace) {
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
        DataCell(
          IconButton(
            onPressed: () async {
              if (await UserSaveHelper.isExpired()) {
                DialogHelper.showExpiredDialog(context);
                return;
              }
              edit?.call();
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
              delete?.call();
            },
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ),
      ],
    );
  }
}
