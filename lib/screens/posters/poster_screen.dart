// import 'package:admin/utility/extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
//
// import '../../utility/constants.dart';
// import 'components/add_poster_form.dart';
// import 'components/poster_header.dart';
// import 'components/poster_list_section.dart';
//
// class PosterScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: SingleChildScrollView(
//         primary: false,
//         padding: EdgeInsets.all(defaultPadding),
//         child: Column(
//           children: [
//             PosterHeader(),
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
//                               "My Posters",
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
//                               showAddPosterForm(context, null);
//                             },
//                             icon: Icon(Icons.add),
//                             label: Text("Add Poster"),
//                           ),
//                           Gap(20),
//                           IconButton(
//                               onPressed: () {
//                                 context.dataProvider
//                                     .getAllPosters(showSnack: true);
//                               },
//                               icon: Icon(Icons.refresh)),
//                         ],
//                       ),
//                       Gap(defaultPadding),
//                       PosterListSection(),
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
import 'components/add_poster_form.dart';
import 'components/poster_header.dart';
import 'components/poster_list_section.dart';

class PosterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            PosterHeader(),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Expanded(
                          //   child: Text(
                          //     "پوسترهای من",
                          //     style: Theme.of(context).textTheme.titleMedium,
                          //   ),
                          // ),
                          IconButton(
                            tooltip: "بروزرسانی لیست",
                            onPressed: () async {
                              if (await UserSaveHelper.isExpired()) {
                                DialogHelper.showExpiredDialog(context);
                                return;
                              }
                              context.dataProvider
                                  .getAllPosters(showSnack: true);
                            },

                            icon: Icon(Icons.refresh),
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
                              showAddPosterForm(context, null);
                            },

                            icon: Icon(Icons.add),
                            label: Text("افزودن پوستر"),
                          ),
                        //  Gap(20),

                          const SizedBox(width: 12),
                          const Expanded(child: ProfileCard()),
                        ],
                      ),
                      Gap(defaultPadding),
                      PosterListSection(),
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
