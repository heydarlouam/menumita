import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:admin/core/data/repositories/category_repository.dart';
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';

import 'package:admin/services/auth_api.dart';

class CategoryProvider extends ChangeNotifier {
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  final CategoryRepository repository = CategoryRepository();
  final DataProvider _dataProvider;

  final addCategoryFormKey = GlobalKey<FormState>();
  final TextEditingController categoryNameCtrl = TextEditingController();

  Category? categoryForUpdate;
  File? selectedImage;
  XFile? imgXFile;

  Category? _currentEditingCategory;
  Category? get currentEditingCategory => _currentEditingCategory;

  CategoryProvider(this._dataProvider);

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

  bool _isOk(Response res) => res.isOk;
  bool _okFlag(Map<String, dynamic>? m) =>
      m != null && (m['success'] == true || m['ok'] == true);
  String _msg(Map<String, dynamic>? m, String fallback) => (m != null &&
          m['message'] is String &&
          (m['message'] as String).isNotEmpty)
      ? m!['message'] as String
      : fallback;

  // ---------- Create ----------
  //  Future<void> addCategory() async {
  //    try {
  //      if (selectedImage == null && imgXFile == null) {
  //        SnackBarHelper.showErrorSnackBar('Please choose an image!');
  //        return;
  //      }
  //
  //      final Map<String, dynamic> formDataMap = {
  //        'name': categoryNameCtrl.text,
  // 'phone_number_code':'12345'
  //      };
  //
  //      final FormData form =
  //      await createFormData(imgXFile: imgXFile, formData: formDataMap);
  //
  //      final res = await service.addItem(
  //        endpointUrl: 'api/categories',
  //        itemData: form,
  //      );
  //
  //      if (_isOk(res)) {
  //        final body = _parseBody(res.body);
  //        if (_okFlag(body)) {
  //          clearFields();
  //          SnackBarHelper.showSuccessSnackBar(
  //              _msg(body, 'Category created successfully'));
  //          log('category added');
  //          await _dataProvider.getAllCategories();
  //        } else {
  //          SnackBarHelper.showErrorSnackBar(
  //              'Failed to add category: ${body?['error'] ?? 'Unknown error'}');
  //        }
  //      } else {
  //        SnackBarHelper.showErrorSnackBar(
  //            'Error: ${res.body?['error'] ?? res.statusText}');
  //      }
  //    } catch (e) {
  //      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
  //      rethrow;
  //    }
  //  }
  //
  //  // ---------- Update ----------
  //  Future<void> updateCategory() async {
  //    try {
  //      if (categoryForUpdate == null) {
  //        SnackBarHelper.showErrorSnackBar('Category data is missing');
  //        return;
  //      }
  //      final String? categoryId = categoryForUpdate?.sId;
  //      if (categoryId == null || categoryId.isEmpty) {
  //        SnackBarHelper.showErrorSnackBar('Category ID is missing');
  //        return;
  //      }
  //
  //      final Map<String, dynamic> formDataMap = {
  //        'name': categoryNameCtrl.text,
  //        'phone_number_code':'12345'
  //      };
  //
  //      final FormData form =
  //      await createFormData(imgXFile: imgXFile, formData: formDataMap);
  //
  //      final res = await service.updateItem(
  //        endpointUrl: 'api/categories',
  //        itemId: categoryId,
  //        itemData: form,
  //      );
  //
  //      if (_isOk(res)) {
  //        final body = _parseBody(res.body);
  //        if (_okFlag(body)) {
  //          clearFields();
  //          SnackBarHelper.showSuccessSnackBar(
  //              _msg(body, 'Category updated successfully'));
  //          log('category updated');
  //          await _dataProvider.getAllCategories();
  //        } else {
  //          SnackBarHelper.showErrorSnackBar(
  //              'Failed to update category: ${body?['error'] ?? 'Unknown error'}');
  //        }
  //      } else {
  //        SnackBarHelper.showErrorSnackBar(
  //            'Error: ${res.body?['error'] ?? res.statusText}');
  //      }
  //    } catch (e) {
  //      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
  //      rethrow;
  //    }
  //  }
  //
  //
  //  Future<bool> submitCategory() async {
  //    if (_isSubmitting) return false; // درحال ارسال: کاری نکن
  //    _isSubmitting = true;
  //    notifyListeners();
  //
  //    try {
  //      final Map<String, dynamic> formDataMap = {
  //        'name': categoryNameCtrl.text,
  //        'phone_number_code':'12345'
  //      };
  //      final FormData form =
  //      await createFormData(imgXFile: imgXFile, formData: formDataMap);
  //
  //      final String? targetId = categoryForUpdate?.sId;
  //      final bool isUpdate = (targetId != null && targetId.isNotEmpty);
  //
  //      // در افزودن (نه ویرایش) تصویر اجباری است
  //      if (!isUpdate && imgXFile == null) {
  //        SnackBarHelper.showErrorSnackBar('Please choose an image!');
  //        return false;
  //      }
  //
  //      final Response res = isUpdate
  //          ? await service.updateItem(
  //        endpointUrl: 'api/categories',
  //        itemId: targetId!,
  //        itemData: form,
  //      )
  //          : await service.addItem(
  //        endpointUrl: 'api/categories',
  //        itemData: form,
  //      );
  //
  //      // parse امن
  //      Map<String, dynamic>? body;
  //      final dynamic raw = res.body;
  //      if (raw is String) {
  //        try {
  //          final decoded = jsonDecode(raw);
  //          if (decoded is Map) body = decoded.cast<String, dynamic>();
  //        } catch (_) {}
  //      } else if (raw is Map) {
  //        body = raw.cast<String, dynamic>();
  //      }
  //
  //      final okFlag = body != null && (body!['success'] == true || body!['ok'] == true);
  //
  //      if (res.isOk && okFlag) {
  //        await _dataProvider.getAllCategories(showSnack: true);
  //        final msg = (body?['message'] as String?) ??
  //            (isUpdate ? 'Category updated successfully' : 'Category created successfully');
  //        SnackBarHelper.showSuccessSnackBar(msg);
  //        clearFields();
  //        return true; // ✅ به Caller بگو موفق شد
  //      } else {
  //        final errMsg = body?['message'] ??
  //            body?['error'] ??
  //            'Operation failed';
  //        SnackBarHelper.showErrorSnackBar(errMsg.toString());
  //        return false;
  //      }
  //    } catch (e) {
  //      log(e.toString());
  //      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
  //      return false;
  //    } finally {
  //      _isSubmitting = false;
  //      notifyListeners();
  //    }
  //  }

