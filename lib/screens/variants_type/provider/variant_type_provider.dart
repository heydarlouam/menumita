
import 'package:admin/utility/User_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_connect/http/src/response/response.dart';

import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';

import '../../../models/variant_type.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';


// class VariantsTypeProvider extends ChangeNotifier {
//   HttpService service = HttpService();
//   final DataProvider _dataProvider;
//
//   final addVariantsTypeFormKey = GlobalKey<FormState>();
//   TextEditingController variantNameCtrl = TextEditingController();
//   TextEditingController variantTypeCtrl = TextEditingController();
//
//   VariantType? variantTypeForUpdate;
//
//   VariantsTypeProvider(this._dataProvider);
//
//   addVariantType() async {
//     try {
//       Map<String, dynamic> variantType = {
//         'name': variantNameCtrl.text.trim(),
//         'type': variantTypeCtrl.text.trim()
//       };
//
//       final response = await service.addItem(
//           endpointUrl: 'api/variant-types',
//           itemData: variantType
//       );
//
//       if (response.isOk) {
//         if (response.body['success'] == true) {
//           clearFields();
//           SnackBarHelper.showSuccessSnackBar(response.body['message'] ?? 'Variant type added successfully');
//           print('✅ Variant type added');
//
//           _dataProvider.getAllVariantTypes();
//         } else {
//           SnackBarHelper.showErrorSnackBar(
//               'Failed to add variant type: ${response.body['error']}');
//         }
//       } else {
//         SnackBarHelper.showErrorSnackBar(
//             'Error: ${response.body?['error'] ?? response.statusText}');
//       }
//     } catch (e) {
//       print(e);
//       SnackBarHelper.showErrorSnackBar('An error occurred: $e');
//       rethrow;
//     }
//   }
//
//   updateVariantType() async {
//     try {
//       Map<String, dynamic> variantType = {
//         'name': variantNameCtrl.text.trim(),
//         'type': variantTypeCtrl.text.trim()
//       };
//
//       final response = await service.updateItem(
//           endpointUrl: 'api/variant-types',
//           itemId: variantTypeForUpdate?.sId ?? '',
//           itemData: variantType);
//
//       if (response.isOk) {
//         if (response.body['success'] == true) {
//           clearFields();
//           SnackBarHelper.showSuccessSnackBar(response.body['message'] ?? 'Variant type updated successfully');
//           print('✅ Variant type updated');
//
//           _dataProvider.getAllVariantTypes();
//         } else {
//           SnackBarHelper.showErrorSnackBar(
//               'Failed to update variant type: ${response.body['error']}');
//         }
//       } else {
//         SnackBarHelper.showErrorSnackBar(
//             'Error: ${response.body?['error'] ?? response.statusText}');
//       }
//     } catch (e) {
//       print(e);
//       SnackBarHelper.showErrorSnackBar('An error occurred: $e');
//       rethrow;
//     }
//   }
//
//   submitVariantType() async =>
//       variantTypeForUpdate != null ? updateVariantType() : addVariantType();
//
//   deleteVariantType(VariantType variantType) async {
//     try {
//       Response response = await service.deleteItem(
//           endpointUrl: 'api/variant-types',
//           itemId: variantType.sId ?? '');
//
//       if (response.isOk) {
//         if (response.body['success'] == true) {
//           SnackBarHelper.showSuccessSnackBar(
//               response.body['message'] ?? 'Variant type deleted successfully!');
//           _dataProvider.getAllVariantTypes();
//         } else {
//           SnackBarHelper.showErrorSnackBar(
//               'Failed to delete: ${response.body['error']}');
//         }
//       } else {
//         SnackBarHelper.showErrorSnackBar(
//             'Error: ${response.body?['error'] ?? response.statusText}');
//       }
//     } catch (e) {
//       print(e);
//       SnackBarHelper.showErrorSnackBar('An error occurred: $e');
//       rethrow;
//     }
//   }
//
//   setDataForUpdateVariantTYpe(VariantType? variantType) {
//     if (variantType != null) {
//       variantTypeForUpdate = variantType;
//       variantNameCtrl.text = variantType.name ?? '';
//       variantTypeCtrl.text = variantType.type ?? '';
//     } else {
//       clearFields();
//     }
//   }
//
//   clearFields() {
//     variantNameCtrl.clear();
//     variantTypeCtrl.clear();
//     variantTypeForUpdate = null;
//   }
// }


// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import '../../../core/data/data_provider.dart';
// import '../../../models/variant_type.dart';
// import '../../../services/http_services.dart';
// import '../../../utility/snack_bar_helper.dart';
//
// class VariantsTypeProvider extends ChangeNotifier {
//   VariantsTypeProvider(this._dataProvider);
//
//   final HttpService service = HttpService();
//   final DataProvider _dataProvider;
//
//   final formKey = GlobalKey<FormState>();
//   final TextEditingController variantNameCtrl = TextEditingController();
//   final TextEditingController variantTypeCtrl = TextEditingController();
//
//   VariantType? variantTypeForUpdate;
//
//   bool _isSubmitting = false;
//   bool get isSubmitting => _isSubmitting;
//
//   // --- helpers
//   Map<String, dynamic> _buildBody() => {
//     'name': variantNameCtrl.text,
//     'type': variantTypeCtrl.text,
//     // طبق قانون ثابت کاربر:
//     'phone_number_code': '12345',
//   };
//
//   bool _ok(Response res, Map body) =>
//       res.isOk && (body['success'] == true || body['ok'] == true);
//
//   // --- CRUD
//   Future<bool> addVariantType() async {
//     try {
//       final res = await service.addItem(
//         endpointUrl: 'api/variant-types',
//         itemData: _buildBody(),
//       );
//       final body = res.body is Map ? res.body as Map : {};
//       if (_ok(res, body)) {
//         SnackBarHelper.showSuccessSnackBar(body['message'] ?? 'Created');
//         clearFields();
//         await _dataProvider.getAllVariantTypes();
//         return true;
//       }
//       SnackBarHelper.showErrorSnackBar(body['message'] ?? body['error'] ?? 'Failed');
//       return false;
//     } catch (e) {
//       SnackBarHelper.showErrorSnackBar('Error: $e');
//       return false;
//     }
//   }
//
//   Future<bool> updateVariantType() async {
//     try {
//       final id = variantTypeForUpdate?.sId ?? '';
//       if (id.isEmpty) {
//         SnackBarHelper.showErrorSnackBar('ID missing');
//         return false;
//       }
//       final res = await service.updateItem(
//         endpointUrl: 'api/variant-types',
//         itemId: id,
//         itemData: _buildBody(),
//       );
//       final body = res.body is Map ? res.body as Map : {};
//       if (_ok(res, body)) {
//         SnackBarHelper.showSuccessSnackBar(body['message'] ?? 'Updated');
//         clearFields();
//         await _dataProvider.getAllVariantTypes();
//         return true;
//       }
//       SnackBarHelper.showErrorSnackBar(body['message'] ?? body['error'] ?? 'Failed');
//       return false;
//     } catch (e) {
//       SnackBarHelper.showErrorSnackBar('Error: $e');
//       return false;
//     }
//   }
//
//   Future<bool> deleteVariantType(VariantType item) async {
//     try {
//       final res = await service.deleteItem(
//         endpointUrl: 'api/variant-types',
//         itemId: item.sId ?? '',
//       );
//       final body = res.body is Map ? res.body as Map : {};
//       if (_ok(res, body)) {
//         SnackBarHelper.showSuccessSnackBar(body['message'] ?? 'Deleted');
//         await _dataProvider.getAllVariantTypes();
//         return true;
//       }
//       SnackBarHelper.showErrorSnackBar(body['message'] ?? body['error'] ?? 'Failed');
//       return false;
//     } catch (e) {
//       SnackBarHelper.showErrorSnackBar('Error: $e');
//       return false;
//     }
//   }
//
//   Future<bool> submit() async {
//     if (_isSubmitting) return false;
//     _isSubmitting = true;
//     notifyListeners();
//     try {
//       final form = formKey.currentState;
//       if (form == null || !form.validate()) return false;
//       form.save();
//       return variantTypeForUpdate != null ? await updateVariantType() : await addVariantType();
//     } finally {
//       _isSubmitting = false;
//       notifyListeners();
//     }
//   }
//
//   void setDataForUpdateVariantType(VariantType? item) {
//     if (item != null) {
//       variantTypeForUpdate = item;
//       variantNameCtrl.text = item.name ?? '';
//       variantTypeCtrl.text = item.type ?? '';
//     } else {
//       clearFields();
//     }
//     notifyListeners();
//   }
//
//   void clearFields() {
//     variantTypeForUpdate = null;
//     variantNameCtrl.clear();
//     variantTypeCtrl.clear();
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/variant_type.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

