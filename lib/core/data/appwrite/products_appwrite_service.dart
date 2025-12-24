// lib/core/data/appwrite/products_appwrite_service.dart

import 'package:appwrite/appwrite.dart';
import 'package:admin/config/environment.dart';
import 'package:admin/config/ network/appwrite_client.dart';
import 'package:admin/config/ network/api_result.dart';
import 'package:admin/config/ network/request_executor.dart';
import 'package:admin/models/product.dart';

class ProductsAppwriteService {
  final RequestExecutor _executor = RequestExecutor();
  Databases get _db => AppwriteClient.instance.databases;

  Future<ApiResult<List<Product>>> getByPhoneNumberCode(String phoneNumberCode) {
    return _executor.execute<List<Product>>(
          () async {
        final res = await _db.listDocuments(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdProducts,
          queries: [
            Query.equal('phone_number_code', phoneNumberCode),
          ],
        );

        return res.documents.map((doc) {
          final map = <String, dynamic>{
            ...doc.data,
            r'$id': doc.$id,
            r'$createdAt': doc.$createdAt,
            r'$updatedAt': doc.$updatedAt,
          };
          return Product.fromJson(map);
        }).toList();
      },
      label: 'GET products',
    );
  }

  Future<ApiResult<Product>> createProduct({
    required Map<String, dynamic> data,
  }) {
    return _executor.execute<Product>(
          () async {
        final doc = await _db.createDocument(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdProducts,
          documentId: ID.unique(),
          data: data,
        );

        final map = <String, dynamic>{
          ...doc.data,
          r'$id': doc.$id,
          r'$createdAt': doc.$createdAt,
          r'$updatedAt': doc.$updatedAt,
        };
        return Product.fromJson(map);
      },
      label: 'CREATE product',
    );
  }

  Future<ApiResult<Product>> updateProduct({
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return _executor.execute<Product>(
          () async {
        final doc = await _db.updateDocument(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdProducts,
          documentId: documentId,
          data: data,
        );

        final map = <String, dynamic>{
          ...doc.data,
          r'$id': doc.$id,
          r'$createdAt': doc.$createdAt,
          r'$updatedAt': doc.$updatedAt,
        };
        return Product.fromJson(map);
      },
      label: 'UPDATE product',
    );
  }

  Future<ApiResult<void>> deleteProduct(String documentId) {
    return _executor.execute<void>(
          () async {
        await _db.deleteDocument(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdProducts,
          documentId: documentId,
        );
      },
      label: 'DELETE product',
    );
  }



}
