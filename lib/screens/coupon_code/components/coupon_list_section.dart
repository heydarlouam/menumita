import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/coupon.dart';
import '../../../utility/color_list.dart';
import '../../../utility/constants.dart';
import 'add_coupon_form.dart';


// class CouponListSection extends StatelessWidget {
//   const CouponListSection({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(defaultPadding),
//       decoration: const BoxDecoration(
//         color: secondaryColor,
//         borderRadius: BorderRadius.all(Radius.circular(10)),
//       ),
//       child: SizedBox(
//         width: double.infinity,
//         child: Consumer<DataProvider>(
//           builder: (context, dataProvider, _) {
//             return DataTable(
//               columnSpacing: defaultPadding,
//               columns: const [
//                 DataColumn(label: Text("Coupon Name")),
//                 DataColumn(label: Text("Status")),
//                 DataColumn(label: Text("Type")),
//                 DataColumn(label: Text("Amount")),
//                 DataColumn(label: Text("Edit")),
//                 DataColumn(label: Text("Delete")),
//               ],
//               rows: List.generate(
//                 dataProvider.coupons.length,
//                     (index) => _couponDataRow(
//                   context,
//                   dataProvider.coupons[index],
//                   index + 1,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   DataRow _couponDataRow(BuildContext context, Coupon coupon, int index) {
//     return DataRow(
//       cells: [
//         DataCell(
//           Row(
//             children: [
//               Container(
//                 height: 24,
//                 width: 24,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: colors[index % colors.length],
//                   shape: BoxShape.circle,
//                 ),
//                 child: Text('$index', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
//               ),
//               const SizedBox(width: defaultPadding),
//               Text(coupon.couponCode ?? ''),
//             ],
//           ),
//         ),
//         DataCell(Text(coupon.status ?? '')),
//         DataCell(Text(coupon.discountType ?? '')),
//         DataCell(Text('${coupon.discountAmount ?? ''}')),
//         DataCell(
//           IconButton(
//             onPressed: () => showAddCouponForm(context, coupon),
//             icon: const Icon(Icons.edit, color: Colors.white),
//           ),
//         ),
//         DataCell(
//           IconButton(
//             onPressed: () => context.couponCodeProvider.deleteCoupon(coupon),
//             icon: const Icon(Icons.delete, color: Colors.red),
//           ),
//         ),
//       ],
//     );
//   }
// }

// lib/screens/coupon_code/components/coupon_list_section.dart
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/coupon.dart';
import '../../../utility/color_list.dart';
import '../../../utility/constants.dart';
import 'add_coupon_form.dart';

class CouponListSection extends StatelessWidget {
  const CouponListSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Selector<DataProvider, List<Coupon>>(
          selector: (_, dp) => dp.coupons,
          builder: (context, coupons, _) {
            return DataTable(
              columnSpacing: defaultPadding,
              columns: const [
                DataColumn(label: Text("Coupon Name")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Type")),
                DataColumn(label: Text("Amount")),
                DataColumn(label: Text("Edit")),
                DataColumn(label: Text("Delete")),
              ],
              rows: List.generate(
                coupons.length,
                    (index) => _couponDataRow(
                  context,
                  coupons[index],
                  index + 1,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  DataRow _couponDataRow(BuildContext context, Coupon coupon, int index) {
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
                child: Text('$index', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: defaultPadding),
              Text(coupon.couponCode ?? ''),
            ],
          ),
        ),
        DataCell(Text(coupon.status ?? '')),
        DataCell(Text(coupon.discountType ?? '')),
        DataCell(Text('${coupon.discountAmount ?? ''}')),
        DataCell(
          IconButton(
            onPressed: () => showAddCouponForm(context, coupon),
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ),
        DataCell(
          IconButton(
            onPressed: () => context.couponCodeProvider.deleteCoupon(coupon),
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ),
      ],
    );
  }
}