class VariantsTypeProvider extends ChangeNotifier {
  final HttpService service = HttpService();
  final DataProvider _dataProvider;

  VariantsTypeProvider(this._dataProvider);

  // Form state
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController typeCtrl = TextEditingController();

  VariantType? forUpdate;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // ---------------- Helpers
  // Map<String, dynamic> _createBody() => {
  //   'name': nameCtrl.text.trim(),
  //   'type': typeCtrl.text.trim(),
  //   'phone_number_code': '12345', // قانون ثابت
  // };
  //
  // Map<String, dynamic> _updateBody() {
  //   final body = <String, dynamic>{
  //     'name': nameCtrl.text.trim(),
  //     'phone_number_code': '12345',
  //   };
  //   // فقط اگر type را پر/تغییر داده‌ایم ارسال کنیم
  //   if (typeCtrl.text.trim().isNotEmpty) {
  //     body['type'] = typeCtrl.text.trim();
  //   }
  //   return body;
  // }

  bool _ok(Response res) => res.isOk && (res.body?['success'] == true);

  // ---------------- CRUD
  // Future<bool> addVariantType() async {
  //   try {
  //     final Response res = await service.addItem(
  //       endpointUrl: 'api/variant-types',
  //       itemData: _createBody(),
  //     );
  //     if (_ok(res)) {
  //       SnackBarHelper.showSuccessSnackBar(res.body['message'] ?? 'Created');
  //       clearFields();
  //       await _dataProvider.getAllVariantTypes();
  //       return true;
  //     }
  //     SnackBarHelper.showErrorSnackBar(
  //       res.body?['message'] ?? res.body?['error'] ?? res.statusText ?? 'Failed',
  //     );
  //     return false;
  //   } catch (e) {
  //     SnackBarHelper.showErrorSnackBar('Error: $e');
  //     return false;
  //   }
  // }
  //
  // Future<bool> updateVariantType() async {
  //   try {
  //     final id = forUpdate?.sId ?? '';
  //     if (id.isEmpty) {
  //       SnackBarHelper.showErrorSnackBar('ID missing');
  //       return false;
  //     }
  //     final Response res = await service.updateItem(
  //       endpointUrl: 'api/variant-types',
  //       itemId: id,
  //       itemData: _updateBody(),
  //     );
  //     if (_ok(res)) {
  //       SnackBarHelper.showSuccessSnackBar(res.body['message'] ?? 'Updated');
  //       clearFields();
  //       await _dataProvider.getAllVariantTypes();
  //       return true;
  //     }
  //     SnackBarHelper.showErrorSnackBar(
  //       res.body?['message'] ?? res.body?['error'] ?? res.statusText ?? 'Failed',
  //     );
  //     return false;
  //   } catch (e) {
  //     SnackBarHelper.showErrorSnackBar('Error: $e');
  //     return false;
  //   }
  // }
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

      final Response res = await service.addItem(
        endpointUrl: 'api/variant-types',
        itemData: body,
      );

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

      final Response res = await service.updateItem(
        endpointUrl: 'api/variant-types',
        itemId: id,
        itemData: body,
      );

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
      final Response res = await service.deleteItem(
        endpointUrl: 'api/variant-types',
        itemId: item.sId ?? '',
      );
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
