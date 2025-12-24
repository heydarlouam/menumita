// lib/core/data/appwrite/coupon_code_appwrite_service.dart

import 'package:appwrite/appwrite.dart';
import 'package:admin/config/environment.dart';
import 'package:admin/config/ network/appwrite_client.dart';
import 'package:admin/config/ network/api_result.dart';
import 'package:admin/config/ network/request_executor.dart';
import 'package:admin/models/coupon.dart';

class CouponCodeAppwriteService {
  CouponCodeAppwriteService();

  final RequestExecutor _executor = RequestExecutor();

  Databases get _db => AppwriteClient.instance.databases;

  Future<ApiResult<List<Coupon>>> getByPhoneNumberCode(String phoneNumberCode) {
    return _executor.execute<List<Coupon>>(
          () async {
        final res = await _db.listDocuments(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdCouponCode,
          queries: [
            Query.equal('phone_number_code', phoneNumberCode),
          ],
        );

        final items = res.documents.map((doc) {
          final map = <String, dynamic>{
            ...doc.data,
            r'$id': doc.$id,
            r'$createdAt': doc.$createdAt,
            r'$updatedAt': doc.$updatedAt,
          };
          return Coupon.fromJson(map);
        }).toList();

        return items;
      },
      label: 'GET coupons by phone_number_code',
    );
  }

  Future<ApiResult<Coupon>> createCoupon({
    required String couponId, // همان documentId
    required Map<String, dynamic> data,
  }) {
    return _executor.execute<Coupon>(
          () async {
        final doc = await _db.createDocument(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdCouponCode,
          documentId: couponId,
          data: data,
        );

        final map = <String, dynamic>{
          ...doc.data,
          r'$id': doc.$id,
          r'$createdAt': doc.$createdAt,
          r'$updatedAt': doc.$updatedAt,
        };
        return Coupon.fromJson(map);
      },
      label: 'CREATE coupon (documentId = couponCode)',
    );
  }

  Future<ApiResult<Coupon>> updateCoupon({
    required String couponId,
    required Map<String, dynamic> data,
  }) {
    return _executor.execute<Coupon>(
          () async {
        final doc = await _db.updateDocument(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdCouponCode,
          documentId: couponId,
          data: data,
        );

        final map = <String, dynamic>{
          ...doc.data,
          r'$id': doc.$id,
          r'$createdAt': doc.$createdAt,
          r'$updatedAt': doc.$updatedAt,
        };
        return Coupon.fromJson(map);
      },
      label: 'UPDATE coupon',
    );
  }

  Future<ApiResult<void>> deleteCoupon(String couponId) {
    return _executor.execute<void>(
          () async {
        await _db.deleteDocument(
          databaseId: Environment.databaseIdMenuMita,
          collectionId: Environment.collectionIdCouponCode,
          documentId: couponId,
        );
      },
      label: 'DELETE coupon',
    );
  }
}
