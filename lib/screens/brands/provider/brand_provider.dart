

import 'package:admin/utility/User_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/data/data_provider.dart';

import '../../../models/brand.dart';
import '../../../models/sub_category.dart';

import '../../../utility/snack_bar_helper.dart';


import 'package:admin/core/data/appwrite/brands_repository.dart';

import 'package:flutter/material.dart';



class BrandProvider extends ChangeNotifier {
  final BrandsRepository _repo = BrandsRepository();
  final DataProvider _dataProvider;

  final addBrandFormKey = GlobalKey<FormState>();
  final TextEditingController brandNameCtrl = TextEditingController();

  SubCategory? selectedSubCategory;
  Brand? brandForUpdate;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  BrandProvider(this._dataProvider);

  // ---------- Create ----------
  Future<bool> addBrand() async {
    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false);
      if (phone == null || phone.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن/کد در حافظه یافت نشد!');
        return false;
      }

      final sub = selectedSubCategory;
      final subId = sub?.sId;
      if (subId == null || subId.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('لطفاً یک زیر‌دسته انتخاب کنید');
        return false;
      }

      final brand = Brand(
        name: brandNameCtrl.text.trim(),
        phoneNumberCode: phone.trim(),

        subcategory: subId.trim(),
      );

      final res = await _repo.create(brand);

      if (res.isSuccess) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar('برند ایجاد شد');
        await _dataProvider.getAllBrands(showSnack: false);
        return true;
      } else {
        final err = res.requireError();
        SnackBarHelper.showErrorSnackBar(
          err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'خطا در ایجاد برند'),
        );
        return false;
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('خطا: $e');
      return false;
    }
  }

  // ---------- Update ----------
  Future<bool> updateBrand() async {
    try {
      final id = brandForUpdate?.sId ?? '';
      if (id.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('ID برند نامعتبر است');
        return false;
      }

      final phone = await UserSaveHelper.getPhoneNumber(showError: false);
      if (phone == null || phone.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن/کد در حافظه یافت نشد!');
        return false;
      }

      final sub = selectedSubCategory;
      final subId = sub?.sId;
      if (subId == null || subId.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('لطفاً یک زیر‌دسته انتخاب کنید');
        return false;
      }

      final brand = Brand(
        name: brandNameCtrl.text.trim(),
        phoneNumberCode: phone.trim(),

        subcategory: subId.trim(),
      );

      final res = await _repo.update(id.trim(), brand);

      if (res.isSuccess) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar('برند بروزرسانی شد');
        await _dataProvider.getAllBrands(showSnack: false);
        return true;
      } else {
        final err = res.requireError();
        SnackBarHelper.showErrorSnackBar(
          err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'خطا در بروزرسانی برند'),
        );
        return false;
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('خطا: $e');
      return false;
    }
  }

  // ---------- Unified Submit ----------
  Future<bool> submitBrand() async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    notifyListeners();

    try {
      final form = addBrandFormKey.currentState;
      if (form == null) return false;
      if (!form.validate()) return false;
      form.save();

      return brandForUpdate == null ? await addBrand() : await updateBrand();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ---------- Delete ----------
  Future<void> deleteBrand(Brand b) async {
    try {
      final id = b.sId ?? '';
      if (id.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('ID برند نامعتبر است');
        return;
      }

      final res = await _repo.delete(id.trim());

      if (res.isSuccess) {
        SnackBarHelper.showSuccessSnackBar('برند حذف شد');
        await _dataProvider.getAllBrands(showSnack: false);
      } else {
        final err = res.requireError();
        SnackBarHelper.showErrorSnackBar(
          err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'خطا در حذف برند'),
        );
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('خطا: $e');
    }
  }




  // ---------- Edit mode ----------
  setDataForUpdateBrand(Brand? brand) {
    if (brand != null) {
      brandForUpdate = brand;
      brandNameCtrl.text = brand.name ?? '';

      // preselect: اولویت با object -> سپس id
      final String? subId = brand.subCategoryId?.sId ?? brand.subcategory;
      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull(
            (s) => s.sId == subId,
      );
    } else {
      clearFields();
    }
    notifyListeners();
  }

  void clearFields() {
    brandNameCtrl.clear();
    selectedSubCategory = null;
    brandForUpdate = null;
    notifyListeners();
  }

  void updateUi() => notifyListeners();

  @override
  void dispose() {
    brandNameCtrl.dispose();
    super.dispose();
  }
}

