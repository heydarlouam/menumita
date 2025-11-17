import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

import 'package:admin/utility/User_helper.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/data/data_provider.dart';

import '../../../models/brand.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../models/sub_category.dart';
import '../../../models/variant_type.dart';
import '../../../core/data/repositories/category_repository.dart';
import '../../../utility/snack_bar_helper.dart';

class DashBoardProvider extends ChangeNotifier {
  final ProductRepository repository = ProductRepository();
  final DataProvider _dataProvider;
  final addProductFormKey = GlobalKey<FormState>();
  final Set<int> removedImageSlots = {};

  // --- Busy state (هم‌راستا با CategoryProvider)
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productDescCtrl = TextEditingController();
  TextEditingController productQntCtrl = TextEditingController();
  TextEditingController productPriceCtrl = TextEditingController();
  TextEditingController productOffPriceCtrl = TextEditingController();

  //? dropdown value
  Category? selectedCategory;
  SubCategory? selectedSubCategory;
  Brand? selectedBrand;
  VariantType? selectedVariantType;
  List<String> selectedVariants = [];

  Product? productForUpdate;
  File? selectedMainImage,
      selectedSecondImage,
      selectedThirdImage,
      selectedFourthImage,
      selectedFifthImage;
  XFile? imgXFile1, imgXFile2, imgXFile3, imgXFile4, imgXFile5;

  //? to filter the data depending on the selected dropdown value
  List<SubCategory> subCategoriesByCategory = [];
  List<Brand> brandsBySubCategory = [];
  List<String> variantsByVariantType = [];

  DashBoardProvider(this._dataProvider);

  // ---------- Helpers (هم‌الگو با CategoryProvider) ----------
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
  String _msg(Map<String, dynamic>? m, String fallback) {
    if (m != null && m['message'] is String) {
      final msg = (m['message'] as String).trim();
      if (msg.isNotEmpty) return msg;
    }
    return fallback;
  }

  void _logProgress(String step, [Object? detail]) {
    if (!kDebugMode) return;
    final msg = detail == null ? step : '$step | $detail';
    debugPrint('🟦 ProductSubmit → $msg');
  }

  Future<bool> submitProduct() async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    notifyListeners();

    try {
      _logProgress('started');
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        _logProgress('failed', 'phone number missing');
        return false;
      }
      _logProgress('phone loaded', phone);

      // variant names -> ids
      List<String> variantIds = [];
      if (selectedVariants.isNotEmpty) {
        variantIds = _dataProvider.variants
            .where((v) => selectedVariants.contains(v.name))
            .map((v) => v.sId ?? '')
            .where((id) => id.isNotEmpty)
            .toList();
      }

      // ✅ آرایه‌های موازی فایل‌ها و اسلات‌ها
      final List<Map<String, XFile?>> imageEntries = [];
      final List<int> imageSlots = [];

      if (imgXFile1 != null) {
        imageEntries.add({'images': imgXFile1});
        imageSlots.add(1);
      }
      if (imgXFile2 != null) {
        imageEntries.add({'images': imgXFile2});
        imageSlots.add(2);
      }
      if (imgXFile3 != null) {
        imageEntries.add({'images': imgXFile3});
        imageSlots.add(3);
      }
      if (imgXFile4 != null) {
        imageEntries.add({'images': imgXFile4});
        imageSlots.add(4);
      }
      if (imgXFile5 != null) {
        imageEntries.add({'images': imgXFile5});
        imageSlots.add(5);
      }
      _logProgress(
          'images prepared', 'count=${imageEntries.length}, slots=$imageSlots');

      final Map<String, dynamic> formDataMap = {
        'name': productNameCtrl.text,
        'description': productDescCtrl.text,
        'quantity': int.tryParse(productQntCtrl.text) ?? 0,
        'price': double.tryParse(productPriceCtrl.text) ?? 0.0,
        'offer_price': productOffPriceCtrl.text.isEmpty
            ? (double.tryParse(productPriceCtrl.text) ?? 0.0)
            : (double.tryParse(productOffPriceCtrl.text) ?? 0.0),
        'category': selectedCategory?.sId ?? '',
        'subcategory': selectedSubCategory?.sId,
        'brand': selectedBrand?.sId,
        'variant_type': selectedVariantType?.sId,
        'variants': jsonEncode(variantIds),
        'phone_number_code': phone,

        // ✅ اسلات‌های حذف‌شده (برای PUT اهمیت دارد)
        'remove_image_indexes': jsonEncode(removedImageSlots.toList()),
      };

      // ✅ ساخت FormData با فایل‌ها + الصاق image_slots
      _logProgress('building form data');
      final FormData form = await createFormDataForMultipleImage(
        imgXFiles: imageEntries,
        formData: formDataMap,
        imageSlots: imageSlots, // ← جدید
      );
      _logProgress('form data ready',
          'fields=${form.fields.length}, files=${form.files.length}');

