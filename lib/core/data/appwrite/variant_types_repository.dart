// lib/core/data/appwrite/variant_types_repository.dart

import 'package:appwrite/appwrite.dart' show Query;
import 'package:admin/config/environment.dart';
import 'package:admin/models/variant_type.dart';

import '../../../config/network/api_result.dart';
import 'base_crud_repository.dart';

class VariantTypesRepository extends BaseCrudRepository<VariantType> {
  VariantTypesRepository()
      : super(
    collectionId: Environment.collectionIdVariantTypes,
    fromJson: (json) => VariantType.fromJson(json),
    toJson: (vt) => vt.toJson(),
  );

  Future<ApiResult<List<VariantType>>> getByPhoneNumberCode(String phone) {
    return getAll(
      queries: [
        Query.equal('phone_number_code', phone),
      ],
    );
  }

  /// ✅ Paging برای جدول (Infinite scroll)
  Future<ApiResult<List<VariantType>>> getPagedByPhoneNumberCode(
      String phone, {
        required int limit,
        String? cursorAfter,
      }) {
    final queries = <String>[
      Query.equal('phone_number_code', phone),
      // اگر سمت سرور هم ترتیب داد، عالی؛ اگر نه، داخل Provider مرتب می‌کنیم
      Query.orderDesc(r'$updatedAt'),
      Query.limit(limit),
    ];

    final c = (cursorAfter ?? '').trim();
    if (c.isNotEmpty) {
      queries.add(Query.cursorAfter(c));
    }

    return getAll(queries: queries);
  }
}

