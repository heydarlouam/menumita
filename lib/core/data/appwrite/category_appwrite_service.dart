// lib/core/data/appwrite/category_appwrite_service.dart

import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;

import 'package:admin/config/environment.dart';

import 'package:admin/models/category.dart';

import '../../../config/network/api_result.dart';
import '../../../config/network/appwrite_client.dart';
import '../../../config/network/request_executor.dart';


class CategoryAppwriteService {
  CategoryAppwriteService();

  final RequestExecutor _executor = RequestExecutor();

  Databases get _db => AppwriteClient.instance.databases;

  Storage get _storage => Storage(AppwriteClient.instance.client);

  /// ۱) آپلود عکس در باکت IMGCategories
  /// ۲) ساختن Category در collection categories
  Future<ApiResult<Category>> createCategoryWithImage({
    required String name,
    required String phoneNumberCode,
    required Uint8List imageBytes,
    required String filename,
  }) {
    return _executor.execute<Category>(
          () async {
        // ۱) آپلود فایل
        final appwrite_models.File file = await _storage.createFile(
          bucketId: Environment.BucketImages,
          fileId: ID.unique(),
          file: InputFile.fromBytes(
            bytes: imageBytes,
            filename: filename,
          ),
        );

        // ۲) ساخت URL تصویر (برای Image.network)
        final imageUrl =
            '${Environment.appwriteEndpoint}/storage/buckets/${Environment.BucketImages}/files/${file.$id}/view?project=${Environment.appwriteProjectId}';

        // ۳) ساخت داکیومنت کتگوری در دیتابیس
        final doc = await _db.createDocument(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdCategories,
          documentId: ID.unique(),
          data: <String, dynamic>{
            'name': name,
            'imageUrl': imageUrl,
            'phone_number_code': phoneNumberCode,
          },
        );

        final map = <String, dynamic>{
          ...doc.data,
          r'$id': doc.$id,
          r'$createdAt': doc.$createdAt,
          r'$updatedAt': doc.$updatedAt,
        };

        return Category.fromJson(map);
      },
      label: 'CREATE category with image',
    );
  }

  /// آپدیت کتگوری:
  /// اگر imageBytes != null → تصویر جدید آپلود می‌شود و imageUrl عوض می‌شود
  /// اگر imageBytes == null → فقط name/phone_number_code آپدیت می‌شود

  /// آپدیت کتگوری:
  /// اگر imageBytes != null → تصویر جدید آپلود می‌شود و imageUrl عوض می‌شود
  /// اگر imageBytes == null → فقط name/phone_number_code آپدیت می‌شود
  Future<ApiResult<Category>> updateCategory({
    required String documentId,
    required String name,
    required String phoneNumberCode,
    Uint8List? imageBytes,
    String? filename,
    String? existingImageUrl,
  }) {
    return _executor.execute<Category>(
          () async {
        // ۱) اگر تصویر قبلی داریم، fileId رو از URL دربیار
        final String? oldFileId = _extractFileIdFromUrl(existingImageUrl);

        String? finalImageUrl = existingImageUrl;

        // ۲) اگر تصویر جدید داریم، آپلود کن و URL جدید بساز
        if (imageBytes != null && filename != null) {
          final appwrite_models.File file = await _storage.createFile(
            bucketId: Environment.BucketImages,
            fileId: ID.unique(),
            file: InputFile.fromBytes(
              bytes: imageBytes,
              filename: filename,
            ),
          );

          finalImageUrl =
          '${Environment.appwriteEndpoint}/storage/buckets/${Environment.BucketImages}/files/${file.$id}/view?project=${Environment.appwriteProjectId}';
        }

        // ۳) آماده‌کردن دیتا برای updateDocument
        final data = <String, dynamic>{
          'name': name,
          'phone_number_code': phoneNumberCode,
        };

        if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
          data['imageUrl'] = finalImageUrl;
        }

        // ۴) آپدیت داکیومنت
        final doc = await _db.updateDocument(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdCategories,
          documentId: documentId,
          data: data,
        );

        // ۵) اگر تصویر جدید آپلود شده بود و تصویر قبلی داشتیم → فایل قبلی رو حذف کن
        if (imageBytes != null &&
            filename != null &&
            oldFileId != null &&
            oldFileId.isNotEmpty) {
          await _safeDeleteOldFile(oldFileId);
        }

        final map = <String, dynamic>{
          ...doc.data,
          r'$id': doc.$id,
          r'$createdAt': doc.$createdAt,
          r'$updatedAt': doc.$updatedAt,
        };

        return Category.fromJson(map);
      },
      label: 'UPDATE category',
    );
  }


  /// استخراج fileId از URL تصویر Appwrite
  /// ساختار: .../storage/buckets/{bucketId}/files/{fileId}/view?...
  String? _extractFileIdFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final filesIndex = segments.indexOf('files');
      if (filesIndex == -1 || filesIndex + 1 >= segments.length) {
        return null;
      }
      return segments[filesIndex + 1];
    } catch (_) {
      return null;
    }
  }

  Future<void> _safeDeleteOldFile(String fileId) async {
    try {
      await _storage.deleteFile(
        bucketId: Environment.BucketImages,
        fileId: fileId,
      );
    } catch (e) {
      // اینجا عمداً swallow می‌کنیم که اگر حذف فایل fail شد، خود آپدیت کتگوری fail نشه
      // می‌تونی برای دیباگ لاگ هم بگیری
      // debugPrint('Failed to delete old category image: $e');
    }
  }


  /// حذف کتگوری از دیتابیس (فعلاً فایل تصویر رو دست نمی‌زنیم)

  /// حذف کتگوری از دیتابیس و حذف فایل تصویر مربوطه (اگر وجود داشته باشد)
  Future<ApiResult<void>> deleteCategory({
    required String documentId,
    String? existingImageUrl,
  }) {
    return _executor.execute<void>(
          () async {
        // ۱) اگر تصویر قبلی داریم، fileId رو از URL دربیار
        final String? oldFileId = _extractFileIdFromUrl(existingImageUrl);

        // ۲) حذف داکیومنت از دیتابیس
        await _db.deleteDocument(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdCategories,
          documentId: documentId,
        );

        // ۳) اگر fileId معتبر داریم، تلاش برای حذف فایل از باکت
        if (oldFileId != null && oldFileId.isNotEmpty) {
          await _safeDeleteOldFile(oldFileId);
        }

        return null;
      },
      label: 'DELETE category',
    );
  }

}
