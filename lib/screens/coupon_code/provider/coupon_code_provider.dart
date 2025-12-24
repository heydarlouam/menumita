import 'dart:developer';

import 'package:admin/utility/User_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/data/data_provider.dart';

import '../../../models/category.dart';
import '../../../models/coupon.dart';
import '../../../models/product.dart';
import '../../../models/sub_category.dart';

import '../../../utility/snack_bar_helper.dart';


import 'package:admin/core/data/appwrite/coupon_code_appwrite_service.dart';

import 'package:intl/intl.dart';


class CouponCodeProvider extends ChangeNotifier {
  final DataProvider _dataProvider;
  final CouponCodeAppwriteService _service = CouponCodeAppwriteService();

  final addCouponFormKey = GlobalKey<FormState>();

  final TextEditingController couponCodeCtrl = TextEditingController();
  final TextEditingController discountAmountCtrl = TextEditingController();
  final TextEditingController minimumPurchaseAmountCtrl = TextEditingController();
  final TextEditingController endDateCtrl = TextEditingController();

  String selectedDiscountType = 'fixed'; // fixed | percentage
  String selectedCouponStatus = 'active'; // active | inactive

  Category? selectedCategory;
  SubCategory? selectedSubCategory;
  Product? selectedProduct;

  Coupon? couponForUpdate;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  CouponCodeProvider(this._dataProvider);

  bool _isValidCouponId(String id) {
    // documentId بهتر است انگلیسی/عدد/_/-
    return RegExp(r'^[A-Za-z0-9_-]{3,36}$').hasMatch(id);
  }

  String _defaultEndDate() {
    final d = DateTime.now().add(const Duration(days: 30));
    return DateFormat('yyyy-MM-dd').format(d);
  }

  Future<Map<String, dynamic>?> _buildAppwriteData({required bool forUpdate}) async {
    final phone = await UserSaveHelper.getPhoneNumber(showError: false);
    if (phone == null || phone.trim().isEmpty) {
      SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
      return null;
    }

    final discountText = discountAmountCtrl.text.trim();
    final minText = minimumPurchaseAmountCtrl.text.trim().isNotEmpty
        ? minimumPurchaseAmountCtrl.text.trim()
        : '0';

    final endDate = endDateCtrl.text.trim().isNotEmpty
        ? endDateCtrl.text.trim()
        : _defaultEndDate();

    final String? catId = selectedCategory?.sId;
    final String? subId = selectedSubCategory?.sId;
    final String? prodId = selectedProduct?.sId;

    final data = <String, dynamic>{
      'discountType': selectedDiscountType,
      'discountAmount': discountText,
      'minimumPurchaseAmount': minText,
      'endDate': endDate,
      'status': selectedCouponStatus,
    'phone_number_code': phone.trim(),

    };

    // هدف: فقط یکی از سه مورد (UI فعلی همین کار را می‌کند)
    if (forUpdate) {
      // در ویرایش باید قبلی‌ها پاک شوند
     // data['categories'] = (catId != null && catId.isNotEmpty) ? <String>[catId] : <String>[];
      data['categories_id'] = (catId != null && catId.isNotEmpty) ? catId : null;

  //    data['subcategories'] = (subId != null && subId.isNotEmpty) ? <String>[subId] : <String>[];
      data['subcategories_id'] = (subId != null && subId.isNotEmpty) ? subId : null;

    //  data['products'] = (prodId != null && prodId.isNotEmpty) ? <String>[prodId] : <String>[];
      data['products_id'] = (prodId != null && prodId.isNotEmpty) ? prodId : null;
    } else {
      // در ایجاد فقط همان مورد انتخابی را می‌فرستیم
      if (catId != null && catId.isNotEmpty) {
     //   data['categories'] = <String>[catId];
        data['categories_id'] = catId;
      } else if (subId != null && subId.isNotEmpty) {
  //      data['subcategories'] = <String>[subId];
        data['subcategories_id'] = subId;
      } else if (prodId != null && prodId.isNotEmpty) {
  //      data['products'] = <String>[prodId];
        data['products_id'] = prodId;
      }
    }

    return data;
  }

