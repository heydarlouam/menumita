// lib/core/data/appwrite/poster_appwrite_service.dart

import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;

import 'package:admin/config/environment.dart';
import 'package:admin/config/network/appwrite_client.dart';
import 'package:admin/config/network/api_result.dart';
import 'package:admin/config/network/request_executor.dart';
import 'package:admin/models/poster.dart';

class PosterAppwriteService {
  PosterAppwriteService();

  final RequestExecutor _executor = RequestExecutor();

  Databases get _db => AppwriteClient.instance.databases;
  Storage get _storage => Storage(AppwriteClient.instance.client);

  // ... create/update/delete همان قبلی ...

  /// ✅ نسخه paging شده (مثل subcategories)
  Future<ApiResult<List<Poster>>> getPagedByPhoneNumberCode(
      String phoneNumberCode, {
        required int limit,
        String? cursorAfter,
      }) {
    return _executor.execute<List<Poster>>(
          () async {
        final queries = <String>[
          Query.equal('phone_number_code', phoneNumberCode),
          Query.orderDesc(r'$createdAt'), // مثل ساب‌کتگوری
          Query.limit(limit),
        ];

        final c = (cursorAfter ?? '').trim();
        if (c.isNotEmpty) {
          queries.add(Query.cursorAfter(c));
        }

        final res = await _db.listDocuments(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdPosters,
          queries: queries,
        );

        final posters = res.documents.map((doc) {
          final map = <String, dynamic>{
            ...doc.data,
            r'$id': doc.$id,
            r'$createdAt': doc.$createdAt,
            r'$updatedAt': doc.$updatedAt,
          };
          return Poster.fromJson(map);
        }).toList();

        return posters;
      },
      label: 'GET posters paged',
    );
  }

  // ✅ متد قدیمی رو می‌تونی نگه داری (اختیاری)
  Future<ApiResult<List<Poster>>> getPostersByPhoneNumberCode(String phoneNumberCode) {
    return _executor.execute<List<Poster>>(
          () async {
        final res = await _db.listDocuments(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdPosters,
          queries: [
            Query.equal('phone_number_code', phoneNumberCode),
          ],
        );

        final posters = res.documents.map((doc) {
          final map = <String, dynamic>{
            ...doc.data,
            r'$id': doc.$id,
            r'$createdAt': doc.$createdAt,
            r'$updatedAt': doc.$updatedAt,
          };
          return Poster.fromJson(map);
        }).toList();

        return posters;
      },
      label: 'GET posters by phone_number_code',
    );
  }


  /// ایجاد پوستر همراه با آپلود تصویر
  Future<ApiResult<Poster>> createPosterWithImage({
    required String name,
    required String phoneNumberCode,
    required Uint8List imageBytes,
    required String filename,
  }) {
    return _executor.execute<Poster>(
          () async {
        // ۱) آپلود فایل در باکت پوسترها
        final appwrite_models.File file = await _storage.createFile(
          bucketId: Environment.BucketImages,
          fileId: ID.unique(),
          file: InputFile.fromBytes(
            bytes: imageBytes,
            filename: filename,
          ),
        );

        // ۲) ساخت URL تصویر
        final imageUrl =
            '${Environment.appwriteEndpoint}/storage/buckets/${Environment.BucketImages}/files/${file.$id}/view?project=${Environment.appwriteProjectId}';

        // ۳) ایجاد داکیومنت پوستر
        final doc = await _db.createDocument(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdPosters,
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

        return Poster.fromJson(map);
      },
      label: 'CREATE poster with image',
    );
  }

  /// آپدیت پوستر:
  /// اگر imageBytes != null → تصویر جدید آپلود می‌شود و بعد از موفقیت، تصویر قبلی حذف می‌شود.
  Future<ApiResult<Poster>> updatePoster({
    required String documentId,
    required String name,
    required String phoneNumberCode,
    Uint8List? imageBytes,
    String? filename,
    String? existingImageUrl,
  }) {
    return _executor.execute<Poster>(
          () async {
        // ۱) استخراج fileId تصویر قبلی
        final String? oldFileId = _extractFileIdFromUrl(existingImageUrl);

        String? finalImageUrl = existingImageUrl;

        // ۲) اگر تصویر جدید داریم، آپلود و ساخت URL جدید
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

        // ۳) آماده‌سازی دیتا
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
          collectionId: Environment.collectionIdPosters,
          documentId: documentId,
          data: data,
        );

        // ۵) اگر تصویر جدید آپلود شده و تصویر قبلی داشتیم → حذف فایل قبلی
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

        return Poster.fromJson(map);
      },
      label: 'UPDATE poster',
    );
  }

  /// حذف پوستر + حذف تصویر
  Future<ApiResult<void>> deletePoster({
    required String documentId,
    String? existingImageUrl,
  }) {
    return _executor.execute<void>(
          () async {
        final String? oldFileId = _extractFileIdFromUrl(existingImageUrl);

        await _db.deleteDocument(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdPosters,
          documentId: documentId,
        );

        if (oldFileId != null && oldFileId.isNotEmpty) {
          await _safeDeleteOldFile(oldFileId);
        }

        return null;
      },
      label: 'DELETE poster',
    );
  }



  /// Helpers
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
    } catch (_) {
      // اگر حذف فایل خطا داد، نمی‌گذاریم کل عملیات fail شود
    }
  }
}
