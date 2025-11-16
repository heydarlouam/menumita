
import 'package:admin/utility/User_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/data/data_provider.dart';

import '../../../models/variant.dart';
import '../../../models/variant_type.dart';
import '../../../core/data/repositories/category_repository.dart';
import '../../../utility/snack_bar_helper.dart';


import 'package:get/get_connect/http/src/response/response.dart';



class VariantsProvider extends ChangeNotifier {
  final VariantRepository repository = VariantRepository();
  final DataProvider _dataProvider;

  final addVariantsFormKey = GlobalKey<FormState>();
  final TextEditingController variantCtrl = TextEditingController();
  VariantType? selectedVariantType;

  Variant? variantForUpdate;

  // ✅ جدید: کنترل ارسال
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  VariantsProvider(this._dataProvider);


  Future<void> addVariant() async {
    try {
      // ⬅️ گرفتن شماره از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return;
      }

      final Map<String, dynamic> body = {
        'name': variantCtrl.text.trim(),
        'variant_type': selectedVariantType?.sId,
        'phone_number_code': phone, // ⬅️ جایگزین مقدار ثابت
      };

      final Response res = await repository.addVariant(body);

      if (res.isOk && (res.body?['success'] == true)) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar(
          res.body['message'] ?? 'Variant added successfully',
        );
        await _dataProvider.getAllVariants();
      } else {
        SnackBarHelper.showErrorSnackBar(
          res.body?['message'] ?? res.body?['error'] ?? res.statusText ?? 'Failed to add variant',
        );
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
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

      // ⬅️ گرفتن شماره از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return;
      }

      final Map<String, dynamic> body = {
        'name': variantCtrl.text.trim(),
        'phone_number_code': phone, // ⬅️ جایگزین مقدار ثابت
      };
      if (selectedVariantType?.sId != null) {
        body['variant_type'] = selectedVariantType!.sId;
      }

      final Response res = await repository.updateVariant(id, body);

      if (res.isOk && (res.body?['success'] == true)) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar(
          res.body['message'] ?? 'Variant updated successfully',
        );
        await _dataProvider.getAllVariants();
      } else {
        SnackBarHelper.showErrorSnackBar(
          res.body?['message'] ?? res.body?['error'] ?? res.statusText ?? 'Failed to update variant',
        );
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  // ✅ جدید: قفل ارسال مثل الگوی مرجع
  Future<void> submitVariant() async {
    if (_isSubmitting) return;
    _isSubmitting = true; notifyListeners();

    try {
      final form = addVariantsFormKey.currentState;
      if (form == null || !form.validate()) return;
      form.save();

      if (variantForUpdate != null) {
        await updateVariant();
      } else {
        await addVariant();
      }
    } finally {
      _isSubmitting = false; notifyListeners();
    }
  }

  Future<void> deleteVariant(Variant item) async {
    try {
      final Response res = await repository.deleteVariant(item.sId ?? '');
      if (res.isOk && (res.body?['success'] == true)) {
        SnackBarHelper.showSuccessSnackBar(res.body['message'] ?? 'Variant deleted successfully!');
        await _dataProvider.getAllVariants();
      } else {
        SnackBarHelper.showErrorSnackBar(
          res.body?['message'] ?? res.body?['error'] ?? res.statusText ?? 'Failed to delete variant',
        );
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  void setDataForUpdateVariant(Variant? variant) {
    if (variant != null) {
      variantForUpdate = variant;
      variantCtrl.text = variant.name ?? '';

      final vtId = variant.variantTypeId?.sId;
      if (vtId != null && _dataProvider.variantTypes.isNotEmpty) {
        selectedVariantType = _dataProvider.variantTypes.firstWhereOrNull((t) => t.sId == vtId);
      } else {
        selectedVariantType = null; // بعداً در فرم هیدراته می‌شود
      }
    } else {
      clearFields();
    }
  }

  void hydrateSelectedType(String? vtId) {
    if (vtId == null) return;
    if (selectedVariantType == null && _dataProvider.variantTypes.isNotEmpty) {
      selectedVariantType = _dataProvider.variantTypes.firstWhereOrNull((t) => t.sId == vtId);
      notifyListeners();
    }
  }

  void clearFields() {
    variantCtrl.clear();
    selectedVariantType = null;
    variantForUpdate = null;
  }

  void updateUI() => notifyListeners();
}
