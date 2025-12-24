
import 'package:admin/utility/User_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/data/data_provider.dart';

import '../../../models/variant.dart';
import '../../../models/variant_type.dart';

import '../../../utility/snack_bar_helper.dart';


import 'package:admin/core/data/appwrite/variants_repository.dart';

class VariantsProvider extends ChangeNotifier {
  final DataProvider _dataProvider;
  final VariantsRepository _repo = VariantsRepository();

  final addVariantsFormKey = GlobalKey<FormState>();
  final TextEditingController variantCtrl = TextEditingController();

  VariantType? selectedVariantType;
  Variant? variantForUpdate;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  VariantsProvider(this._dataProvider);

  Future<void> addVariant() async {
    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';
      if (phone.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن/کد پیدا نشد!');
        return;
      }

      if (selectedVariantType?.sId == null || selectedVariantType!.sId!.isEmpty) {
        SnackBarHelper.showErrorSnackBar('نوع ویژگی را انتخاب کنید');
        return;
      }

      final entity = Variant(
        name: variantCtrl.text.trim(),
        phoneNumberCode: phone.trim(),

        variantType: selectedVariantType!.sId!,
      );

      final res = await _repo.create(entity);

      if (res.isSuccess) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar('ویژگی ایجاد شد');
        await _dataProvider.getAllVariants(showSnack: true);
      } else {
        final err = res.requireError();
        SnackBarHelper.showErrorSnackBar(
          err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'خطا در ایجاد ویژگی'),
        );
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('خطا: $e');
      rethrow;
    }
  }

  Future<void> updateVariant() async {
    try {
      final String id = variantForUpdate?.sId ?? '';
      if (id.isEmpty) {
        SnackBarHelper.showErrorSnackBar('ID missing');
        return;
      }

      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';
      if (phone.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن/کد پیدا نشد!');
        return;
      }

      if (selectedVariantType?.sId == null || selectedVariantType!.sId!.isEmpty) {
        SnackBarHelper.showErrorSnackBar('نوع ویژگی را انتخاب کنید');
        return;
      }

      final entity = Variant(
        name: variantCtrl.text.trim(),
       phoneNumberCode: phone.trim(),

        variantType: selectedVariantType!.sId!,
      );

      final res = await _repo.update(id, entity);

      if (res.isSuccess) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar('ویژگی بروزرسانی شد');
        await _dataProvider.getAllVariants(showSnack: true);
      } else {
        final err = res.requireError();
        SnackBarHelper.showErrorSnackBar(
          err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'خطا در بروزرسانی ویژگی'),
        );
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('خطا: $e');
      rethrow;
    }
  }

  Future<void> submitVariant() async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    notifyListeners();

    try {
      final form = addVariantsFormKey.currentState;
      if (form == null || !form.validate()) return;
      form.save();

      if (variantForUpdate == null) {
        await addVariant();
      } else {
        await updateVariant();
      }
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteVariant(Variant item) async {
    try {
      final id = item.sId ?? '';
      if (id.isEmpty) {
        SnackBarHelper.showErrorSnackBar('ID missing');
        return;
      }

      final res = await _repo.delete(id);
      if (res.isSuccess) {
        SnackBarHelper.showSuccessSnackBar('حذف شد');
        await _dataProvider.getAllVariants(showSnack: true);
      } else {
        final err = res.requireError();
        SnackBarHelper.showErrorSnackBar(
          err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'خطا در حذف'),
        );
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('خطا: $e');
    }
  }

  void setDataForUpdateVariant(Variant? variant) {
    if (variant != null) {
      variantForUpdate = variant;
      variantCtrl.text = variant.name ?? '';

      final vtId = variant.variantType ?? variant.variantTypeId?.sId;

      if (vtId != null && _dataProvider.variantTypes.isNotEmpty) {
        selectedVariantType =
            _dataProvider.variantTypes.firstWhereOrNull((t) => t.sId == vtId);
      } else {
        selectedVariantType = null; // بعداً hydrate می‌شود
      }
    } else {
      clearFields();
    }

    notifyListeners();
  }

  void hydrateSelectedType(String? vtId) {
    if (vtId == null) return;
    if (selectedVariantType == null && _dataProvider.variantTypes.isNotEmpty) {
      selectedVariantType =
          _dataProvider.variantTypes.firstWhereOrNull((t) => t.sId == vtId);
      notifyListeners();
    }
  }

  void clearFields() {
    variantCtrl.clear();
    selectedVariantType = null;
    variantForUpdate = null;
  }

  void updateUI() => notifyListeners();

  @override
  void dispose() {
    variantCtrl.dispose();
    super.dispose();
  }
}

