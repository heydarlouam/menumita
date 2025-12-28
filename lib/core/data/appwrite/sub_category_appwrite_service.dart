// lib/core/data/appwrite/sub_category_appwrite_service.dart


import 'package:appwrite/appwrite.dart';

import 'package:admin/config/environment.dart';
import 'package:admin/models/sub_category.dart';


import '../../../config/network/api_result.dart';
import '../../../config/network/appwrite_client.dart';
import '../../../config/network/request_executor.dart';


class SubCategoryAppwriteService {
  final RequestExecutor _executor = RequestExecutor();

  Databases get _db => AppwriteClient.instance.databases;

  /// ایجاد زیر‌دسته
  Future<ApiResult<SubCategory>> createSubCategory({
    required String name,
    required String phoneNumberCode,
    required String categoryId,
  }) {
    return _executor.execute<SubCategory>(
          () async {
        final doc = await _db.createDocument(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdSubcategories,
          documentId: ID.unique(),
          data: <String, dynamic>{
            'name': name,
            'phone_number_code': phoneNumberCode,
            // در Appwrite رابطه Many-to-many با category (ولی در UI تک‌انتخابی است)
            'categories': [categoryId],
            // ✅ ستون کمکی برای سینک تک‌کتگوری
            'categories_id': categoryId,
          },
        );

        final map = <String, dynamic>{
          ...doc.data,
          r'$id': doc.$id,
          r'$createdAt': doc.$createdAt,
          r'$updatedAt': doc.$updatedAt,
        };

        return SubCategory.fromJson(map);
      },
      label: 'CREATE subcategory',
    );
  }

  /// ویرایش زیر‌دسته
  Future<ApiResult<SubCategory>> updateSubCategory({
    required String documentId,
    required String name,
    required String phoneNumberCode,
    required String categoryId,
  }) {
    return _executor.execute<SubCategory>(
          () async {
        final doc = await _db.updateDocument(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdSubcategories,
          documentId: documentId,
          data: <String, dynamic>{
            'name': name,
            'phone_number_code': phoneNumberCode,
            'categories': [categoryId],
            // ✅ ستون کمکی برای سینک تک‌کتگوری
            'categories_id': categoryId,
          },
        );

        final map = <String, dynamic>{
          ...doc.data,
          r'$id': doc.$id,
          r'$createdAt': doc.$createdAt,
          r'$updatedAt': doc.$updatedAt,
        };

        return SubCategory.fromJson(map);
      },
      label: 'UPDATE subcategory',
    );
  }

  /// حذف زیر‌دسته
  Future<ApiResult<void>> deleteSubCategory({
    required String documentId,
  }) {
    return _executor.execute<void>(
          () async {
        await _db.deleteDocument(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdSubcategories,
          documentId: documentId,
        );
        return null;
      },
      label: 'DELETE subcategory',
    );
  }

  /// ✅ نسخه paging شده (مثل categories/brands)
  Future<ApiResult<List<SubCategory>>> getPagedByPhoneNumberCode(
      String phoneNumberCode, {
        required int limit,
        String? cursorAfter,
      }) {
    return _executor.execute<List<SubCategory>>(
          () async {
        final queries = <String>[
          Query.equal('phone_number_code', phoneNumberCode),
          Query.orderDesc(r'$createdAt'),
          Query.limit(limit),
        ];
        if (cursorAfter != null && cursorAfter.trim().isNotEmpty) {
          queries.add(Query.cursorAfter(cursorAfter.trim()));
        }

        final res = await _db.listDocuments(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdSubcategories,
          queries: queries,
        );

        // --- map to model ---
        final categoryIds = <String>{};

        final subs = res.documents.map((doc) {
          final map = <String, dynamic>{
            ...doc.data,
            r'$id': doc.$id,
            r'$createdAt': doc.$createdAt,
            r'$updatedAt': doc.$updatedAt,
          };

          final sub = SubCategory.fromJson(map);
          if (sub.category != null && sub.category!.trim().isNotEmpty) {
            categoryIds.add(sub.category!.trim());
          }
          return sub;
        }).toList();

        // --- fetch categories for this page only (برای نمایش نام category) ---
        final categories = <String, CategoryId>{};
        for (final catId in categoryIds) {
          try {
            final catDoc = await _db.getDocument(
              databaseId: Environment.databaseIdMenuMita,
              collectionId: Environment.collectionIdCategories,
              documentId: catId,
            );

            categories[catId] = CategoryId.fromJson({
              ...catDoc.data,
              r'$id': catDoc.$id,
            });
          } catch (_) {}
        }

        // --- hydrate ---
        for (final sub in subs) {
          final catId = sub.category;
          if (catId != null && categories.containsKey(catId)) {
            sub.categoryId = categories[catId];
          }
        }

        return subs;
      },
      label: 'GET subcategories paged',
    );
  }
  /// ✅ گرفتن یک SubCategory با id (برای edit وقتی paging هست)
  Future<ApiResult<SubCategory>> getById(String documentId) {
    return _executor.execute<SubCategory>(
          () async {
        final doc = await _db.getDocument(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdSubcategories,
          documentId: documentId,
        );

        final map = <String, dynamic>{
          ...doc.data,
          r'$id': doc.$id,
          r'$createdAt': doc.$createdAt,
          r'$updatedAt': doc.$updatedAt,
        };

        return SubCategory.fromJson(map);
      },
      label: 'GET subcategory by id',
    );
  }




}
