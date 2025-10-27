import 'dart:convert';

import 'dart:io';

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
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

class DashBoardProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addProductFormKey = GlobalKey<FormState>();

  // --- Busy state (هم‌راستا با CategoryProvider)
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  //?text editing controllers in dashBoard screen
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
  String _msg(Map<String, dynamic>? m, String fallback) =>
      (m != null && m['message'] is String && (m['message'] as String).isNotEmpty)
          ? m!['message'] as String
          : fallback;

  // ---------- Submit (Create or Update) ----------
  // Future<bool> submitProduct() async {
  //   if (_isSubmitting) return false;
  //   _isSubmitting = true;
  //   notifyListeners();
  //
  //   try {
  //     // تبدیل variant names به variant IDs
  //     List<String> variantIds = [];
  //     if (selectedVariants.isNotEmpty) {
  //       variantIds = _dataProvider.variants
  //           .where((variant) => selectedVariants.contains(variant.name))
  //           .map((variant) => variant.sId ?? '')
  //           .where((id) => id.isNotEmpty)
  //           .toList();
  //     }
  //
  //     final Map<String, dynamic> formDataMap = {
  //       'name': productNameCtrl.text,
  //       'description': productDescCtrl.text,
  //       'quantity': int.tryParse(productQntCtrl.text) ?? 0,
  //       'price': double.tryParse(productPriceCtrl.text) ?? 0.0,
  //       'offer_price': productOffPriceCtrl.text.isEmpty
  //           ? (double.tryParse(productPriceCtrl.text) ?? 0.0)
  //           : (double.tryParse(productOffPriceCtrl.text) ?? 0.0),
  //       'category': selectedCategory?.sId ?? '',
  //       'subcategory': selectedSubCategory?.sId,
  //       'brand': selectedBrand?.sId,
  //       'variant_type': selectedVariantType?.sId,
  //       'variants': jsonEncode(variantIds), // سرورت این‌طوری می‌خواست
  //       'phone_number_code': '12345', // ✅ طبق قانونتان
  //     };
  //
  //     // ساخت FormData با تصاویر (PocketBase: کلید یکسان 'images')
  //     final FormData form = await createFormDataForMultipleImage(
  //       imgXFiles: [
  //         if (imgXFile1 != null) {'images': imgXFile1},
  //         if (imgXFile2 != null) {'images': imgXFile2},
  //         if (imgXFile3 != null) {'images': imgXFile3},
  //         if (imgXFile4 != null) {'images': imgXFile4},
  //         if (imgXFile5 != null) {'images': imgXFile5},
  //       ],
  //       formData: formDataMap,
  //     );
  //
  //     final String? targetId = productForUpdate?.sId;
  //     final bool isUpdate = (targetId != null && targetId.isNotEmpty);
  //
  //     final Response res = isUpdate
  //         ? await service.updateItem(
  //       endpointUrl: 'api/products',
  //       itemId: targetId!,
  //       itemData: form,
  //     )
  //         : await service.addItem(
  //       endpointUrl: 'api/products',
  //       itemData: form,
  //     );
  //
  //     final Map<String, dynamic>? body = _parseBody(res.body);
  //     final bool ok = _isOk(res) && _okFlag(body);
  //
  //     if (ok) {
  //       await _dataProvider.getAllProducts(showSnack: true);
  //       final msg = _msg(
  //         body,
  //         isUpdate ? 'Product updated successfully' : 'Product created successfully',
  //       );
  //       SnackBarHelper.showSuccessSnackBar(msg);
  //       clearFields();
  //       return true;
  //     } else {
  //       final err = body?['message'] ?? body?['error'] ?? 'Operation failed';
  //       SnackBarHelper.showErrorSnackBar(err.toString());
  //       return false;
  //     }
  //   } catch (e) {
  //     SnackBarHelper.showErrorSnackBar('An error occurred: $e');
  //     return false;
  //   } finally {
  //     _isSubmitting = false;
  //     notifyListeners();
  //   }
  // }
  Future<bool> submitProduct() async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    notifyListeners();

    try {
      // ✅ شماره را از SharedPreferences بگیر
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return false;
      }

      // تبدیل variant names به variant IDs
      List<String> variantIds = [];
      if (selectedVariants.isNotEmpty) {
        variantIds = _dataProvider.variants
            .where((variant) => selectedVariants.contains(variant.name))
            .map((variant) => variant.sId ?? '')
            .where((id) => id.isNotEmpty)
            .toList();
      }

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
        // ⬅️ به‌جای مقدار ثابت
        'phone_number_code': phone,
      };

      // ساخت FormData با تصاویر
      final FormData form = await createFormDataForMultipleImage(
        imgXFiles: [
          if (imgXFile1 != null) {'images': imgXFile1},
          if (imgXFile2 != null) {'images': imgXFile2},
          if (imgXFile3 != null) {'images': imgXFile3},
          if (imgXFile4 != null) {'images': imgXFile4},
          if (imgXFile5 != null) {'images': imgXFile5},
        ],
        formData: formDataMap,
      );

      final String? targetId = productForUpdate?.sId;
      final bool isUpdate = (targetId != null && targetId.isNotEmpty);

      final Response res = isUpdate
          ? await service.updateItem(
        endpointUrl: 'api/products',
        itemId: targetId!,
        itemData: form,
      )
          : await service.addItem(
        endpointUrl: 'api/products',
        itemData: form,
      );

      final Map<String, dynamic>? body = _parseBody(res.body);
      final bool ok = _isOk(res) && _okFlag(body);

      if (ok) {
        await _dataProvider.getAllProducts(showSnack: true);
        final msg = _msg(
          body,
          isUpdate ? 'Product updated successfully' : 'Product created successfully',
        );
        SnackBarHelper.showSuccessSnackBar(msg);
        clearFields();
        return true;
      } else {
        final err = body?['message'] ?? body?['error'] ?? 'Operation failed';
        SnackBarHelper.showErrorSnackBar(err.toString());
        return false;
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }


  // ---------- Delete ----------
  deleteProduct(Product product) async {
    try {
      Response response = await service.deleteItem(
        endpointUrl: 'api/products',
        itemId: product.sId ?? '',
      );

      if (response.isOk) {
        final body = _parseBody(response.body);
        if (_okFlag(body)) {
          SnackBarHelper.showSuccessSnackBar(_msg(body, 'محصول با موفقیت حذف شد!'));
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

  // ---------- Image Picking ----------
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
      notifyListeners();
    }
  }

  Future<FormData> createFormDataForMultipleImage({
    required List<Map<String, XFile?>>? imgXFiles,
    required Map<String, dynamic> formData,
  }) async {
    final FormData form = FormData(formData);

    if (imgXFiles != null) {
      for (int i = 0; i < imgXFiles.length; i++) {
        XFile? imgXFile = imgXFiles[i]['images'];
        if (imgXFile != null) {
          if (kIsWeb) {
            String fileName = imgXFile.name;
            Uint8List byteImg = await imgXFile.readAsBytes();
            form.files.add(MapEntry('images', MultipartFile(byteImg, filename: fileName)));
          } else {
            String filePath = imgXFile.path;
            String fileName = filePath.split('/').last;
            form.files.add(MapEntry('images', await MultipartFile(filePath, filename: fileName)));
          }
        }
      }
    }
    return form;
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
            .where((subCategory) => subCategory.categoryId?.sId == selectedCategory?.sId)
            .toList();
      }

      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull(
            (element) => element.sId == product.proSubCategoryId?.sId,
      );

      if (selectedSubCategory != null) {
        brandsBySubCategory = _dataProvider.brands
            .where((brand) => brand.subCategoryId?.sId == selectedSubCategory?.sId)
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
            .where((variant) => variant.variantTypeId?.sId == selectedVariantType?.sId)
            .toList()
            .map((variant) => variant.name ?? '')
            .toList();
      }

      // نمایش نام ویژگی‌ها
      selectedVariants = _dataProvider.variants
          .where((variant) => product.proVariantId?.contains(variant.sId) ?? false)
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
  }

  clearFields() {
    _clearFieldsWithoutNotify();
    notifyListeners();
  }

  updateUI() {
    notifyListeners();
  }
}
