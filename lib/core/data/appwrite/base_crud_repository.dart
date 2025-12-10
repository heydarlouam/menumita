// lib/core/data/appwrite/base_crud_repository.dart

import 'package:admin/config/environment.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;

import '../../../config/ network/api_result.dart';
import '../../../config/ network/appwrite_client.dart';
import '../../../config/ network/request_executor.dart';



typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef ToJson<T> = Map<String, dynamic> Function(T value);

class BaseCrudRepository<T> {
  BaseCrudRepository({
    required this.collectionId,
    required this.fromJson,
    required this.toJson,
    String? databaseId,
    RequestExecutor? executor,
  })  : databaseId = databaseId ?? Environment.databaseIdMenuMita,
        _executor = executor ?? RequestExecutor();

  final String databaseId;
  final String collectionId;
  final FromJson<T> fromJson;
  final ToJson<T> toJson;
  final RequestExecutor _executor;

  Databases get _db => AppwriteClient.instance.databases;

  /// گرفتن همه‌ی آیتم‌ها با Queryهای دلخواه
  Future<ApiResult<List<T>>> getAll({
    List<String>? queries,
  }) {
    return _executor.execute<List<T>>(
          () async {
        final res = await _db.listDocuments(
          databaseId: databaseId,
          collectionId: collectionId,
          queries: queries,
        );

        final items = res.documents
            .map<Map<String, dynamic>>(_documentToMap)
            .map<T>(fromJson)
            .toList();

        return items;
      },
      label: 'GET all from $collectionId',
    );
  }

  /// گرفتن یک آیتم بر اساس id
  Future<ApiResult<T>> getById(String documentId) {
    return _executor.execute<T>(
          () async {
        final doc = await _db.getDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: documentId,
        );

        final json = _documentToMap(doc);
        return fromJson(json);
      },
      label: 'GET $collectionId / $documentId',
    );
  }

  /// ایجاد آیتم جدید
  Future<ApiResult<T>> create(
      T entity, {
        String? documentId,
        List<String>? permissions,
      }) {
    return _executor.execute<T>(
          () async {
        final data = toJson(entity);

        final doc = await _db.createDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: documentId ?? 'unique()',
          data: data,
          permissions: permissions,
        );

        final json = _documentToMap(doc);
        return fromJson(json);
      },
      label: 'CREATE $collectionId',
    );
  }

  /// ویرایش آیتم
  Future<ApiResult<T>> update(
      String documentId,
      T entity, {
        List<String>? permissions,
      }) {
    return _executor.execute<T>(
          () async {
        final data = toJson(entity);

        final doc = await _db.updateDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: documentId,
          data: data,
          permissions: permissions,
        );

        final json = _documentToMap(doc);
        return fromJson(json);
      },
      label: 'UPDATE $collectionId / $documentId',
    );
  }

  /// حذف آیتم
  Future<ApiResult<void>> delete(String documentId) {
    return _executor.execute<void>(
          () async {
        await _db.deleteDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: documentId,
        );

        return null;
      },
      label: 'DELETE $collectionId / $documentId',
    );
  }

  /// تبدیل Doc Appwrite به Map استاندارد شامل $id, $createdAt, $updatedAt
  Map<String, dynamic> _documentToMap(appwrite_models.Document doc) {
    final data = Map<String, dynamic>.from(doc.data);
    data['\$id'] = doc.$id;
    data['\$createdAt'] = doc.$createdAt;
    data['\$updatedAt'] = doc.$updatedAt;
    return data;
  }
}
