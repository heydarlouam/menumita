
import 'dart:io';

import 'package:admin/utility/User_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/data/data_provider.dart';

import '../../../models/poster.dart';
import '../../../core/data/repositories/category_repository.dart';
import '../../../utility/snack_bar_helper.dart';


class PosterProvider extends ChangeNotifier {
  final PosterRepository repository = PosterRepository();
  final DataProvider _dataProvider;

  final addPosterFormKey = GlobalKey<FormState>();
  final TextEditingController posterNameCtrl = TextEditingController();

  Poster? posterForUpdate;

  File? selectedImage;   // ✅ مثل Category
  XFile? imgXFile;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  PosterProvider(this._dataProvider);

  // ---------- Image Picking (مثل Category) ----------
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path); // ✅ حتی روی وب: blob به‌صورت path
      imgXFile = image;
      notifyListeners();                // ✅ برای Consumer
    }
  }


  Future<FormData> _buildFormData() async {
    // ✅ گرفتن شماره از SharedPreferences
    final phone = await UserSaveHelper.getPhoneNumber();
    if (phone == null || phone.isEmpty) {
      SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
      // برای توقف جریان و جلوگیری از ارسال فرم بدون شماره
      throw Exception('missing phone_number in SharedPreferences');
    }

    final Map<String, dynamic> fields = {
      'poster_name': posterNameCtrl.text,
      'phone_number_code': phone, // ⬅️ به‌جای مقدار ثابت
    };

    if (imgXFile != null) {
      final String fileName = imgXFile!.name;
      final bytes = await imgXFile!.readAsBytes();
      final mf = MultipartFile(bytes, filename: fileName);
      fields['image'] = mf; // کلید فایل
    }

    return FormData(fields);
  }

  // ---------- Add ----------
  Future<bool> addPoster() async {
    try {
      if (imgXFile == null) {
        SnackBarHelper.showErrorSnackBar('Please choose an image!');
        return false;
      }
      final form = await _buildFormData();

      final res = await repository.addPoster(form);

      if (res.isOk && (res.body is Map && ((res.body['success']==true) || (res.body['ok']==true)))) {
        SnackBarHelper.showSuccessSnackBar(res.body['message'] ?? 'Poster created successfully');
        clearFields();
        await _dataProvider.getAllPosters();
        return true;
      }
      SnackBarHelper.showErrorSnackBar(res.body?['message'] ?? res.body?['error'] ?? 'Failed to add poster');
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  // ---------- Update ----------
  Future<bool> updatePoster() async {
    try {
      final id = posterForUpdate?.sId ?? '';
      if (id.isEmpty) {
        SnackBarHelper.showErrorSnackBar('Poster ID is missing');
        return false;
      }
      final form = await _buildFormData();
      final res = await repository.updatePoster(id, form);

      if (res.isOk && (res.body is Map && ((res.body['success']==true) || (res.body['ok']==true)))) {
        SnackBarHelper.showSuccessSnackBar(res.body['message'] ?? 'Poster updated successfully');
        clearFields();
        await _dataProvider.getAllPosters();
        return true;
      }
      SnackBarHelper.showErrorSnackBar(res.body?['message'] ?? res.body?['error'] ?? 'Failed to update poster');
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  // ---------- Unified Submit ----------
  Future<bool> submitPoster() async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    notifyListeners();

    try {
      final form = addPosterFormKey.currentState;
      if (form == null || !form.validate()) return false;
      form.save();

      if (posterForUpdate != null) {
        return await updatePoster();
      } else {
        return await addPoster();
      }
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ---------- Delete ----------
  Future<bool> deletePoster(Poster poster) async {
    try {
      final id = poster.sId ?? '';
      if (id.isEmpty) return false;

      final res = await repository.deletePoster(id);
      if (res.isOk && (res.body is Map && ((res.body['success']==true) || (res.body['ok']==true)))) {
        SnackBarHelper.showSuccessSnackBar(res.body['message'] ?? 'Poster deleted successfully!');
        await _dataProvider.getAllPosters();
        return true;
      }
      SnackBarHelper.showErrorSnackBar(res.body?['message'] ?? res.body?['error'] ?? 'Failed to delete poster');
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  // ---------- Editing context ----------
  void setDataForUpdatePoster(Poster? poster) {
    if (poster != null) {
      posterForUpdate = poster;
      posterNameCtrl.text = poster.posterName ?? '';
      selectedImage = null; // ✅ تا وقتی عکس جدید انتخاب نشد، همون imageUrl نمایش داده شود
      imgXFile = null;
    } else {
      clearFields();
    }
    notifyListeners();
  }

  void clearFields() {
    posterForUpdate = null;
    posterNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    notifyListeners();
  }
}