      final String? targetId = productForUpdate?.sId;
      if (productForUpdate != null && (targetId == null || targetId.isEmpty)) {
        SnackBarHelper.showErrorSnackBar(
            'شناسه محصول برای بروزرسانی نامعتبر است');
        _logProgress('abort', 'empty product id while editing');
        return false;
      }

      late final Response res;
      late final bool isUpdate;
      if (targetId != null && targetId.isNotEmpty) {
        isUpdate = true;
        _logProgress('updating product', targetId);
        res = await repository.updateProduct(targetId, form);
      } else {
        isUpdate = false;
        _logProgress('creating product', 'new');
        res = await repository.addProduct(form);
      }
      _logProgress('response received', 'status=${res.statusCode}');

      final Map<String, dynamic>? body = _parseBody(res.body);
      final bool ok = _isOk(res) && _okFlag(body);

      if (ok) {
        _logProgress('success', body?['message'] ?? 'ok');
        await _dataProvider.getAllProducts(showSnack: true);
        final msg = _msg(
          body,
          isUpdate
              ? 'Product updated successfully'
              : 'Product created successfully',
        );
        SnackBarHelper.showSuccessSnackBar(msg);
        clearFields();
        return true;
      } else {
        final err = body?['message'] ?? body?['error'] ?? 'Operation failed';
        SnackBarHelper.showErrorSnackBar(err.toString());
        _logProgress('server error', err);
        return false;
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      _logProgress('exception', e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
      _logProgress('finished');
    }
  }

