
import 'dart:io';

import 'package:admin/utility/User_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
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

  // ---------- Logging ----------
  void _logProgress(String step, [Object? payload]) {
    if (!kDebugMode) return;
    final buffer = StringBuffer('🟪 PosterSubmit → $step');
    if (payload != null) buffer.write(' | $payload');
    debugPrint(buffer.toString());
  }

  // ---------- Image Picking (مثل Category) ----------
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path); // ✅ حتی روی وب: blob به‌صورت path
      imgXFile = image;
      _logProgress('image picked', image.name);
      notifyListeners();                // ✅ برای Consumer
    }
  }


  Future<FormData> _buildFormData() async {
    _logProgress('build form data:start');
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
      _logProgress('attach image', fileName);
      if (kIsWeb) {
        final bytes = await imgXFile!.readAsBytes();
        _logProgress('image bytes ready', 'length=${bytes.length}');
        fields['image'] = MultipartFile(bytes, filename: fileName);
      } else {
        final filePath = imgXFile!.path;
        final fileNameFromPath = filePath.split('/').last;
        fields['image'] = await MultipartFile(filePath, filename: fileNameFromPath);
      }
    }

    final form = FormData(fields);
    _logProgress('form data ready', 'fields=${form.fields.length}, files=${form.files.length}');
    return form;
  }

  // ---------- Add ----------
  Future<bool> addPoster() async {
    try {
      if (imgXFile == null) {
        SnackBarHelper.showErrorSnackBar('Please choose an image!');
        _logProgress('validation failed', 'image missing');
        return false;
      }
      _logProgress('add poster:start');
      final form = await _buildFormData();

      final res = await repository.addPoster(form);

      if (res.isOk && (res.body is Map && ((res.body['success']==true) || (res.body['ok']==true)))) {
        SnackBarHelper.showSuccessSnackBar(res.body['message'] ?? 'Poster created successfully');
        _logProgress('add poster:success', res.body?['message']);
        clearFields();
        await _dataProvider.getAllPosters();
        return true;
      }
      SnackBarHelper.showErrorSnackBar(res.body?['message'] ?? res.body?['error'] ?? 'Failed to add poster');
      _logProgress('add poster:error', res.body?['message'] ?? res.body?['error']);
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      _logProgress('add poster:exception', e);
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
      _logProgress('update poster:start', id);
      final form = await _buildFormData();
      final res = await repository.updatePoster(id, form);

      if (res.isOk && (res.body is Map && ((res.body['success']==true) || (res.body['ok']==true)))) {
        SnackBarHelper.showSuccessSnackBar(res.body['message'] ?? 'Poster updated successfully');
        _logProgress('update poster:success', res.body?['message']);
        clearFields();
        await _dataProvider.getAllPosters();
        return true;
      }
      SnackBarHelper.showErrorSnackBar(res.body?['message'] ?? res.body?['error'] ?? 'Failed to update poster');
      _logProgress('update poster:error', res.body?['message'] ?? res.body?['error']);
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      _logProgress('update poster:exception', e);
      return false;
    }
  }

  // ---------- Unified Submit ----------
  // Future<bool> submitPoster() async {
  //   if (_isSubmitting) return false;
  //   _isSubmitting = true;
  //   notifyListeners();
  //   _logProgress('submit:start', posterForUpdate == null ? 'create' : 'update');
  //
  //   try {
  //     final form = addPosterFormKey.currentState;
  //     if (form == null) {
  //       _logProgress('submit:error', 'form state missing');
  //       return false;
  //     }
  //     if (!form.validate()) {
  //       _logProgress('submit:error', 'form invalid');
  //       return false;
  //     }
  //     form.save();
  //
  //     if (posterForUpdate != null) {
  //       return await updatePoster();
  //     } else {
  //       return await addPoster();
  //     }
  //   } finally {
  //     _isSubmitting = false;
  //     notifyListeners();
  //      _logProgress('submit:finished');
  //   }
  // }

  Future<bool> submitPoster() async {
    final form = addPosterFormKey.currentState;
    if (form == null) {
      _logProgress('submit:error', 'form state missing');
      return false;
    }

    if (!form.validate()) {
      _logProgress('submit:error', 'form invalid');
      return false;
    }

    form.save();

    try {
      if (posterForUpdate != null) {
        return await updatePoster();
      } else {
        return await addPoster();
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('خطا در ارسال: $e');
      _logProgress('submit:exception', e);
      return false;
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
      _logProgress('set update context', poster.sId);
    } else {
      clearFields();
    }
    notifyListeners();
  }

  // void clearFields() {
  //   posterForUpdate = null;
  //   posterNameCtrl.clear();
  //   selectedImage = null;
  //   imgXFile = null;
  //   _logProgress('fields cleared');
  //   notifyListeners();
  // }
  void clearFields() {
    posterForUpdate = null;
    posterNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    _logProgress('fields cleared');

    // فقط اگه هنوز کسی داره گوش میده، notify کن
    if (hasListeners) {
      notifyListeners();
    }
  }
}

