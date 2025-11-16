
import 'package:admin/utility/User_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_connect/http/src/response/response.dart';

import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';

import '../../../models/variant_type.dart';
import '../../../core/data/repositories/category_repository.dart';
import '../../../utility/snack_bar_helper.dart';



import 'package:flutter/material.dart';

class VariantsTypeProvider extends ChangeNotifier {
  final VariantTypeRepository repository = VariantTypeRepository();
  final DataProvider _dataProvider;

  VariantsTypeProvider(this._dataProvider);

  // Form state
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController typeCtrl = TextEditingController();

  VariantType? forUpdate;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;


  bool _ok(Response res) => res.isOk && (res.body?['success'] == true);


  Future<bool> addVariantType() async {
    try {
      // شماره از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return false;
      }

      final Map<String, dynamic> body = {
        'name': nameCtrl.text.trim(),
        'type': typeCtrl.text.trim(),
        'phone_number_code': phone, // ⬅️ به‌جای مقدار ثابت
      };

      final Response res = await repository.addVariantType(body);

      if (res.isOk && (res.body?['success'] == true)) {
        SnackBarHelper.showSuccessSnackBar(res.body['message'] ?? 'Created');
        clearFields();
        await _dataProvider.getAllVariantTypes();
        return true;
      }
      SnackBarHelper.showErrorSnackBar(
        res.body?['message'] ?? res.body?['error'] ?? res.statusText ?? 'Failed',
      );
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

      // شماره از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return false;
      }

      final Map<String, dynamic> body = {
        'name': nameCtrl.text.trim(),
        'phone_number_code': phone, // ⬅️ به‌جای مقدار ثابت
      };
      // فقط اگر type پر شده باشد ارسال کن
      final t = typeCtrl.text.trim();
      if (t.isNotEmpty) body['type'] = t;

      final Response res = await repository.updateVariantType(id, body);

      if (res.isOk && (res.body?['success'] == true)) {
        SnackBarHelper.showSuccessSnackBar(res.body['message'] ?? 'Updated');
        clearFields();
        await _dataProvider.getAllVariantTypes();
        return true;
      }
      SnackBarHelper.showErrorSnackBar(
        res.body?['message'] ?? res.body?['error'] ?? res.statusText ?? 'Failed',
      );
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Error: $e');
      return false;
    }
  }

  Future<bool> deleteVariantType(VariantType item) async {
    try {
      final Response res = await repository.deleteVariantType(item.sId ?? '');
      if (_ok(res)) {
        SnackBarHelper.showSuccessSnackBar(res.body['message'] ?? 'Deleted');
        await _dataProvider.getAllVariantTypes();
        return true;
      }
      SnackBarHelper.showErrorSnackBar(
        res.body?['message'] ?? res.body?['error'] ?? res.statusText ?? 'Failed',
      );
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Error: $e');
      return false;
    }
  }

  Future<bool> submit() async {
    if (_isSubmitting) return false;
    _isSubmitting = true; notifyListeners();
    try {
      final form = formKey.currentState;
      if (form == null || !form.validate()) return false;
      form.save();
      return (forUpdate != null) ? await updateVariantType() : await addVariantType();
    } finally {
      _isSubmitting = false; notifyListeners();
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
    // notify در پایان submit/close هم صدا می‌خورد
  }
}