  // ---------- Delete ----------
  deleteProduct(Product product) async {
    try {
      Response response = await repository.deleteProduct(
        product.sId ?? '',
      );

      if (response.isOk) {
        final body = _parseBody(response.body);
        if (_okFlag(body)) {
          SnackBarHelper.showSuccessSnackBar(
              _msg(body, 'محصول با موفقیت حذف شد!'));
          await _dataProvider.getAllProducts(showSnack: true);
        } else {
          SnackBarHelper.showErrorSnackBar(
              'خطا در حذف محصول: ${body?['error'] ?? 'Unknown error'}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'خطا: ${response.body?['error'] ?? response.statusText}');
      }
    } catch (e) {
      print('❌ Error deleting product: $e');
      SnackBarHelper.showErrorSnackBar('خطا در حذف محصول: $e');
      rethrow;
    }
  }

  void pickImage({required int imageCardNumber}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (imageCardNumber == 1) {
        selectedMainImage = File(image.path);
        imgXFile1 = image;
      } else if (imageCardNumber == 2) {
        selectedSecondImage = File(image.path);
        imgXFile2 = image;
      } else if (imageCardNumber == 3) {
        selectedThirdImage = File(image.path);
        imgXFile3 = image;
      } else if (imageCardNumber == 4) {
        selectedFourthImage = File(image.path);
        imgXFile4 = image;
      } else if (imageCardNumber == 5) {
        selectedFifthImage = File(image.path);
        imgXFile5 = image;
      }

      // ✅ اگر قبلاً برای این اسلات حذف ثبت شده بود، چون الان جایگزین می‌کنیم، حذف را لغو کن
      removedImageSlots.remove(imageCardNumber);

      notifyListeners();
    }
  }

  Future<FormData> createFormDataForMultipleImage({
    required List<Map<String, XFile?>>? imgXFiles,
    required Map<String, dynamic> formData,
    List<int>? imageSlots, // ← جدید
  }) async {
    final FormData form = FormData(formData);

    if (imgXFiles != null && imgXFiles.isNotEmpty) {
      for (int i = 0; i < imgXFiles.length; i++) {
        final XFile? imgXFile = imgXFiles[i]['images'];
        if (imgXFile != null) {
          _logProgress('attach image',
              'slot=${imageSlots != null && i < imageSlots.length ? imageSlots[i] : '?'} name=${imgXFile.name}');
          if (kIsWeb) {
            final String fileName = imgXFile.name;
            final Uint8List byteImg = await imgXFile.readAsBytes();
            form.files.add(
                MapEntry('images', MultipartFile(byteImg, filename: fileName)));
          } else {
            final String filePath = imgXFile.path;
            final String fileName = filePath.split('/').last;
            form.files.add(MapEntry(
                'images', await MultipartFile(filePath, filename: fileName)));
          }

          // ✅ الصاق شماره اسلات متناظر با همین فایل
          if (imageSlots != null && i < imageSlots.length) {
            form.fields.add(MapEntry('image_slots', imageSlots[i].toString()));
          }
        }
      }
    }

    return form;
  }

  void markImageRemoved(int slot) {
    switch (slot) {
      case 1:
        selectedMainImage = null;
        imgXFile1 = null;
        break;
      case 2:
        selectedSecondImage = null;
        imgXFile2 = null;
        break;
      case 3:
        selectedThirdImage = null;
        imgXFile3 = null;
        break;
      case 4:
        selectedFourthImage = null;
        imgXFile4 = null;
        break;
      case 5:
        selectedFifthImage = null;
        imgXFile5 = null;
        break;
      default:
        return;
    }
    // ✅ این اسلات باید سمت سرور حذف شود
    removedImageSlots.add(slot);
    notifyListeners();
  }

  // ---------- Filters ----------
  filterSubcategory(Category category) {
    selectedSubCategory = null;
    selectedBrand = null;
    selectedCategory = category;
    subCategoriesByCategory.clear();

    subCategoriesByCategory = _dataProvider.subCategories
        .where((subCategory) => subCategory.categoryId?.sId == category.sId)
        .toList();
    notifyListeners();
  }

  filterBrand(SubCategory subCategory) {
    selectedBrand = null;
    selectedSubCategory = subCategory;
    brandsBySubCategory.clear();

    brandsBySubCategory = _dataProvider.brands
        .where((brand) => brand.subCategoryId?.sId == subCategory.sId)
        .toList();
    notifyListeners();
  }

  filterVariant(VariantType variantType) {
    selectedVariants = [];
    selectedVariantType = variantType;

    variantsByVariantType = _dataProvider.variants
        .where((variant) => variant.variantTypeId?.sId == variantType.sId)
        .toList()
        .map((variant) => variant.name ?? '')
        .toList();
    notifyListeners();
  }

  // ---------- Editing context ----------
  setDataForUpdateProduct(Product? product) {
    if (product != null) {
      productForUpdate = product;

      productNameCtrl.text = product.name ?? '';
      productDescCtrl.text = product.description ?? '';
      productPriceCtrl.text = product.price?.toString() ?? '';
      productOffPriceCtrl.text = product.offerPrice?.toString() ?? '';
      productQntCtrl.text = product.quantity?.toString() ?? '';

      selectedCategory = _dataProvider.categories.firstWhereOrNull(
        (element) => element.sId == product.proCategoryId?.sId,
      );

      if (selectedCategory != null) {
        subCategoriesByCategory = _dataProvider.subCategories
            .where((subCategory) =>
                subCategory.categoryId?.sId == selectedCategory?.sId)
            .toList();
      }

      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull(
        (element) => element.sId == product.proSubCategoryId?.sId,
      );

      if (selectedSubCategory != null) {
        brandsBySubCategory = _dataProvider.brands
            .where(
                (brand) => brand.subCategoryId?.sId == selectedSubCategory?.sId)
            .toList();
      }

      selectedBrand = _dataProvider.brands.firstWhereOrNull(
        (element) => element.sId == product.proBrandId?.sId,
      );

      selectedVariantType = _dataProvider.variantTypes.firstWhereOrNull(
        (element) => element.sId == product.proVariantTypeId?.sId,
      );

      if (selectedVariantType != null) {
        variantsByVariantType = _dataProvider.variants
            .where((variant) =>
                variant.variantTypeId?.sId == selectedVariantType?.sId)
            .toList()
            .map((variant) => variant.name ?? '')
            .toList();
      }

      // نمایش نام ویژگی‌ها
      selectedVariants = _dataProvider.variants
          .where(
              (variant) => product.proVariantId?.contains(variant.sId) ?? false)
          .map((variant) => variant.name ?? '')
          .toList();
    } else {
      _clearFieldsWithoutNotify();
    }
    // عمداً notify نمی‌زنیم
  }

  // ---------- Clear ----------
  void _clearFieldsWithoutNotify() {
    productNameCtrl.clear();
    productDescCtrl.clear();
    productPriceCtrl.clear();
    productOffPriceCtrl.clear();
    productQntCtrl.clear();

    selectedMainImage = null;
    selectedSecondImage = null;
    selectedThirdImage = null;
    selectedFourthImage = null;
    selectedFifthImage = null;

    imgXFile1 = null;
    imgXFile2 = null;
    imgXFile3 = null;
    imgXFile4 = null;
    imgXFile5 = null;

    selectedCategory = null;
    selectedSubCategory = null;
    selectedBrand = null;
    selectedVariantType = null;
    selectedVariants = [];

    productForUpdate = null;

    subCategoriesByCategory = [];
    brandsBySubCategory = [];
    variantsByVariantType = [];
    removedImageSlots.clear();
  }

  clearFields() {
    _clearFieldsWithoutNotify();
    notifyListeners();
  }

  updateUI() {
    notifyListeners();
  }
}
