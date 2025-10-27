// import 'package:admin/utility/extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
//
// import '../../utility/constants.dart';
// import 'components/add_brand_form.dart';
// import 'components/brand_header.dart';
// import 'components/brand_list_section.dart';
//
// class BrandScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: SingleChildScrollView(
//         primary: false,
//         padding: EdgeInsets.all(defaultPadding),
//         child: Column(
//           children: [
//             BrandHeader(),
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
//                               "My Brands",
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
//                               showAddBrandForm(context, null); // قبلاً: showBrandForm
//                             },
//
//                             icon: Icon(Icons.add),
//                             label: Text("Add Brand"),
//                           ),
//                           Gap(20),
//                           IconButton(
//                               onPressed: () {
//                                 context.dataProvider
//                                     .getAllBrands(showSnack: true);
//                               },
//                               icon: Icon(Icons.refresh)),
//                         ],
//                       ),
//                       Gap(defaultPadding),
//                       BrandListSection(),
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


import 'package:admin/screens/profile_card.dart';
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utility/constants.dart';
import 'components/add_brand_form.dart';
import 'components/brand_header.dart';
import 'components/brand_list_section.dart';

class BrandScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            BrandHeader(),
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
                                  .getAllBrands(showSnack: true);
                            },

                            icon: Icon(Icons.refresh),
                            tooltip: "بروزرسانی",
                          ),
                          // Gap(20),
                  //        const SizedBox(width: 12),
                  //         ElevatedButton.icon(
                  //           style: TextButton.styleFrom(
                  //             padding: EdgeInsets.symmetric(
                  //               horizontal: defaultPadding * 1.5,
                  //               vertical: defaultPadding,
                  //             ),
                  //           ),
                  //           onPressed: () {
                  //             showAddBrandForm(context, null);
                  //           },
                  //           icon: Icon(Icons.add),
                  //           label: Text("افزودن برند"),
                  //         ),
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
                              showAddBrandForm(context, null);
                            },
                            icon: Icon(Icons.add),
                            label: Text("افزودن برند"),
                          ),

                          const SizedBox(width: 12),
                          const Expanded(child: ProfileCard()),
                        ],
                      ),
                      Gap(defaultPadding),
                      BrandListSection(),
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
