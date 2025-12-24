// lib/core/data/appwrite/categories_repository.dart

import 'package:appwrite/appwrite.dart' show Query;
import 'package:admin/config/environment.dart';

import '../../../config/network/api_result.dart' as net;
import 'base_crud_repository.dart';
// import '../models/category_model.dart';

// class CategoriesRepository extends BaseCrudRepository<Category> {
//   CategoriesRepository()
//       : super(
//     collectionId: Environment.collectionIdCategories,
//     fromJson: Category.fromJson,
//     toJson: (c) => c.toJson(),
//   );
//
//   /// گرفتن همه‌ی دسته‌بندی‌ها بدون فیلتر
//   Future<net.ApiResult<List<Category>>> getAllCategories() {
//     return getAll();
//   }
//
//   /// گرفتن دسته‌بندی‌ها بر اساس phone_number_code
//   Future<net.ApiResult<List<Category>>> getByPhoneNumberCode(
//       String phoneNumberCode,
//       ) {
//     return getAll(
//       queries: [
//         Query.equal('phone_number_code', phoneNumberCode),
//       ],
//     );
//   }
// }

// lib/core/data/appwrite/categories_repository.dart

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
    // فعلاً برای read استفاده می‌شود؛
    // برای create/update بعداً تصمیم می‌گیریم از چه ساختاری استفاده کنیم.
    toJson: (category) => category.toJson(),
  );

  /// گرفتن دسته‌بندی‌ها بر اساس phone_number_code
  Future<ApiResult<List<Category>>> getByPhoneNumberCode(
      String phoneNumberCode,
      ) {
    return getAll(
      queries: [
        Query.equal('phone_number_code', phoneNumberCode),
      ],
    );
  }
}
