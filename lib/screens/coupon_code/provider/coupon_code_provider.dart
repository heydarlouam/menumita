import 'dart:developer';

import 'package:admin/utility/User_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/data/data_provider.dart';

import '../../../models/category.dart';
import '../../../models/coupon.dart';
import '../../../models/product.dart';
import '../../../models/sub_category.dart';
import '../../../core/data/repositories/category_repository.dart';
import '../../../utility/snack_bar_helper.dart';



class CouponCodeProvider extends ChangeNotifier {
  final CouponRepository repository = CouponRepository();
  final DataProvider _dataProvider;

  Coupon? couponForUpdate;

  final addCouponFormKey = GlobalKey<FormState>();
  final TextEditingController couponCodeCtrl = TextEditingController();
  final TextEditingController discountAmountCtrl = TextEditingController();
  final TextEditingController minimumPurchaseAmountCtrl = TextEditingController();
  final TextEditingController endDateCtrl = TextEditingController();

  String selectedDiscountType = 'fixed';
  String selectedCouponStatus = 'active';

  Category? selectedCategory;
  SubCategory? selectedSubCategory;
  Product? selectedProduct;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  CouponCodeProvider(this._dataProvider);

  @override
  void dispose() {
    couponCodeCtrl.dispose();
    discountAmountCtrl.dispose();
    minimumPurchaseAmountCtrl.dispose();
    endDateCtrl.dispose();
    super.dispose();
  }

  // Map<String, dynamic> _buildPayload() {
  //   final discount = double.tryParse(discountAmountCtrl.text) ?? 0;
  //   final minPurchase = minimumPurchaseAmountCtrl.text.isNotEmpty
  //       ? (double.tryParse(minimumPurchaseAmountCtrl.text) ?? 0)
  //       : 0;
  //
  //   return {
  //     'couponCode': couponCodeCtrl.text.trim(),
  //     'discountType': selectedDiscountType,
  //     'discountAmount': discount,
  //     'minimumPurchaseAmount': minPurchase,
  //     'endDate': endDateCtrl.text,
  //     'status': selectedCouponStatus,
  //     'applicableCategory': selectedCategory?.sId ?? "",
  //     'applicableSubCategory': selectedSubCategory?.sId ?? "",
  //     'applicableProduct': selectedProduct?.sId ?? "",
  //     // قانون ثابت:
  //     'phone_number_code': '12345',
  //   };
  // }
  // ✨ قبلی: Map<String, dynamic> _buildPayload()
// ✨ جدید:
  Future<Map<String, dynamic>?> _buildPayload() async {
    // گرفتن شماره از SharedPreferences
    final phone = await UserSaveHelper.getPhoneNumber();
    if (phone == null || phone.isEmpty) {
      SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
      return null;
    }

    final discount = double.tryParse(discountAmountCtrl.text) ?? 0;
    final minPurchase = minimumPurchaseAmountCtrl.text.isNotEmpty
        ? (double.tryParse(minimumPurchaseAmountCtrl.text) ?? 0)
        : 0;

    return {
      'couponCode': couponCodeCtrl.text.trim(),
      'discountType': selectedDiscountType,
      'discountAmount': discount,
      'minimumPurchaseAmount': minPurchase,
      'endDate': endDateCtrl.text,
      'status': selectedCouponStatus,
      'applicableCategory': selectedCategory?.sId ?? "",
      'applicableSubCategory': selectedSubCategory?.sId ?? "",
      'applicableProduct': selectedProduct?.sId ?? "",
      // ✅ به‌جای مقدار ثابت:
      'phone_number_code': phone,
    };
  }


