// lib/core/data/appwrite/brands_repository.dart

import 'package:appwrite/appwrite.dart' show Query;
import 'package:admin/config/environment.dart';
import 'package:admin/config/network/api_result.dart';

import 'base_crud_repository.dart';
import 'package:admin/models/brand.dart';


// class BrandsRepository extends BaseCrudRepository<Brand> {
//   BrandsRepository()
//       : super(
//     collectionId: Environment.collectionIdBrands,
//     fromJson: (json) => Brand.fromJson(json),
//     toJson: (brand) => brand.toJson(),
//   );
//
//   Future<ApiResult<List<Brand>>> getAllBrands() => getAll();
//
//   Future<ApiResult<List<Brand>>> getByPhoneNumberCode(String phoneNumberCode) {
//     return getAll(
//       queries: [
//         Query.equal('phone_number_code', phoneNumberCode),
//       ],
//     );
//   }
//
//   /// اگر بعداً خواستی لیست برندها را بر اساس یک ساب‌کتگوری فیلتر کنی
//   /// (برای سازگاری رکوردهای قدیمی، روی relation فیلتر می‌کنیم)
//   Future<ApiResult<List<Brand>>> getBySubcategoryId(
//       String subcategoryId, {
//         String? phoneNumberCode,
//       }) {
//     final queries = <String>[
//       Query.equal('subcategories', subcategoryId),
//     ];
//
//     if (phoneNumberCode != null && phoneNumberCode.trim().isNotEmpty) {
//       queries.add(Query.equal('phone_number_code', phoneNumberCode));
//     }
//
//     return getAll(queries: queries);
//   }
// }

import 'package:appwrite/appwrite.dart' show Query;
// ...

class BrandsRepository extends BaseCrudRepository<Brand> {
  BrandsRepository()
      : super(
    collectionId: Environment.collectionIdBrands,
    fromJson: (json) => Brand.fromJson(json),
    toJson: (brand) => brand.toJson(),
  );

  Future<ApiResult<List<Brand>>> getAllBrands() => getAll();

  Future<ApiResult<List<Brand>>> getByPhoneNumberCode(String phoneNumberCode) {
    return getAll(
      queries: [
        Query.equal('phone_number_code', phoneNumberCode),
      ],
    );
  }

  // ✅ NEW: paging با cursorAfter
  Future<ApiResult<List<Brand>>> getPagedByPhoneNumberCode(
      String phoneNumberCode, {
        required int limit,
        String? cursorAfter,
      }) {
    final queries = <String>[
      Query.equal('phone_number_code', phoneNumberCode),
      Query.orderDesc(r'$updatedAt'),
      Query.limit(limit),
    ];

    if (cursorAfter != null && cursorAfter.trim().isNotEmpty) {
      queries.add(Query.cursorAfter(cursorAfter));
    }

    return getAll(queries: queries);
  }
}
