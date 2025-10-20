import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/data/data_provider.dart';

import '../../../models/category.dart';
import '../../../models/coupon.dart';
import '../../../models/product.dart';
import '../../../models/sub_category.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';


class CouponCodeProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  Coupon? couponForUpdate;

  final addCouponFormKey = GlobalKey<FormState>();
  TextEditingController couponCodeCtrl = TextEditingController();
  TextEditingController discountAmountCtrl = TextEditingController();
  TextEditingController minimumPurchaseAmountCtrl = TextEditingController();
  TextEditingController endDateCtrl = TextEditingController();
  String selectedDiscountType = 'fixed';
  String selectedCouponStatus = 'active';
  Category? selectedCategory;
  SubCategory? selectedSubCategory;
  Product? selectedProduct;

  CouponCodeProvider(this._dataProvider);

  addCoupon() async {
    try {
      // اعتبارسنجی‌ها
      if (endDateCtrl.text.isEmpty) {
        SnackBarHelper.showErrorSnackBar('Please select end date!');
        return;
      }

      try {
        DateTime endDate = DateTime.parse(endDateCtrl.text);
        if (endDate.isBefore(DateTime.now())) {
          SnackBarHelper.showErrorSnackBar('Please select valid end date!');
          return;
        }
      } catch (e) {
        SnackBarHelper.showErrorSnackBar('Invalid date format!');
        return;
      }

      // ساخت داده‌های کوپن - توجه: فیلدهای رابطه‌ای باید String باشند
      Map<String, dynamic> coupon = {
        'couponCode': couponCodeCtrl.text.trim(),
        'discountType': selectedDiscountType,
        'discountAmount': double.parse(discountAmountCtrl.text),
        'minimumPurchaseAmount': minimumPurchaseAmountCtrl.text.isNotEmpty
            ? double.parse(minimumPurchaseAmountCtrl.text)
            : 0,
        'endDate': endDateCtrl.text,
        'status': selectedCouponStatus,
        // فیلدهای رابطه‌ای - در صورت null بودن به صورت "" ارسال می‌شوند
        'applicableCategory': selectedCategory?.sId ?? "",
        'applicableSubCategory': selectedSubCategory?.sId ?? "",
        'applicableProduct': selectedProduct?.sId ?? ""
      };

      print('📤 Sending coupon data: $coupon');

      final response = await service.addItem(endpointUrl: 'api/coupons', itemData: coupon);

      if (response.isOk) {
        if (response.body['success'] == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('Coupon created successfully');
          log('✅ Coupon added successfully');

          _dataProvider.getAllCoupons();
        } else {
          String errorMessage = response.body['error'] ?? 'Unknown error';
          print('❌ Server error: $errorMessage');
          SnackBarHelper.showErrorSnackBar('Failed to add coupon: $errorMessage');
        }
      } else {
        print('❌ HTTP error: ${response.statusCode} - ${response.body}');
        SnackBarHelper.showErrorSnackBar(
            'Error: ${response.body?['error'] ?? response.statusText}');
      }
    } catch (e) {
      print('❌ Exception in addCoupon: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  updateCoupon() async {
    try {
      Map<String, dynamic> coupon = {
        'couponCode': couponCodeCtrl.text.trim(),
        'discountType': selectedDiscountType,
        'discountAmount': double.parse(discountAmountCtrl.text),
        'minimumPurchaseAmount': minimumPurchaseAmountCtrl.text.isNotEmpty
            ? double.parse(minimumPurchaseAmountCtrl.text)
            : 0,
        'endDate': endDateCtrl.text,
        'status': selectedCouponStatus,
        // فیلدهای رابطه‌ای - در صورت null بودن به صورت "" ارسال می‌شوند
        'applicableCategory': selectedCategory?.sId ?? "",
        'applicableSubCategory': selectedSubCategory?.sId ?? "",
        'applicableProduct': selectedProduct?.sId ?? ""
      };

      print('📤 Updating coupon with data: $coupon');

      final response = await service.updateItem(
          endpointUrl: 'api/coupons',
          itemId: '${couponForUpdate?.sId}',
          itemData: coupon);

      if (response.isOk) {
        if (response.body['success'] == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('Coupon updated successfully');
          log('✅ Coupon updated successfully');

          _dataProvider.getAllCoupons();
        } else {
          String errorMessage = response.body['error'] ?? 'Unknown error';
          print('❌ Server error: $errorMessage');
          SnackBarHelper.showErrorSnackBar('Failed to update coupon: $errorMessage');
        }
      } else {
        print('❌ HTTP error: ${response.statusCode} - ${response.body}');
        SnackBarHelper.showErrorSnackBar(
            'Error: ${response.body?['error'] ?? response.statusText}');
      }
    } catch (e) {
      print('❌ Exception in updateCoupon: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  submitCoupon() => couponForUpdate != null ? updateCoupon() : addCoupon();

  deleteCoupon(Coupon coupon) async {
    try {
      Response response = await service.deleteItem(
          endpointUrl: 'api/coupons', itemId: coupon.sId ?? '');

      if (response.isOk) {
        if (response.body['success'] == true) {
          SnackBarHelper.showSuccessSnackBar('Coupon deleted successfully!');
          _dataProvider.getAllCoupons();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to delete coupon: ${response.body['error']}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error: ${response.body?['error'] ?? response.statusText}');
      }
    } catch (e) {
      print('❌ Exception in deleteCoupon: $e');
      rethrow;
    }
  }

  //? set data for update on editing
  setDataForUpdateCoupon(Coupon? coupon) {
    if (coupon != null) {
      couponForUpdate = coupon;
      couponCodeCtrl.text = coupon.couponCode ?? '';
      selectedDiscountType = coupon.discountType ?? 'fixed';
      discountAmountCtrl.text = '${coupon.discountAmount ?? ''}';
      minimumPurchaseAmountCtrl.text = '${coupon.minimumPurchaseAmount ?? ''}';
      endDateCtrl.text = coupon.endDate ?? '';
      selectedCouponStatus = coupon.status ?? 'active';

      // Set selected category if exists - توجه: applicableCategory اکنون String است
      if (coupon.applicableCategory != null && coupon.applicableCategory!.isNotEmpty) {
        selectedCategory = _dataProvider.categories.firstWhereOrNull(
                (element) => element.sId == coupon.applicableCategory);
      } else {
        selectedCategory = null;
      }

      // Set selected subcategory if exists
      if (coupon.applicableSubCategory != null && coupon.applicableSubCategory!.isNotEmpty) {
        selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull(
                (element) => element.sId == coupon.applicableSubCategory);
      } else {
        selectedSubCategory = null;
      }

      // Set selected product if exists
      if (coupon.applicableProduct != null && coupon.applicableProduct!.isNotEmpty) {
        selectedProduct = _dataProvider.products.firstWhereOrNull(
                (element) => element.sId == coupon.applicableProduct);
      } else {
        selectedProduct = null;
      }

      print('🔍 Setting data for update:');
      print('   - Category: ${selectedCategory?.name} (ID: ${coupon.applicableCategory})');
      print('   - SubCategory: ${selectedSubCategory?.name} (ID: ${coupon.applicableSubCategory})');
      print('   - Product: ${selectedProduct?.name} (ID: ${coupon.applicableProduct})');
    } else {
      clearFields();
    }
    notifyListeners();
  }

  //? to clear text field and images after adding or update coupon
  clearFields() {
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

  updateUi() {
    notifyListeners();
  }
}