
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/poster.dart';
import '../../../utility/constants.dart';
import 'add_poster_form.dart';

class PosterListSection extends StatelessWidget {
  const PosterListSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // لیست پوسترها فقط هنگام تغییر خود لیست، باعث ریبیلد می‌شود

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      width: double.infinity,
      // child: DataTable(
      //   columnSpacing: defaultPadding,
      //   columns: const [
      //     DataColumn(label: Text('عنوان پوستر')),
      //     DataColumn(label: Text('تصویر')),
      //     DataColumn(label: Text('ویرایش')),
      //     DataColumn(label: Text('حذف')),
      //   ],
      //   rows: List.generate(
      //     data.posters.length,
      //         (index) => _row(context, data.posters[index]),
      //   ),
      // ),
      child: LayoutBuilder(
        builder: (_, cons) {
          final w = cons.maxWidth; // عرض واقعی کارت/کنتینر
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,                  // 👈 اسکرول افقی در صورت نیاز
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: w),        // 👈 جدول حداقل = کل عرض
              child: SingleChildScrollView(                    // 👈 اسکرول عمودی مثل قبل
                child: Selector<DataProvider, List<Poster>>(
                  selector: (_, dp) => dp.posters,
                  builder: (_, posters, __) => DataTable(
                    columnSpacing: defaultPadding,
                    columns: const [
                      DataColumn(label: Text('عنوان پوستر')),
                      DataColumn(label: Text('تصویر')),
                      DataColumn(label: Text('ویرایش')),
                      DataColumn(label: Text('حذف')),
                    ],
                    rows: List.generate(
                      posters.length,
                          (index) => _row(context, posters[index]),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),

    );
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
              final ok = await context.posterProvider.deletePoster(p);
              if (ok && context.mounted) {
                // عملیات تازه‌سازی در provider انجام می‌شود
              }
            },
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ),
      ],
    );
  }
}
