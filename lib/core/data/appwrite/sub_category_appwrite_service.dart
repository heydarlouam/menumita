// lib/core/data/appwrite/sub_category_appwrite_service.dart

import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;

import 'package:admin/config/environment.dart';
import 'package:admin/models/sub_category.dart';
import 'package:flutter/foundation.dart';

import '../../../config/network/api_result.dart';
import '../../../config/network/appwrite_client.dart';
import '../../../config/network/request_executor.dart';

// class SubCategoryAppwriteService {
//   final RequestExecutor _executor = RequestExecutor();
//
//   Databases get _db => AppwriteClient.instance.databases;
//
//   /// ایجاد زیر‌دسته
//   Future<ApiResult<SubCategory>> createSubCategory({
//     required String name,
//     required String phoneNumberCode,
//     required String categoryId,
//   }) {
//     return _executor.execute<SubCategory>(
//           () async {
//         final doc = await _db.createDocument(
//           databaseId: Environment.databaseIdMenuMita,
//           collectionId: Environment.collectionIdSubcategories,
//           documentId: ID.unique(),
//           data: <String, dynamic>{
//             'name': name,
//             'phone_number_code': phoneNumberCode,
//             // در Appwrite رابطه Many-to-many با category
//             'categories': [categoryId],
//           },
//         );
//
//         final map = <String, dynamic>{
//           ...doc.data,
//           r'$id': doc.$id,
//           r'$createdAt': doc.$createdAt,
//           r'$updatedAt': doc.$updatedAt,
//         };
//
//         return SubCategory.fromJson(map);
//       },
//       label: 'CREATE subcategory',
//     );
//   }
//
//   /// ویرایش زیر‌دسته
//   Future<ApiResult<SubCategory>> updateSubCategory({
//     required String documentId,
//     required String name,
//     required String phoneNumberCode,
//     required String categoryId,
//   }) {
//     return _executor.execute<SubCategory>(
//           () async {
//         final doc = await _db.updateDocument(
//           databaseId: Environment.databaseIdMenuMita,
//           collectionId: Environment.collectionIdSubcategories,
//           documentId: documentId,
//           data: <String, dynamic>{
//             'name': name,
//             'phone_number_code': phoneNumberCode,
//             'categories': [categoryId],
//           },
//         );
//
//         final map = <String, dynamic>{
//           ...doc.data,
//           r'$id': doc.$id,
//           r'$createdAt': doc.$createdAt,
//           r'$updatedAt': doc.$updatedAt,
//         };
//
//         return SubCategory.fromJson(map);
//       },
//       label: 'UPDATE subcategory',
//     );
//   }
//
//   /// حذف زیر‌دسته
//   Future<ApiResult<void>> deleteSubCategory({
//     required String documentId,
//   }) {
//     return _executor.execute<void>(
//           () async {
//         await _db.deleteDocument(
//           databaseId: Environment.databaseIdMenuMita,
//           collectionId: Environment.collectionIdSubcategories,
//           documentId: documentId,
//         );
//         return null;
//       },
//       label: 'DELETE subcategory',
//     );
//   }
//
//   /// گرفتن همه زیر‌دسته‌ها برای یک phone_number_code
//
// // lib/core/data/appwrite/sub_category_appwrite_service.dart
//
//   Future<ApiResult<List<SubCategory>>> getByPhoneNumberCode(
//       String phoneNumberCode,
//       ) async {
//     return _executor.execute<List<SubCategory>>(
//           () async {
//         // گرفتن subcategoryها
//         final res = await _db.listDocuments(
//           databaseId: Environment.databaseIdMenuMita,
//           collectionId: Environment.collectionIdSubcategories,
//           queries: [
//             Query.equal('phone_number_code', phoneNumberCode),
//           ],
//         );
//
//         // جمع‌آوری همه IDهای category
//         final categoryIds = <String>{};
//         final subcategories = res.documents.map((doc) {
//           final sub = SubCategory.fromJson({
//             ...doc.data,
//             r'$id': doc.$id,
//             r'$createdAt': doc.$createdAt,
//             r'$updatedAt': doc.$updatedAt,
//           });
//
//           if (sub.category != null) {
//             categoryIds.add(sub.category!);
//           }
//           return sub;
//         }).toList();
//
//         // گرفتن همه categoryها در یک بار
//         final categories = <String, CategoryId>{};
//         for (final catId in categoryIds) {
//           try {
//             final catDoc = await _db.getDocument(
//               databaseId: Environment.databaseIdMenuMita,
//               collectionId: 'categories',
//               documentId: catId,
//             );
//
//             categories[catId] = CategoryId.fromJson({
//               ...catDoc.data,
//               r'$id': catDoc.$id,
//             });
//           } catch (e) {
//             print('خطا در گرفتن category $catId: $e');
//           }
//         }
//
//         // مپ کردن categoryها به subcategoryها
//         for (final sub in subcategories) {
//           if (sub.category != null && categories.containsKey(sub.category)) {
//             sub.categoryId = categories[sub.category!];
//           }
//         }
//
//         return subcategories;
//       },
//       label: 'GET subcategories',
//     );
//   }
// }



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

  /// گرفتن همه زیر‌دسته‌ها برای یک phone_number_code
  Future<ApiResult<List<SubCategory>>> getByPhoneNumberCode(
      String phoneNumberCode,
      ) async {
    return _executor.execute<List<SubCategory>>(
          () async {
        // گرفتن subcategoryها
        final res = await _db.listDocuments(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdSubcategories,
          queries: [
            Query.equal('phone_number_code', phoneNumberCode),
          ],
        );

        // جمع‌آوری همه IDهای category
        final categoryIds = <String>{};

        final subcategories = res.documents.map((doc) {
          final map = <String, dynamic>{
            ...doc.data,
            r'$id': doc.$id,
            r'$createdAt': doc.$createdAt,
            r'$updatedAt': doc.$updatedAt,
          };

          final sub = SubCategory.fromJson(map);

          // مرجع اصلی (بعد از آپدیت مدل) => sub.category
          if (sub.category != null) {
            categoryIds.add(sub.category!);
          }
          return sub;
        }).toList();

        // گرفتن همه categoryها در یک بار (به صورت loop اما با cache)
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
          } catch (_) {
            // اگر دسته‌بندی حذف شده/نباشد، فقط مپ نمی‌کنیم
          }
        }

        // مپ کردن categoryها به subcategoryها
        for (final sub in subcategories) {
          final catId = sub.category;
          if (catId != null && categories.containsKey(catId)) {
            sub.categoryId = categories[catId];
          }
        }

        return subcategories;
      },
      label: 'GET subcategories',
    );
  }
}