  // ---------- Create ----------
  Future<void> addCategory() async {
    try {
      if (selectedImage == null && imgXFile == null) {
        SnackBarHelper.showErrorSnackBar('Please choose an image!');
        return;
      }

      // ✅ گرفتن شماره از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return;
      }

      final Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text,
        'phone_number_code': phone, // 👈 جایگزین عدد ثابت
      };

      final FormData form =
          await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final res = await repository.addCategory(form);

      if (_isOk(res)) {
        final body = _parseBody(res.body);
        if (_okFlag(body)) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(
              _msg(body, 'Category created successfully'));
          log('category added');
          await _dataProvider.getAllCategories();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to add category: ${body?['error'] ?? 'Unknown error'}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error: ${res.body?['error'] ?? res.statusText}');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

// ---------- Update ----------
  Future<void> updateCategory() async {
    try {
      if (categoryForUpdate == null) {
        SnackBarHelper.showErrorSnackBar('Category data is missing');
        return;
      }
      final String? categoryId = categoryForUpdate?.sId;
      if (categoryId == null || categoryId.isEmpty) {
        SnackBarHelper.showErrorSnackBar('Category ID is missing');
        return;
      }

      // ✅ گرفتن شماره از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return;
      }

      final Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text,
        'phone_number_code': phone, // 👈 جایگزین عدد ثابت
      };

      final FormData form =
          await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final res = await repository.updateCategory(categoryId, form);

      if (_isOk(res)) {
        final body = _parseBody(res.body);
        if (_okFlag(body)) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(
              _msg(body, 'Category updated successfully'));
          log('category updated');
          await _dataProvider.getAllCategories();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to update category: ${body?['error'] ?? 'Unknown error'}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error: ${res.body?['error'] ?? res.statusText}');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

// ---------- Unified Submit ----------
  Future<bool> submitCategory() async {
    if (_isSubmitting) return false; // درحال ارسال: کاری نکن
    _isSubmitting = true;
    notifyListeners();

    try {
      // ✅ گرفتن شماره از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return false;
      }

      final Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text,
        'phone_number_code': phone, // 👈 جایگزین عدد ثابت
      };

      final FormData form =
          await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final String? targetId = categoryForUpdate?.sId;
      final bool isUpdate = (targetId != null && targetId.isNotEmpty);

      // در افزودن (نه ویرایش) تصویر اجباری است
      if (!isUpdate && imgXFile == null) {
        SnackBarHelper.showErrorSnackBar('Please choose an image!');
        return false;
      }

      final Response res = isUpdate
          ? await repository.updateCategory(targetId!, form)
          : await repository.addCategory(form);

      // parse امن
      Map<String, dynamic>? body;
      final dynamic raw = res.body;
      if (raw is String) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map) body = decoded.cast<String, dynamic>();
        } catch (_) {}
      } else if (raw is Map) {
        body = raw.cast<String, dynamic>();
      }

      final okFlag =
          body != null && (body!['success'] == true || body!['ok'] == true);

      if (res.isOk && okFlag) {
        await _dataProvider.getAllCategories(showSnack: true);
        final msg = (body?['message'] as String?) ??
            (isUpdate
                ? 'Category updated successfully'
                : 'Category created successfully');
        SnackBarHelper.showSuccessSnackBar(msg);
        clearFields();
        return true; // ✅ موفقیت
      } else {
        final errMsg = body?['message'] ?? body?['error'] ?? 'Operation failed';
        SnackBarHelper.showErrorSnackBar(errMsg.toString());
        return false;
      }
    } catch (e) {
      log(e.toString());
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ---------- Delete ----------
  Future<void> deleteCategory(Category category) async {
    try {
      final res = await repository.deleteCategory(category.sId ?? '');

      if (_isOk(res)) {
        final body = _parseBody(res.body);
        if (_okFlag(body)) {
          SnackBarHelper.showSuccessSnackBar(
              _msg(body, 'Category deleted successfully!'));
          await _dataProvider.getAllCategories();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to delete category: ${body?['error'] ?? 'Unknown error'}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error: ${res.body?['error'] ?? res.statusText}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ---------- Image Picking ----------
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      imgXFile = image;
      notifyListeners();
    }
  }

  // ---------- FormData Builder ----------
  Future<FormData> createFormData({
    required XFile? imgXFile,
    required Map<String, dynamic> formData,
  }) async {
    if (imgXFile != null) {
      try {
        final String fileName = imgXFile.name;
        final Uint8List byteImg = await imgXFile.readAsBytes();
        final MultipartFile multipartFile =
            MultipartFile(byteImg, filename: fileName);
        formData['image'] = multipartFile; // کلید image
      } catch (e) {
        rethrow;
      }
    }
    return FormData(formData);
  }

  // ---------- Editing context ----------
  void setDataForUpdateCategory(Category? category) {
    _currentEditingCategory = category;
    if (category != null) {
      categoryForUpdate = category;
      categoryNameCtrl.text = category.name ?? '';
    } else {
      clearFields();
    }
  }

  void clearFields() {
    _currentEditingCategory = null;
    categoryNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    categoryForUpdate = null;
    notifyListeners();
  }
}
