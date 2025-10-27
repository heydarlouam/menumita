// import 'package:admin/utility/extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
//
// import '../../utility/constants.dart';
// import 'components/add_sub_category_form.dart';
// import 'components/sub_category_header.dart';
// import 'components/sub_category_list_section.dart';
//
// class SubCategoryScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: SingleChildScrollView(
//         primary: false,
//         padding: EdgeInsets.all(defaultPadding),
//         child: Column(
//           children: [
//             SubCategoryHeader(),
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
//                               "My Sub Categories",
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
//                               showAddSubCategoryForm(context, null);
//                             },
//                             icon: Icon(Icons.add),
//                             label: Text("Add Sub Category"),
//                           ),
//                           Gap(20),
//                           IconButton(
//                               onPressed: () {
//                                 context.dataProvider
//                                     .getAllSubCategories(showSnack: true);
//                               },
//                               icon: Icon(Icons.refresh)),
//                         ],
//                       ),
//                       Gap(defaultPadding),
//                       SubCategoryListSection(),
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
import 'components/add_sub_category_form.dart';
import 'components/sub_category_header.dart';
import 'components/sub_category_list_section.dart';

class SubCategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            SubCategoryHeader(),
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
                                  .getAllSubCategories(showSnack: true);
                            },

                            icon: Icon(Icons.refresh),
                            tooltip: "بروزرسانی",
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
                              showAddSubCategoryForm(context, null);
                            },

                            icon: Icon(Icons.add),
                            label: Text("افزودن زیر‌دسته"),
                          ),

                          const SizedBox(width: 12),
                          const Expanded(child: ProfileCard()),
                        ],
                      ),
                      Gap(defaultPadding),
                      SubCategoryListSection(),
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
