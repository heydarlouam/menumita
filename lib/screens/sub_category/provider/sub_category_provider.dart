import 'dart:convert';
import 'dart:developer';


import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../models/sub_category.dart';
import '../../../services/http_services.dart';


class SubCategoryProvider extends ChangeNotifier {
  final HttpService service = HttpService();
  final DataProvider _dataProvider;

  final addSubCategoryFormKey = GlobalKey<FormState>();
  final TextEditingController subCategoryNameCtrl = TextEditingController();

  Category? selectedCategory;
  SubCategory? subCategoryForUpdate;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  SubCategoryProvider(this._dataProvider);

  // ---------- Helpers ----------
  Map<String, dynamic>? _parseBody(dynamic body) {
    if (body == null) return null;
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return body.cast<String, dynamic>();
    if (body is String) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map) return decoded.cast<String, dynamic>();
      } catch (_) {}
    }
    return null;
  }

  bool _okFlag(Map<String, dynamic>? m) =>
      m != null && (m['success'] == true || m['ok'] == true);

  String _msg(Map<String, dynamic>? m, String fallback) =>
      (m != null && m['message'] is String && (m['message'] as String).isNotEmpty)
          ? m!['message'] as String
          : fallback;

  // ---------- Create ----------
  Future<bool> addSubCategory() async {
    try {
      final Map<String, dynamic> subCategory = {
        'name': subCategoryNameCtrl.text,
        'category': selectedCategory?.sId,
        'phone_number_code':'12345'
      };

      final response = await service.addItem(
        endpointUrl: 'api/subcategories',
        itemData: subCategory,
      );

      if (response.isOk) {
        final m = _parseBody(response.body);
        if (_okFlag(m)) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(
              _msg(m, 'Sub category added successfully'));
          log('sub category added');
          await _dataProvider.getAllSubCategories();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to add sub category: ${m?['error'] ?? m?['message'] ?? 'Unknown error'}');
          return false;
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error: ${response.statusText}');
        return false;
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  // ---------- Update ----------
  Future<bool> updateSubCategory() async {
    try {
      final Map<String, dynamic> subCategory = {
        'name': subCategoryNameCtrl.text,
        'category': selectedCategory?.sId,
        'phone_number_code':'12345'
      };

      final response = await service.updateItem(
        endpointUrl: 'api/subcategories',
        itemId: subCategoryForUpdate?.sId ?? '',
        itemData: subCategory,
      );

      if (response.isOk) {
        final m = _parseBody(response.body);
        if (_okFlag(m)) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(
              _msg(m, 'Sub category updated successfully'));
          log('sub category updated');
          await _dataProvider.getAllSubCategories();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to update sub category: ${m?['error'] ?? m?['message'] ?? 'Unknown error'}');
          return false;
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error: ${response.statusText}');
        return false;
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  // ---------- Unified Submit (decides add/update) ----------
  Future<bool> submitSubCategory() async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    notifyListeners();

    try {
      if (addSubCategoryFormKey.currentState?.validate() != true) {
        return false;
      }
      addSubCategoryFormKey.currentState?.save();

      if (subCategoryForUpdate != null) {
        return await updateSubCategory();
      } else {
        return await addSubCategory();
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
  Future<bool> deleteSubCategory(SubCategory subCategory) async {
    try {
      final response = await service.deleteItem(
        endpointUrl: 'api/subcategories',
        itemId: subCategory.sId ?? '',
      );

      if (response.isOk) {
        final m = _parseBody(response.body);
        if (_okFlag(m)) {
          SnackBarHelper.showSuccessSnackBar(
              _msg(m, 'Sub category deleted successfully!'));
          await _dataProvider.getAllSubCategories();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to delete: ${m?['error'] ?? m?['message'] ?? 'Unknown error'}');
          return false;
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error: ${response.statusText}');
        return false;
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  // ---------- Editing context ----------
  void setDataForUpdateSubCategory(SubCategory? subCategory) {
    if (subCategory != null) {
      subCategoryForUpdate = subCategory;
      subCategoryNameCtrl.text = subCategory.name ?? '';
      // پیدا کردن Category متناظر برای انتخاب اولیه
      selectedCategory = _dataProvider.categories.firstWhereOrNull(
            (c) => c.sId == subCategory.categoryId?.sId,
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
