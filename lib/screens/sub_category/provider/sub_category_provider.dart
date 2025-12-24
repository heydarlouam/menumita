
import 'dart:developer';


import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../models/sub_category.dart';


import 'package:admin/core/data/appwrite/sub_category_appwrite_service.dart';

import 'package:flutter/material.dart';


class SubCategoryProvider extends ChangeNotifier {
  final DataProvider _dataProvider;
  final SubCategoryAppwriteService _subService = SubCategoryAppwriteService();

  SubCategoryProvider(this._dataProvider);

  final addSubCategoryFormKey = GlobalKey<FormState>();
  final TextEditingController subCategoryNameCtrl = TextEditingController();

  Category? selectedCategory;
  SubCategory? subCategoryForUpdate;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // ---------- Create ----------
  Future<bool> _createSubCategory() async {
    try {
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return false;
      }

      if (selectedCategory == null || selectedCategory!.sId == null) {
        SnackBarHelper.showErrorSnackBar('لطفاً یک دسته‌بندی انتخاب کنید');
        return false;
      }

      final name = subCategoryNameCtrl.text.trim();
      if (name.isEmpty) {
        SnackBarHelper.showErrorSnackBar('نام زیر‌دسته را وارد کنید');
        return false;
      }

      final result = await _subService.createSubCategory(
        name: name,
        phoneNumberCode: phone,

        categoryId: selectedCategory!.sId!,
      );

      if (result.isSuccess) {
        await _dataProvider.getAllSubCategories(showSnack: true);
        clearFields();
        SnackBarHelper.showSuccessSnackBar('زیر‌دسته با موفقیت ایجاد شد');
        log('sub category created');
        return true;
      } else {
        final err = result.requireError();
        SnackBarHelper.showErrorSnackBar(
          err.userMessage.isNotEmpty
              ? err.userMessage
              : (err.devMessage ?? 'ایجاد زیر‌دسته ناموفق بود'),
        );
        return false;
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('خطا در ایجاد زیر‌دسته: $e');
      return false;
    }
  }

  // ---------- Update ----------
  Future<bool> _updateSubCategory() async {
    try {
      if (subCategoryForUpdate == null ||
          subCategoryForUpdate!.sId == null ||
          subCategoryForUpdate!.sId!.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شناسه زیر‌دسته نامعتبر است');
        return false;
      }

      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return false;
      }

      if (selectedCategory == null || selectedCategory!.sId == null) {
        SnackBarHelper.showErrorSnackBar('لطفاً یک دسته‌بندی انتخاب کنید');
        return false;
      }

      final name = subCategoryNameCtrl.text.trim();
      if (name.isEmpty) {
        SnackBarHelper.showErrorSnackBar('نام زیر‌دسته را وارد کنید');
        return false;
      }

      final result = await _subService.updateSubCategory(
        documentId: subCategoryForUpdate!.sId!,
        name: name,
        phoneNumberCode: phone,

        categoryId: selectedCategory!.sId!,
      );

      if (result.isSuccess) {
        await _dataProvider.getAllSubCategories(showSnack: true);
        clearFields();
        SnackBarHelper.showSuccessSnackBar('زیر‌دسته با موفقیت ویرایش شد');
        log('sub category updated');
        return true;
      } else {
        final err = result.requireError();
        SnackBarHelper.showErrorSnackBar(
          err.userMessage.isNotEmpty
              ? err.userMessage
              : (err.devMessage ?? 'ویرایش زیر‌دسته ناموفق بود'),
        );
        return false;
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('خطا در ویرایش زیر‌دسته: $e');
      return false;
    }
  }

  // ---------- Unified Submit ----------
  Future<bool> submitSubCategory() async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      final form = addSubCategoryFormKey.currentState;
      if (form == null) return false;
      if (!form.validate()) return false;
      form.save();

      if (subCategoryForUpdate != null) {
        return await _updateSubCategory();
      } else {
        return await _createSubCategory();
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ---------- Delete ----------
  Future<void> deleteSubCategory(SubCategory subCategory) async {
    try {
      final id = subCategory.sId;
      if (id == null || id.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شناسه زیر‌دسته نامعتبر است');
        return;
      }

      final result = await _subService.deleteSubCategory(documentId: id);

      if (result.isSuccess) {
        SnackBarHelper.showSuccessSnackBar('زیر‌دسته با موفقیت حذف شد');
        await _dataProvider.getAllSubCategories();
      } else {
        final err = result.requireError();
        SnackBarHelper.showErrorSnackBar(
          err.userMessage.isNotEmpty
              ? err.userMessage
              : (err.devMessage ?? 'حذف زیر‌دسته ناموفق بود'),
        );
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('خطا در حذف زیر‌دسته: $e');
    }
  }

  // ---------- Editing context ----------
  void setDataForUpdateSubCategory(SubCategory? subCategory) {
    if (subCategory != null) {
      subCategoryForUpdate = subCategory;
      subCategoryNameCtrl.text = subCategory.name ?? '';

      // سعی می‌کنیم کتگوری متناظر را در لیست کتگوری‌ها پیدا کنیم
      final allCategories = _dataProvider.categories;

      selectedCategory = allCategories.firstWhereOrNull(
            (c) =>
        c.sId == (subCategory.categoryId?.sId ?? subCategory.category),
      );

    } else {
      clearFields();
    }
    notifyListeners();
  }

  void clearFields() {
    subCategoryNameCtrl.clear();
    selectedCategory = null;
    subCategoryForUpdate = null;
    notifyListeners();
  }

  void updateUi() {
    notifyListeners();
  }
}