  Future<bool> addCoupon() async {
    if (_isSubmitting) return false;

    try {
      _isSubmitting = true;
      notifyListeners();

      final code = couponCodeCtrl.text.trim();
      if (!_isValidCouponId(code)) {
        SnackBarHelper.showErrorSnackBar(
          'کد کوپن نامعتبر است. فقط حروف انگلیسی/عدد و _ یا - (۳ تا ۳۶ کاراکتر)',
        );
        return false;
      }

      final data = await _buildAppwriteData(forUpdate: false);
      if (data == null) return false;

      final res = await _service.createCoupon(couponId: code, data: data);

      if (res.isSuccess) {
        SnackBarHelper.showSuccessSnackBar('کوپن ایجاد شد');
        clearFields();
        await _dataProvider.getAllCoupons(showSnack: false);
        return true;
      } else {
        final err = res.requireError();
        SnackBarHelper.showErrorSnackBar(
          err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'خطا در ایجاد کوپن'),
        );
        return false;
      }
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateCoupon() async {
    if (_isSubmitting) return false;

    try {
      _isSubmitting = true;
      notifyListeners();

      final id = couponForUpdate?.sId ?? '';
      if (id.isEmpty) {
        SnackBarHelper.showErrorSnackBar('ID کوپن نامعتبر است');
        return false;
      }

      // تغییر code در ویرایش مجاز نیست (چون documentId است)
      final typed = couponCodeCtrl.text.trim();
      if (typed.isNotEmpty && typed != id) {
        SnackBarHelper.showErrorSnackBar('کد کوپن در حالت ویرایش قابل تغییر نیست');
        couponCodeCtrl.text = id;
      }

      final data = await _buildAppwriteData(forUpdate: true);
      if (data == null) return false;

      final res = await _service.updateCoupon(couponId: id, data: data);

      if (res.isSuccess) {
        SnackBarHelper.showSuccessSnackBar('کوپن بروزرسانی شد');
        clearFields();
        await _dataProvider.getAllCoupons(showSnack: false);
        return true;
      } else {
        final err = res.requireError();
        SnackBarHelper.showErrorSnackBar(
          err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'خطا در بروزرسانی کوپن'),
        );
        return false;
      }
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> submitCoupon() async {
    final form = addCouponFormKey.currentState;
    if (form == null) return false;
    if (!form.validate()) return false;
    form.save();

    return couponForUpdate == null ? await addCoupon() : await updateCoupon();
  }

  Future<void> deleteCoupon(Coupon coupon) async {
    final id = coupon.sId ?? '';
    if (id.isEmpty) {
      SnackBarHelper.showErrorSnackBar('ID کوپن نامعتبر است');
      return;
    }

    final res = await _service.deleteCoupon(id);
    if (res.isSuccess) {
      SnackBarHelper.showSuccessSnackBar('کوپن حذف شد');
      await _dataProvider.getAllCoupons(showSnack: false);
    } else {
      final err = res.requireError();
      SnackBarHelper.showErrorSnackBar(
        err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'خطا در حذف کوپن'),
      );
    }
  }

  void setDataForUpdateCoupon(Coupon? coupon) {
    if (coupon == null) {
      clearFields();
      return;
    }

    couponForUpdate = coupon;

    // چون documentId است:
    couponCodeCtrl.text = coupon.sId ?? coupon.couponCode ?? '';

    selectedDiscountType = coupon.discountType ?? 'fixed';
    selectedCouponStatus = coupon.status ?? 'active';

    discountAmountCtrl.text = (coupon.discountAmount ?? '').toString();
    minimumPurchaseAmountCtrl.text = (coupon.minimumPurchaseAmount ?? '').toString();
    endDateCtrl.text = coupon.endDate ?? '';

    // هدف
    final catId = coupon.applicableCategory;
    final subId = coupon.applicableSubCategory;
    final prodId = coupon.applicableProduct;

    if (catId != null && catId.isNotEmpty) {
      selectedCategory = _dataProvider.categories.firstWhereOrNull((e) => e.sId == catId);
      selectedSubCategory = null;
      selectedProduct = null;
    } else if (subId != null && subId.isNotEmpty) {
      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull((e) => e.sId == subId);
      selectedCategory = null;
      selectedProduct = null;
    } else if (prodId != null && prodId.isNotEmpty) {
      selectedProduct = _dataProvider.products.firstWhereOrNull((e) => e.sId == prodId);
      selectedCategory = null;
      selectedSubCategory = null;
    } else {
      selectedCategory = null;
      selectedSubCategory = null;
      selectedProduct = null;
    }

    notifyListeners();
  }

  void clearFields() {
    couponForUpdate = null;

    couponCodeCtrl.clear();
    discountAmountCtrl.clear();
    minimumPurchaseAmountCtrl.clear();
    endDateCtrl.clear();

    selectedDiscountType = 'fixed';
    selectedCouponStatus = 'active';

    selectedCategory = null;
    selectedSubCategory = null;
    selectedProduct = null;

    notifyListeners();
  }

  void updateUi() => notifyListeners();

  @override
  void dispose() {
    couponCodeCtrl.dispose();
    discountAmountCtrl.dispose();
    minimumPurchaseAmountCtrl.dispose();
    endDateCtrl.dispose();
    super.dispose();
  }
}
