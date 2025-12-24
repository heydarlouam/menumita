
import 'dart:io';


import 'package:admin/utility/User_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;

import 'package:image_picker/image_picker.dart';

import '../../../core/data/data_provider.dart';

import '../../../models/poster.dart';

import '../../../utility/snack_bar_helper.dart';


import 'dart:typed_data';

import 'package:admin/core/data/appwrite/poster_appwrite_service.dart';

class PosterProvider extends ChangeNotifier {
  final DataProvider _dataProvider;

  PosterProvider(this._dataProvider);

  final PosterAppwriteService _posterService = PosterAppwriteService();

  final addPosterFormKey = GlobalKey<FormState>();
  final TextEditingController posterNameCtrl = TextEditingController();

  Poster? posterForUpdate;
  Poster? _currentEditingPoster;
  Poster? get currentEditingPoster => _currentEditingPoster;

  File? selectedImage;
  XFile? imgXFile;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  void _log(String message, [Object? extra]) {
    if (kDebugMode) {
      debugPrint('[PosterProvider] $message ${extra ?? ''}');
    }
  }

  // ---------- Image Picking ----------
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      imgXFile = image;
      _log('image selected', image.path);

      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  // ---------- Editing context ----------
  void setDataForUpdatePoster(Poster? poster) {
    _currentEditingPoster = poster;

    if (poster != null) {
      posterForUpdate = poster;
      posterNameCtrl.text = poster.posterName ?? '';
    } else {
      clearFields();
    }
  }

  void clearFields() {
    posterForUpdate = null;
    _currentEditingPoster = null;
    posterNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    _log('fields cleared');

    if (hasListeners) {
      notifyListeners();
    }
  }

  // ---------- Submit (create / update) ----------
  Future<bool> submitPoster() async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    if (hasListeners) notifyListeners();

    try {
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return false;
      }

      final String name = posterNameCtrl.text.trim();
      if (name.isEmpty) {
        SnackBarHelper.showErrorSnackBar('لطفاً نام پوستر را وارد کنید');
        return false;
      }

      final String? targetId = posterForUpdate?.sId;
      final bool isUpdate = (targetId != null && targetId.isNotEmpty);

      Uint8List? bytes;
      String? filename;

      if (imgXFile != null) {
        bytes = await imgXFile!.readAsBytes();
        filename = imgXFile!.name;
      }

      // در افزودن، تصویر اجباری است
      if (!isUpdate && bytes == null) {
        SnackBarHelper.showErrorSnackBar('لطفاً تصویر پوستر را انتخاب کنید');
        return false;
      }

      final result = isUpdate
          ? await _posterService.updatePoster(
        documentId: targetId!,
        name: name,
         phoneNumberCode: phone,

        imageBytes: bytes,
        filename: filename,
        existingImageUrl: posterForUpdate?.imageUrl,
      )
          : await _posterService.createPosterWithImage(
        name: name,
         phoneNumberCode: phone,

        imageBytes: bytes!,
        filename: filename!,
      );

      if (result.isSuccess) {
        await _dataProvider.getAllPosters(showSnack: true);

        final msg = isUpdate
            ? 'پوستر با موفقیت ویرایش شد'
            : 'پوستر با موفقیت ایجاد شد';
        SnackBarHelper.showSuccessSnackBar(msg);

        clearFields();
        return true;
      } else {
        final error = result.requireError();
        SnackBarHelper.showErrorSnackBar(
          error.userMessage.isNotEmpty
              ? error.userMessage
              : (error.devMessage ?? 'ثبت پوستر ناموفق بود'),
        );
        return false;
      }
    } catch (e) {
      _log('submitPoster error', e);
      SnackBarHelper.showErrorSnackBar('خطا در ثبت پوستر: $e');
      return false;
    } finally {
      _isSubmitting = false;
      if (hasListeners) notifyListeners();
    }
  }

  // ---------- Delete ----------
  Future<bool> deletePoster(Poster poster) async {
    try {
      final String? posterId = poster.sId;
      if (posterId == null || posterId.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شناسه پوستر نامعتبر است');
        return false;
      }

      final result = await _posterService.deletePoster(
        documentId: posterId,
        existingImageUrl: poster.imageUrl,
      );

      if (result.isSuccess) {
        SnackBarHelper.showSuccessSnackBar('پوستر با موفقیت حذف شد');
        await _dataProvider.getAllPosters();
        return true;
      } else {
        final error = result.requireError();
        SnackBarHelper.showErrorSnackBar(
          error.userMessage.isNotEmpty
              ? error.userMessage
              : (error.devMessage ?? 'حذف پوستر ناموفق بود'),
        );
        return false;
      }
    } catch (e) {
      _log('deletePoster error', e);
      SnackBarHelper.showErrorSnackBar('خطا در حذف پوستر: $e');
      return false;
    }
  }
}

