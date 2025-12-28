// lib/core/data/appwrite/variants_repository.dart

import 'package:appwrite/appwrite.dart' show Query;
import 'package:admin/config/environment.dart';
import 'package:admin/config/network/api_result.dart';
import 'package:admin/models/variant.dart';

import 'base_crud_repository.dart';

// class VariantsRepository extends BaseCrudRepository<Variant> {
//   VariantsRepository()
//       : super(
//     collectionId: Environment.collectionIdVariants,
//     fromJson: (json) => Variant.fromJson(json),
//     toJson: (v) => v.toJson(),
//   );
//
//   Future<ApiResult<List<Variant>>> getByPhoneNumberCode(String phone) {
//     return getAll(
//       queries: [
//         Query.equal('phone_number_code', phone),
//       ],
//     );
//   }
// }


// lib/core/data/appwrite/variants_repository.dart

import 'package:appwrite/appwrite.dart' show Query;
import 'package:admin/config/environment.dart';
import 'package:admin/config/network/api_result.dart';
import 'package:admin/models/variant.dart';

import 'base_crud_repository.dart';

class VariantsRepository extends BaseCrudRepository<Variant> {
  VariantsRepository()
      : super(
    collectionId: Environment.collectionIdVariants,
    fromJson: (json) => Variant.fromJson(json),
    toJson: (v) => v.toJson(),
  );

  Future<ApiResult<List<Variant>>> getByPhoneNumberCode(String phone) {
    return getAll(
      queries: [
        Query.equal('phone_number_code', phone),
      ],
    );
  }

  /// ✅ Paging برای جدول (Infinite scroll)
  Future<ApiResult<List<Variant>>> getPagedByPhoneNumberCode(
      String phone, {
        required int limit,
        String? cursorAfter,
      }) {
    final queries = <String>[
      Query.equal('phone_number_code', phone),
      Query.orderDesc(r'$updatedAt'), // یا $createdAt اگر خواستی مثل ساب‌کتگوری
      Query.limit(limit),
    ];

    final c = (cursorAfter ?? '').trim();
    if (c.isNotEmpty) {
      queries.add(Query.cursorAfter(c));
    }

    return getAll(queries: queries);
  }
}
