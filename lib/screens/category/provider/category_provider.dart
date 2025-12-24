import 'dart:convert';
import 'dart:developer';
import 'dart:io';


import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/data/appwrite/category_appwrite_service.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';


class CategoryProvider extends ChangeNotifier {

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;


  final DataProvider _dataProvider;

  final CategoryAppwriteService _categoryService = CategoryAppwriteService(); // ✅ جدید

  final addCategoryFormKey = GlobalKey<FormState>();
  final TextEditingController categoryNameCtrl = TextEditingController();

  Category? categoryForUpdate;
  File? selectedImage;
  XFile? imgXFile;

  Category? _currentEditingCategory;
  Category? get currentEditingCategory => _currentEditingCategory;

  CategoryProvider(this._dataProvider);


  Future<bool> submitCategory() async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    notifyListeners();

    try {
      // شماره تلفن از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return false;
      }

      final String name = categoryNameCtrl.text.trim();
      if (name.isEmpty) {
        SnackBarHelper.showErrorSnackBar('لطفاً نام دسته‌بندی را وارد کنید');
        return false;
      }

      final String? targetId = categoryForUpdate?.sId;
      final bool isUpdate = (targetId != null && targetId.isNotEmpty);

      // خواندن تصویر (در صورت وجود)
      Uint8List? bytes;
      String? filename;

      if (imgXFile != null) {
        bytes = await imgXFile!.readAsBytes();
        filename = imgXFile!.name;
      }

      // در افزودن، تصویر اجباری است
      if (!isUpdate && bytes == null) {
        SnackBarHelper.showErrorSnackBar('لطفاً تصویر را انتخاب کنید');
        return false;
      }

      // تماس با سرویس Appwrite
      final result = isUpdate
          ? await _categoryService.updateCategory(
        documentId: targetId!,
        name: name,
   phoneNumberCode: phone,

        imageBytes: bytes,
        filename: filename,
        existingImageUrl: categoryForUpdate?.image,
      )
          : await _categoryService.createCategoryWithImage(
        name: name,
       phoneNumberCode: phone,

        imageBytes: bytes!,
        filename: filename!,
      );

      if (result.isSuccess) {
        await _dataProvider.getAllCategories(showSnack: true);

        final msg = isUpdate
            ? 'دسته‌بندی با موفقیت ویرایش شد'
            : 'دسته‌بندی با موفقیت ایجاد شد';
        SnackBarHelper.showSuccessSnackBar(msg);

        clearFields();
        return true;
      } else {
        final error = result.requireError();
        SnackBarHelper.showErrorSnackBar(
          error.userMessage.isNotEmpty
              ? error.userMessage
              : (error.devMessage ?? 'عملیات ناموفق بود'),
        );
        return false;
      }
    } catch (e) {
      log(e.toString());
      SnackBarHelper.showErrorSnackBar('خطا در ثبت دسته‌بندی: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }



  Future<void> deleteCategory(Category category) async {
    try {
      final String? categoryId = category.sId;
      if (categoryId == null || categoryId.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شناسه دسته‌بندی نامعتبر است');
        return;
      }

      final result = await _categoryService.deleteCategory(
        documentId: categoryId,
        existingImageUrl: category.image, // ✅ آدرس عکس فعلی برای حذف
      );

      if (result.isSuccess) {
        SnackBarHelper.showSuccessSnackBar('دسته‌بندی با موفقیت حذف شد');
        await _dataProvider.getAllCategories();
      } else {
        final error = result.requireError();
        SnackBarHelper.showErrorSnackBar(
          error.userMessage.isNotEmpty
              ? error.userMessage
              : (error.devMessage ?? 'حذف دسته‌بندی ناموفق بود'),
        );
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('خطا در حذف دسته‌بندی: $e');
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