  Future<bool> addCoupon() async {
    try {
      // اعتبارسنجی تاریخ
      if (endDateCtrl.text.isEmpty) {
        SnackBarHelper.showErrorSnackBar('Please select end date!');
        return false;
      }
      try {
        final endDate = DateTime.parse(endDateCtrl.text);
        if (endDate.isBefore(DateTime.now())) {
          SnackBarHelper.showErrorSnackBar('Please select valid end date!');
          return false;
        }
      } catch (_) {
        SnackBarHelper.showErrorSnackBar('Invalid date format!');
        return false;
      }

      _isSubmitting = true;
      notifyListeners();

      // ✅ اینجا حتما await
      final payload = await _buildPayload();
      if (payload == null) return false;

      log('📤 Sending coupon data: $payload');

      final response = await repository.addCoupon(payload);

      if (response.isOk && response.body['success'] == true) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar('Coupon created successfully');
        await _dataProvider.getAllCoupons();
        return true;
      }

      final msg = response.body?['error'] ?? response.statusText ?? 'Unknown error';
      SnackBarHelper.showErrorSnackBar('Failed to add coupon: $msg');
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }


  Future<bool> updateCoupon() async {
    try {
      _isSubmitting = true;
      notifyListeners();

      final payload = await _buildPayload();
      if (payload == null) return false;

      log('📤 Updating coupon with data: $payload');

      final response = await repository.updateCoupon(
        '${couponForUpdate?.sId}',
        payload,
      );

      if (response.isOk && response.body['success'] == true) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar('Coupon updated successfully');
        await _dataProvider.getAllCoupons();
        return true;
      }

      final msg = response.body?['error'] ?? response.statusText ?? 'Unknown error';
      SnackBarHelper.showErrorSnackBar('Failed to update coupon: $msg');
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> submitCoupon() =>
      couponForUpdate != null ? updateCoupon() : addCoupon();

  Future<bool> deleteCoupon(Coupon coupon) async {
    print('remove coupon ');
    print('remove coupon ${coupon.sId}');
    try {
      final response = await repository.deleteCoupon(coupon.sId ?? '');

      if (response.isOk && response.body['success'] == true) {
        SnackBarHelper.showSuccessSnackBar('Coupon deleted successfully!');
        await _dataProvider.getAllCoupons();
        return true;
      }

      SnackBarHelper.showErrorSnackBar(
        'Failed to delete coupon: ${response.body?['error'] ?? response.statusText}',
      );
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  void setDataForUpdateCoupon(Coupon? coupon) {
    if (coupon != null) {
      // جلوگیری از ست‌کردنِ تکراری در باز-renderها
      if (couponForUpdate?.sId == coupon.sId) return;

      couponForUpdate = coupon;
      couponCodeCtrl.text = coupon.couponCode ?? '';
      selectedDiscountType = coupon.discountType ?? 'fixed';
      discountAmountCtrl.text = '${coupon.discountAmount ?? ''}';
      minimumPurchaseAmountCtrl.text = '${coupon.minimumPurchaseAmount ?? ''}';
      endDateCtrl.text = coupon.endDate ?? '';
      selectedCouponStatus = coupon.status ?? 'active';

      if ((coupon.applicableCategory ?? '').isNotEmpty) {
        selectedCategory = _dataProvider.categories
            .firstWhereOrNull((e) => e.sId == coupon.applicableCategory);
      } else {
        selectedCategory = null;
      }

      if ((coupon.applicableSubCategory ?? '').isNotEmpty) {
        selectedSubCategory = _dataProvider.subCategories
            .firstWhereOrNull((e) => e.sId == coupon.applicableSubCategory);
      } else {
        selectedSubCategory = null;
      }

      if ((coupon.applicableProduct ?? '').isNotEmpty) {
        selectedProduct = _dataProvider.products
            .firstWhereOrNull((e) => e.sId == coupon.applicableProduct);
      } else {
        selectedProduct = null;
      }

      log('🔍 Prefill for update: '
          'cat=${selectedCategory?.name}, sub=${selectedSubCategory?.name}, prod=${selectedProduct?.name}');
    } else {
      clearFields();
    }
    notifyListeners();
  }

  void clearFields() {
    couponForUpdate = null;
    selectedCategory = null;
    selectedSubCategory = null;
    selectedProduct = null;

    couponCodeCtrl.clear();
    discountAmountCtrl.clear();
    minimumPurchaseAmountCtrl.clear();
    endDateCtrl.clear();

    selectedDiscountType = 'fixed';
    selectedCouponStatus = 'active';
    notifyListeners();
  }

  void updateUi() => notifyListeners();
}
