
import 'package:admin/utility/User_helper.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/data/data_provider.dart';

import '../../../models/variant_type.dart';

import '../../../utility/snack_bar_helper.dart';



import 'package:flutter/material.dart';


import 'package:admin/core/data/appwrite/variant_types_repository.dart';


class VariantsTypeProvider extends ChangeNotifier {
  final DataProvider _dataProvider;
  final VariantTypesRepository _repo = VariantTypesRepository();

  VariantsTypeProvider(this._dataProvider);

  // Form state
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController typeCtrl = TextEditingController();

  VariantType? forUpdate;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<bool> submit() async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    notifyListeners();

    try {
      final form = formKey.currentState;
      if (form == null || !form.validate()) return false;
      form.save();

      return (forUpdate != null) ? await updateVariantType() : await addVariantType();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> addVariantType() async {
    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';
      if (phone.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن/کد پیدا نشد!');
        return false;
      }

      final entity = VariantType(
        name: nameCtrl.text.trim(),
        type: typeCtrl.text.trim(),
      phoneNumberCode: phone.trim(),
      );

      final res = await _repo.create(entity);

      if (res.isSuccess) {
        SnackBarHelper.showSuccessSnackBar('نوع ویژگی ایجاد شد');
        clearFields();
        await _dataProvider.getAllVariantTypes();
        return true;
      }

      final err = res.requireError();
      SnackBarHelper.showErrorSnackBar(err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'خطا در ایجاد'));
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Error: $e');
      return false;
    }
  }

  Future<bool> updateVariantType() async {
    try {
      final id = forUpdate?.sId ?? '';
      if (id.isEmpty) {
        SnackBarHelper.showErrorSnackBar('ID missing');
        return false;
      }

      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';
      if (phone.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن/کد پیدا نشد!');
        return false;
      }

      final entity = VariantType(
        name: nameCtrl.text.trim(),
        type: typeCtrl.text.trim(),
        phoneNumberCode: phone.trim(),

      );

      final res = await _repo.update(id, entity);

      if (res.isSuccess) {
        SnackBarHelper.showSuccessSnackBar('نوع ویژگی بروزرسانی شد');
        clearFields();
        await _dataProvider.getAllVariantTypes();
        return true;
      }

      final err = res.requireError();
      SnackBarHelper.showErrorSnackBar(err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'خطا در بروزرسانی'));
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Error: $e');
      return false;
    }
  }

  Future<void> deleteVariantType(VariantType item) async {
    try {
      final id = item.sId ?? '';
      if (id.isEmpty) {
        SnackBarHelper.showErrorSnackBar('ID missing');
        return;
      }

      final res = await _repo.delete(id);

      if (res.isSuccess) {
        SnackBarHelper.showSuccessSnackBar('حذف شد');
        await _dataProvider.getAllVariantTypes();
        return;
      }

      final err = res.requireError();
      SnackBarHelper.showErrorSnackBar(err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'خطا در حذف'));
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Error: $e');
    }
  }

  // ---------------- Form data
  void setDataForUpdate(VariantType? item) {
    if (item != null) {
      forUpdate = item;
      nameCtrl.text = item.name ?? '';
      typeCtrl.text = item.type ?? '';
    } else {
      clearFields();
    }
    notifyListeners();
  }

  void clearFields() {
    forUpdate = null;
    nameCtrl.clear();
    typeCtrl.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    typeCtrl.dispose();
    super.dispose();
  }
}

