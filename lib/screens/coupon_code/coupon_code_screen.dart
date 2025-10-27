import 'package:admin/screens/profile_card.dart';
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utility/constants.dart';
import 'components/add_coupon_form.dart';
import 'components/coupon_code_header.dart';
import 'components/coupon_list_section.dart';

// class CouponCodeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: SingleChildScrollView(
//         primary: false,
//         padding: EdgeInsets.all(defaultPadding),
//         child: Column(
//           children: [
//             CouponCodeHeader(),
//             Gap(defaultPadding),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   flex: 5,
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               "My Coupons",
//                               style: Theme.of(context).textTheme.titleMedium,
//                             ),
//                           ),
//                           ElevatedButton.icon(
//                             style: TextButton.styleFrom(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: defaultPadding * 1.5,
//                                 vertical: defaultPadding,
//                               ),
//                             ),
//                             onPressed: () {
//                               showAddCouponForm(context, null);
//                             },
//                             icon: Icon(Icons.add),
//                             label: Text("Create Coupon"),
//                           ),
//                           Gap(20),
//                           IconButton(
//                               onPressed: () {
//                                 context.dataProvider
//                                     .getAllCoupons(showSnack: true);
//                               },
//                               icon: Icon(Icons.refresh)),
//                         ],
//                       ),
//                       Gap(defaultPadding),
//                       CouponListSection(),
//                     ],
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:admin/utility/extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
//
// import '../../utility/constants.dart';
// import 'components/add_coupon_form.dart';
// import 'components/coupon_code_header.dart';
// import 'components/coupon_list_section.dart';

class CouponCodeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            CouponCodeHeader(),
            Gap(defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () async {
                              if (await UserSaveHelper.isExpired()) {
                                DialogHelper.showExpiredDialog(context);
                                return;
                              }
                              context.dataProvider
                                  .getAllCoupons(showSnack: true);
                            },

                            icon: Icon(Icons.refresh),
                            tooltip: "تازه‌سازی لیست کوپن‌ها",
                          ),
                          ElevatedButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: defaultPadding * 1.5,
                                vertical: defaultPadding,
                              ),
                            ),

                            onPressed: () async {
                              if (await UserSaveHelper.isExpired()) {
                                DialogHelper.showExpiredDialog(context);
                                return;
                              }
                              showAddCouponForm(context, null);
                            },
                            icon: Icon(Icons.add),
                            label: Text("ایجاد کوپن"),
                          ),
                        //  Gap(20),

                          const SizedBox(width: 12),
                          const Expanded(child: ProfileCard()),
                        ],
                      ),
                      Gap(defaultPadding),
                      CouponListSection(),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
