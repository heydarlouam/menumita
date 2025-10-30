// import 'package:admin/utility/extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
//
// import '../../utility/constants.dart';
// import 'components/add_category_form.dart';
// import 'components/category_header.dart';
// import 'components/category_list_section.dart';
//
// class CategoryScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: SingleChildScrollView(
//         primary: false,
//         padding: EdgeInsets.all(defaultPadding),
//         child: Column(
//           children: [
//             CategoryHeader(),
//             SizedBox(height: defaultPadding),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   flex: 5,
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               "My Categories",
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
//                               showAddCategoryForm(context, null, 'Add Category');
//                             },
//                             icon: Icon(Icons.add),
//                             label: Text("Add Category"),
//                           ),
//                           Gap(20),
//                           IconButton(
//                               onPressed: () {
//                                 context.dataProvider
//                                     .getAllCategories(showSnack: true);
//                               },
//                               icon: Icon(Icons.refresh)),
//                         ],
//                       ),
//                       Gap(defaultPadding),
//                       CategoryListSection(),
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
import 'components/add_category_form.dart';
import 'components/category_header.dart';
import 'components/category_list_section.dart';

class CategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            CategoryHeader(),
            SizedBox(height: defaultPadding),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                IconButton(

                  onPressed: () async {
                    if (await UserSaveHelper.isExpired()) {
                      DialogHelper.showExpiredDialog(context);
                      return;
                    }
                    context.dataProvider.getAllCategories(showSnack: true);
                  },


                  icon: const Icon(Icons.refresh),
                  tooltip: 'بروزرسانی',
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal:
           defaultPadding * 1.5,
                      vertical: defaultPadding,
                    ),
                  ),
                  onPressed: () async {
                    if (await UserSaveHelper.isExpired()) {
                      DialogHelper.showExpiredDialog(context);
                      return;
                    }
                    showAddCategoryForm(context, null, 'افزودن دسته‌بندی');
                  },

                  icon: const Icon(Icons.add),
                  label: const Text("افزودن دسته‌بندی"),
                ),

                // ⬇️ اینو اضافه کن تا پروفایل کارت بیاد سمت راست همین ردیف
                const SizedBox(width: 12),
                const Expanded(child: ProfileCard()),
              ],
            ),
                      Gap(defaultPadding),
                      CategoryListSection(),
          ],
        ),
      ),
    );
  }
}


