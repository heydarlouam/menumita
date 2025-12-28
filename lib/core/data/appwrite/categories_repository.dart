// lib/core/data/appwrite/categories_repository.dart

import 'package:appwrite/appwrite.dart' show Query;
import 'package:admin/config/environment.dart';

import 'base_crud_repository.dart';

import '../../../models/category.dart';
import '../../../config/network/api_result.dart';

// class CategoriesRepository extends BaseCrudRepository<Category> {
//   CategoriesRepository()
//       : super(
//     collectionId: Environment.collectionIdCategories,
//     fromJson: (json) => Category.fromJson(json),
//     // فعلاً برای read استفاده می‌شود؛
//     // برای create/update بعداً تصمیم می‌گیریم از چه ساختاری استفاده کنیم.
//     toJson: (category) => category.toJson(),
//   );
//
//   /// گرفتن دسته‌بندی‌ها بر اساس phone_number_code
//   Future<ApiResult<List<Category>>> getByPhoneNumberCode(
//       String phoneNumberCode,
//       ) {
//     return getAll(
//       queries: [
//         Query.equal('phone_number_code', phoneNumberCode),
//       ],
//     );
//   }
// }


import 'package:appwrite/appwrite.dart' show Query;
import 'package:admin/config/environment.dart';

import 'base_crud_repository.dart';
import '../../../models/category.dart';
import '../../../config/network/api_result.dart';

class CategoriesRepository extends BaseCrudRepository<Category> {
  CategoriesRepository()
      : super(
    collectionId: Environment.collectionIdCategories,
    fromJson: (json) => Category.fromJson(json),
    toJson: (category) => category.toJson(),
  );

  Future<ApiResult<List<Category>>> getByPhoneNumberCode(String phoneNumberCode) {
    return getAll(
      queries: [
        Query.equal('phone_number_code', phoneNumberCode),
      ],
    );
  }

  // ✅ NEW: Pagination (مثل برند)
  Future<ApiResult<List<Category>>> getPagedByPhoneNumberCode(
      String phoneNumberCode, {
        required int limit,
        String? cursorAfter,
      }) {
    final queries = <String>[
      Query.equal('phone_number_code', phoneNumberCode),
      Query.limit(limit),

      // ✅ برای ثبات پیجینگ بهتره ترتیب مشخص باشه
      Query.orderDesc(r'$createdAt'),
    ];

    if (cursorAfter != null && cursorAfter.isNotEmpty) {
      // بعضی نسخه‌ها string می‌گیرن، بعضی‌ها لیست. اگر خطا گرفتی، اینو به [cursorAfter] تغییر بده.
      queries.add(Query.cursorAfter(cursorAfter));
      // queries.add(Query.cursorAfter([cursorAfter]));
    }

    return getAll(queries: queries);
  }
}
