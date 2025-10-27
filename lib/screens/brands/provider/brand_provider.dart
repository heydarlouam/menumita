import 'dart:developer';

import 'package:admin/utility/User_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/data/data_provider.dart';

import '../../../models/brand.dart';
import '../../../models/sub_category.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

import 'dart:convert';

class BrandProvider extends ChangeNotifier {
  final HttpService service = HttpService();
  final DataProvider _dataProvider;

  final addBrandFormKey = GlobalKey<FormState>();
  final TextEditingController brandNameCtrl = TextEditingController();

  SubCategory? selectedSubCategory;
  Brand? brandForUpdate;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  BrandProvider(this._dataProvider);

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
  Future<bool> addBrand() async {
    try {
      // ✅ گرفتن شماره از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return false;
      }

      final Map<String, dynamic> brand = {
        'name': brandNameCtrl.text,
        'subcategory': selectedSubCategory?.sId,
        'phone_number_code': phone, // ← جایگزین عدد ثابت
      };

      final response = await service.addItem(
        endpointUrl: 'api/brands',
        itemData: brand,
      );

      if (response.isOk) {
        final m = _parseBody(response.body);
        if (_okFlag(m)) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(_msg(m, 'Brand added successfully'));
          log('brand added');
          await _dataProvider.getAllBrands();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(
            'Failed to add brand: ${m?['error'] ?? m?['message'] ?? 'Unknown error'}',
          );
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
  Future<bool> updateBrand() async {
    try {
      // ✅ گرفتن شماره از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return false;
      }

      final Map<String, dynamic> brand = {
        'name': brandNameCtrl.text,
        'subcategory': selectedSubCategory?.sId,
        'phone_number_code': phone, // ← جایگزین عدد ثابت
      };

      final response = await service.updateItem(
        endpointUrl: 'api/brands',
        itemId: brandForUpdate?.sId ?? '',
        itemData: brand,
      );

      if (response.isOk) {
        final m = _parseBody(response.body);
        if (_okFlag(m)) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(_msg(m, 'Brand updated successfully'));
          log('brand updated');
          await _dataProvider.getAllBrands();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(
            'Failed to update brand: ${m?['error'] ?? m?['message'] ?? 'Unknown error'}',
          );
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

  // // ---------- Create ----------
  // Future<bool> addBrand() async {
  //   try {
  //     final Map<String, dynamic> brand = {
  //       'name': brandNameCtrl.text,
  //       'subcategory': selectedSubCategory?.sId,
  //       'phone_number_code':'12345'
  //     };
  //
  //     final response = await service.addItem(
  //       endpointUrl: 'api/brands',
  //       itemData: brand,
  //     );
  //
  //     if (response.isOk) {
  //       final m = _parseBody(response.body);
  //       if (_okFlag(m)) {
  //         clearFields();
  //         SnackBarHelper.showSuccessSnackBar(
  //             _msg(m, 'Brand added successfully'));
  //         log('brand added');
  //         await _dataProvider.getAllBrands();
  //         return true;
  //       } else {
  //         SnackBarHelper.showErrorSnackBar(
  //             'Failed to add brand: ${m?['error'] ?? m?['message'] ?? 'Unknown error'}');
  //         return false;
  //       }
  //     } else {
  //       SnackBarHelper.showErrorSnackBar('Error: ${response.statusText}');
  //       return false;
  //     }
  //   } catch (e) {
  //     SnackBarHelper.showErrorSnackBar('An error occurred: $e');
  //     return false;
  //   }
  // }
  //
  // // ---------- Update ----------
  // Future<bool> updateBrand() async {
  //   try {
  //     final Map<String, dynamic> brand = {
  //       'name': brandNameCtrl.text,
  //       'subcategory': selectedSubCategory?.sId,
  //       'phone_number_code':'12345'
  //     };
  //
  //     final response = await service.updateItem(
  //       endpointUrl: 'api/brands',
  //       itemId: brandForUpdate?.sId ?? '',
  //       itemData: brand,
  //     );
  //
  //     if (response.isOk) {
  //       final m = _parseBody(response.body);
  //       if (_okFlag(m)) {
  //         clearFields();
  //         SnackBarHelper.showSuccessSnackBar(
  //             _msg(m, 'Brand updated successfully'));
  //         log('brand updated');
  //         await _dataProvider.getAllBrands();
  //         return true;
  //       } else {
  //         SnackBarHelper.showErrorSnackBar(
  //             'Failed to update brand: ${m?['error'] ?? m?['message'] ?? 'Unknown error'}');
  //         return false;
  //       }
  //     } else {
  //       SnackBarHelper.showErrorSnackBar('Error: ${response.statusText}');
  //       return false;
  //     }
  //   } catch (e) {
  //     SnackBarHelper.showErrorSnackBar('An error occurred: $e');
  //     return false;
  //   }
  // }

  // ---------- Unified Submit ----------
  Future<bool> submitBrand() async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    notifyListeners();

    try {
      if (addBrandFormKey.currentState?.validate() != true) {
        return false;
      }
      addBrandFormKey.currentState?.save();

      if (brandForUpdate != null) {
        return await updateBrand();
      } else {
        return await addBrand();
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
  Future<bool> deleteBrand(Brand brand) async {
    try {
      final response = await service.deleteItem(
        endpointUrl: 'api/brands',
        itemId: brand.sId ?? '',
      );

      if (response.isOk) {
        final m = _parseBody(response.body);
        if (_okFlag(m)) {
          SnackBarHelper.showSuccessSnackBar(
              _msg(m, 'Brand deleted successfully!'));
          await _dataProvider.getAllBrands();
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
  void setDataForUpdateBrand(Brand? brand) {
    if (brand != null) {
      brandForUpdate = brand;
      brandNameCtrl.text = brand.name ?? '';

      // انتخاب SubCategory متناظر با اولویت: expand → id
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

  void updateUi() {
    notifyListeners();
  }
}
