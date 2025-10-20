import 'dart:convert';

import 'dart:io';

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


  // addProduct() async {
  //   try {
  //     Map<String, dynamic> formDataMap = {
  //       'name': productNameCtrl.text,
  //       'description': productDescCtrl.text,
  //       'quantity': int.parse(productQntCtrl.text), // تبدیل به int
  //       'price': double.parse(productPriceCtrl.text), // تبدیل به double
  //       'offer_price': productOffPriceCtrl.text.isEmpty
  //           ? double.parse(productPriceCtrl.text)
  //           : double.parse(productOffPriceCtrl.text),
  //       'category': selectedCategory?.sId ?? '',
  //       'subcategory': selectedSubCategory?.sId,
  //       'brand': selectedBrand?.sId,
  //       'variant_type': selectedVariantType?.sId,
  //       'variants': selectedVariants, // ❗ بدون jsonEncode
  //     };
  //
  //     // لاگ برای دیباگ
  //     print('📤 Sending form data: $formDataMap');
  //
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
  //     final response = await service.addItem(
  //         endpointUrl: 'api/products', // ❗ با 'api/'
  //         itemData: form
  //     );
  //
  //     if (response.isOk) {
  //       final responseBody = response.body;
  //       print('✅ Response: $responseBody');
  //
  //       if (responseBody['success'] == true) {
  //         clearFields();
  //         SnackBarHelper.showSuccessSnackBar('محصول با موفقیت اضافه شد');
  //         _dataProvider.getAllProducts();
  //       } else {
  //         SnackBarHelper.showErrorSnackBar(
  //             'خطا در افزودن محصول: ${responseBody['error']}');
  //       }
  //     } else {
  //       print('❌ HTTP Error: ${response.statusCode} - ${response.body}');
  //       SnackBarHelper.showErrorSnackBar(
  //           'خطای شبکه: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('❌ Error adding product: $e');
  //     SnackBarHelper.showErrorSnackBar('خطا در افزودن محصول: $e');
  //   }
  // }


  // addProduct() async {
  //   try {
  //     Map<String, dynamic> formDataMap = {
  //       'name': productNameCtrl.text,
  //       'description': productDescCtrl.text,
  //       'quantity': productQntCtrl.text,
  //       'price': productPriceCtrl.text,
  //       'offer_price': productOffPriceCtrl.text.isEmpty
  //           ? productPriceCtrl.text
  //           : productOffPriceCtrl.text,
  //       'category': selectedCategory?.sId ?? '',
  //       'subcategory': selectedSubCategory?.sId,
  //       'brand': selectedBrand?.sId,
  //       'variant_type': selectedVariantType?.sId,
  //       'variants': jsonEncode(selectedVariants), // آرایه به JSON string
  //     };
  //
  //     final FormData form = await createFormDataForMultipleImage(
  //       imgXFiles: [
  //         {'images': imgXFile1},
  //         {'images': imgXFile2},
  //         {'images': imgXFile3},
  //         {'images': imgXFile4},
  //         {'images': imgXFile5},
  //       ],
  //       formData: formDataMap,
  //     );
  //
  //     final response = await service.addItem(endpointUrl: 'products', itemData: form);
  //
  //     if (response.isOk) {
  //       final responseBody = response.body;
  //
  //       if (responseBody['success'] == true) {
  //         clearFields();
  //         SnackBarHelper.showSuccessSnackBar('Product added successfully');
  //         log('product added');
  //         _dataProvider.getAllProducts();
  //       } else {
  //         SnackBarHelper.showErrorSnackBar(
  //             'Failed to add product: ${responseBody['error']}');
  //       }
  //     } else {
  //       SnackBarHelper.showErrorSnackBar(
  //           'Error: ${response.body?['error'] ?? response.statusText}');
  //     }
  //   } catch (e) {
  //     print('Error adding product: $e');
  //     SnackBarHelper.showErrorSnackBar('An error occurred: $e');
  //     rethrow;
  //   }
  // }


  // addProduct() async {
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
  //     Map<String, dynamic> formDataMap = {
  //       'name': productNameCtrl.text,
  //       'description': productDescCtrl.text,
  //       'quantity': int.parse(productQntCtrl.text),
  //       'price': double.parse(productPriceCtrl.text),
  //       'offer_price': productOffPriceCtrl.text.isEmpty
  //           ? double.parse(productPriceCtrl.text)
  //           : double.parse(productOffPriceCtrl.text),
  //       'category': selectedCategory?.sId ?? '',
  //       'subcategory': selectedSubCategory?.sId,
  //       'brand': selectedBrand?.sId,
  //       'variant_type': selectedVariantType?.sId,
  //       'variants': variantIds, // ❗ ارسال IDها نه نام‌ها
  //     };
  //
  //     print('📤 Sending form data: $formDataMap');
  //
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
  //     final response = await service.addItem(
  //         endpointUrl: 'api/products',
  //         itemData: form
  //     );
  //
  //     if (response.isOk) {
  //       final responseBody = response.body;
  //       print('✅ Response: $responseBody');
  //
  //       if (responseBody['success'] == true) {
  //         clearFields();
  //         SnackBarHelper.showSuccessSnackBar('محصول با موفقیت اضافه شد');
  //         _dataProvider.getAllProducts();
  //       } else {
  //         SnackBarHelper.showErrorSnackBar(
  //             'خطا در افزودن محصول: ${responseBody['error']}');
  //       }
  //     } else {
  //       print('❌ HTTP Error: ${response.statusCode} - ${response.body}');
  //       SnackBarHelper.showErrorSnackBar('خطای شبکه: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('❌ Error adding product: $e');
  //     SnackBarHelper.showErrorSnackBar('خطا در افزودن محصول: $e');
  //   }
  // }
  // updateProduct() async {
  //   try {
  //     Map<String, dynamic> formDataMap = {
  //       'name': productNameCtrl.text,
  //       'description': productDescCtrl.text,
  //       'quantity': productQntCtrl.text,
  //       'price': productPriceCtrl.text,
  //       'offer_price': productOffPriceCtrl.text.isEmpty
  //           ? productPriceCtrl.text
  //           : productOffPriceCtrl.text,
  //       'category': selectedCategory?.sId ?? '',
  //       'subcategory': selectedSubCategory?.sId,
  //       'brand': selectedBrand?.sId,
  //       'variant_type': selectedVariantType?.sId,
  //       'variants': jsonEncode(selectedVariants),
  //     };
  //
  //     final FormData form = await createFormDataForMultipleImage(
  //       imgXFiles: [
  //         {'images': imgXFile1},
  //         {'images': imgXFile2},
  //         {'images': imgXFile3},
  //         {'images': imgXFile4},
  //         {'images': imgXFile5},
  //       ],
  //       formData: formDataMap,
  //     );
  //
  //     final response = await service.updateItem(
  //       endpointUrl: 'products',
  //       itemId: '${productForUpdate?.sId}',
  //       itemData: form,
  //     );
  //
  //     if (response.isOk) {
  //       final responseBody = response.body;
  //
  //       if (responseBody['success'] == true) {
  //         clearFields();
  //         SnackBarHelper.showSuccessSnackBar('Product updated successfully');
  //         log('product updated');
  //         _dataProvider.getAllProducts();
  //       } else {
  //         SnackBarHelper.showErrorSnackBar(
  //             'Failed to update product: ${responseBody['error']}');
  //       }
  //     } else {
  //       SnackBarHelper.showErrorSnackBar(
  //           'Error: ${response.body?['error'] ?? response.statusText}');
  //     }
  //   } catch (e) {
  //     print('Error updating product: $e');
  //     SnackBarHelper.showErrorSnackBar('An error occurred: $e');
  //     rethrow;
  //   }
  // }


  // updateProduct() async {
  //   try {
  //     Map<String, dynamic> formDataMap = {
  //       'name': productNameCtrl.text,
  //       'description': productDescCtrl.text,
  //       'quantity': int.parse(productQntCtrl.text), // تبدیل به int
  //       'price': double.parse(productPriceCtrl.text), // تبدیل به double
  //       'offer_price': productOffPriceCtrl.text.isEmpty
  //           ? double.parse(productPriceCtrl.text)
  //           : double.parse(productOffPriceCtrl.text),
  //       'category': selectedCategory?.sId ?? '',
  //       'subcategory': selectedSubCategory?.sId,
  //       'brand': selectedBrand?.sId,
  //       'variant_type': selectedVariantType?.sId,
  //       'variants': selectedVariants, // ❗ بدون jsonEncode
  //     };
  //
  //     // لاگ برای دیباگ
  //     print('📤 Sending update form data: $formDataMap');
  //
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
  //     final response = await service.updateItem(
  //       endpointUrl: 'api/products', // ❗ با 'api/'
  //       itemId: '${productForUpdate?.sId}',
  //       itemData: form,
  //     );
  //
  //     if (response.isOk) {
  //       final responseBody = response.body;
  //       print('✅ Update Response: $responseBody');
  //
  //       if (responseBody['success'] == true) {
  //         clearFields();
  //         SnackBarHelper.showSuccessSnackBar('محصول با موفقیت به‌روزرسانی شد');
  //         _dataProvider.getAllProducts();
  //       } else {
  //         SnackBarHelper.showErrorSnackBar(
  //             'خطا در به‌روزرسانی محصول: ${responseBody['error']}');
  //       }
  //     } else {
  //       print('❌ HTTP Update Error: ${response.statusCode} - ${response.body}');
  //       SnackBarHelper.showErrorSnackBar(
  //           'خطای شبکه در به‌روزرسانی: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('❌ Error updating product: $e');
  //     SnackBarHelper.showErrorSnackBar('خطا در به‌روزرسانی محصول: $e');
  //   }
  // }


  // updateProduct() async {
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
  //     Map<String, dynamic> formDataMap = {
  //       'name': productNameCtrl.text,
  //       'description': productDescCtrl.text,
  //       'quantity': int.parse(productQntCtrl.text),
  //       'price': double.parse(productPriceCtrl.text),
  //       'offer_price': productOffPriceCtrl.text.isEmpty
  //           ? double.parse(productPriceCtrl.text)
  //           : double.parse(productOffPriceCtrl.text),
  //       'category': selectedCategory?.sId ?? '',
  //       'subcategory': selectedSubCategory?.sId,
  //       'brand': selectedBrand?.sId,
  //       'variant_type': selectedVariantType?.sId,
  //       'variants': variantIds, // ❗ ارسال IDها نه نام‌ها
  //     };
  //
  //     print('📤 Sending update form data: $formDataMap');
  //
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
  //     final response = await service.updateItem(
  //       endpointUrl: 'api/products',
  //       itemId: '${productForUpdate?.sId}',
  //       itemData: form,
  //     );
  //
  //     if (response.isOk) {
  //       final responseBody = response.body;
  //       print('✅ Update Response: $responseBody');
  //
  //       if (responseBody['success'] == true) {
  //         clearFields();
  //         SnackBarHelper.showSuccessSnackBar('محصول با موفقیت به‌روزرسانی شد');
  //         _dataProvider.getAllProducts();
  //       } else {
  //         SnackBarHelper.showErrorSnackBar(
  //             'خطا در به‌روزرسانی محصول: ${responseBody['error']}');
  //       }
  //     } else {
  //       print('❌ HTTP Update Error: ${response.statusCode} - ${response.body}');
  //       SnackBarHelper.showErrorSnackBar(
  //           'خطای شبکه در به‌روزرسانی: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('❌ Error updating product: $e');
  //     SnackBarHelper.showErrorSnackBar('خطا در به‌روزرسانی محصول: $e');
  //   }
  // }



  submitProduct() => productForUpdate != null ? updateProduct() : addProduct();

  addProduct() async {
    try {
      // تبدیل variant names به variant IDs
      List<String> variantIds = [];
      if (selectedVariants.isNotEmpty) {
        variantIds = _dataProvider.variants
            .where((variant) => selectedVariants.contains(variant.name))
            .map((variant) => variant.sId ?? '')
            .where((id) => id.isNotEmpty)
            .toList();
      }

      Map<String, dynamic> formDataMap = {
        'name': productNameCtrl.text,
        'description': productDescCtrl.text,
        'quantity': int.parse(productQntCtrl.text),
        'price': double.parse(productPriceCtrl.text),
        'offer_price': productOffPriceCtrl.text.isEmpty
            ? double.parse(productPriceCtrl.text)
            : double.parse(productOffPriceCtrl.text),
        'category': selectedCategory?.sId ?? '',
        'subcategory': selectedSubCategory?.sId,
        'brand': selectedBrand?.sId,
        'variant_type': selectedVariantType?.sId,
        'variants': jsonEncode(variantIds), // تبدیل به JSON string
      };

      print('📤 Sending form data: $formDataMap');
      print('🖼️ Images count: ${[imgXFile1, imgXFile2, imgXFile3, imgXFile4, imgXFile5].where((x) => x != null).length}');

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

      final response = await service.addItem(
          endpointUrl: 'api/products',
          itemData: form
      );

      if (response.isOk) {
        final responseBody = response.body;
        print('✅ Response: $responseBody');

        if (responseBody['success'] == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('محصول با موفقیت اضافه شد');
          _dataProvider.getAllProducts();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'خطا در افزودن محصول: ${responseBody['error']}');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode} - ${response.body}');
        SnackBarHelper.showErrorSnackBar(
            'خطای شبکه: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error adding product: $e');
      SnackBarHelper.showErrorSnackBar('خطا در افزودن محصول: $e');
    }
  }

  updateProduct() async {
    try {
      // تبدیل variant names به variant IDs
      List<String> variantIds = [];
      if (selectedVariants.isNotEmpty) {
        variantIds = _dataProvider.variants
            .where((variant) => selectedVariants.contains(variant.name))
            .map((variant) => variant.sId ?? '')
            .where((id) => id.isNotEmpty)
            .toList();
      }

      Map<String, dynamic> formDataMap = {
        'name': productNameCtrl.text,
        'description': productDescCtrl.text,
        'quantity': int.parse(productQntCtrl.text),
        'price': double.parse(productPriceCtrl.text),
        'offer_price': productOffPriceCtrl.text.isEmpty
            ? double.parse(productPriceCtrl.text)
            : double.parse(productOffPriceCtrl.text),
        'category': selectedCategory?.sId ?? '',
        'subcategory': selectedSubCategory?.sId,
        'brand': selectedBrand?.sId,
        'variant_type': selectedVariantType?.sId,
        'variants': jsonEncode(variantIds), // تبدیل به JSON string
      };

      print('📤 Sending update form data: $formDataMap');
      print('🖼️ Images count: ${[imgXFile1, imgXFile2, imgXFile3, imgXFile4, imgXFile5].where((x) => x != null).length}');

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

      final response = await service.updateItem(
        endpointUrl: 'api/products',
        itemId: '${productForUpdate?.sId}',
        itemData: form,
      );

      if (response.isOk) {
        final responseBody = response.body;
        print('✅ Update Response: $responseBody');

        if (responseBody['success'] == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('محصول با موفقیت به‌روزرسانی شد');
          _dataProvider.getAllProducts();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'خطا در به‌روزرسانی محصول: ${responseBody['error']}');
        }
      } else {
        print('❌ HTTP Update Error: ${response.statusCode} - ${response.body}');
        SnackBarHelper.showErrorSnackBar(
            'خطای شبکه در به‌روزرسانی: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating product: $e');
      SnackBarHelper.showErrorSnackBar('خطا در به‌روزرسانی محصول: $e');
    }
  }


  deleteProduct(Product product) async {
    try {
      Response response = await service.deleteItem(
          endpointUrl: 'api/products', // ❗ با 'api/'
          itemId: product.sId ?? ''
      );

      if (response.isOk) {
        final responseBody = response.body;

        if (responseBody['success'] == true) {
          SnackBarHelper.showSuccessSnackBar('محصول با موفقیت حذف شد!');
          _dataProvider.getAllProducts();
        } else {
          SnackBarHelper.showErrorSnackBar('خطا در حذف محصول: ${responseBody['error']}');
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
  // deleteProduct(Product product) async {
  //   try {
  //     Response response = await service.deleteItem(
  //         endpointUrl: 'products',
  //         itemId: product.sId ?? ''
  //     );
  //
  //     if (response.isOk) {
  //       final responseBody = response.body;
  //
  //       if (responseBody['success'] == true) {
  //         SnackBarHelper.showSuccessSnackBar('Product deleted successfully!');
  //         _dataProvider.getAllProducts();
  //       } else {
  //         SnackBarHelper.showErrorSnackBar('Failed to delete product: ${responseBody['error']}');
  //       }
  //     } else {
  //       SnackBarHelper.showErrorSnackBar(
  //           'Error: ${response.body?['error'] ?? response.statusText}');
  //     }
  //   } catch (e) {
  //     print('Error deleting product: $e');
  //     SnackBarHelper.showErrorSnackBar('An error occurred: $e');
  //     rethrow;
  //   }
  // }




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

    // اضافه کردن تصاویر با نام یکسان برای سرور PocketBase
    if (imgXFiles != null) {
      for (int i = 0; i < imgXFiles.length; i++) {
        XFile? imgXFile = imgXFiles[i]['images'];
        if (imgXFile != null) {
          if (kIsWeb) {
            String fileName = imgXFile.name;
            Uint8List byteImg = await imgXFile.readAsBytes();
            form.files.add(MapEntry(
              'images', // نام یکسان برای همه تصاویر
              MultipartFile(byteImg, filename: fileName),
            ));
          } else {
            String filePath = imgXFile.path;
            String fileName = filePath.split('/').last;
            form.files.add(MapEntry(
              'images', // نام یکسان برای همه تصاویر
              await MultipartFile(filePath, filename: fileName),
            ));
          }
        }
      }
    }

    return form;
  }

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


  setDataForUpdateProduct(Product? product) {
    if (product != null) {
      productForUpdate = product;

      productNameCtrl.text = product.name ?? '';
      productDescCtrl.text = product.description ?? '';
      productPriceCtrl.text = product.price?.toString() ?? '';
      productOffPriceCtrl.text = product.offerPrice?.toString() ?? '';
      productQntCtrl.text = product.quantity?.toString() ?? '';

      // تنظیم مقادیر dropdown ها
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

      // تبدیل variant IDs به variant names برای نمایش
      selectedVariants = _dataProvider.variants
          .where((variant) => product.proVariantId?.contains(variant.sId) ?? false)
          .map((variant) => variant.name ?? '')
          .toList();
    } else {
      // ❗ به جای clearFields() مستقیم، فقط فیلدها رو خالی کن
      _clearFieldsWithoutNotify();
    }
    // ❌ notifyListeners() رو حذف کن
  }

// تابع جدید برای پاک کردن فیلدها بدون notify
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

    // notifyListeners() اینجا صدا زده نمیشه
  }
  clearFields() {
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

    notifyListeners();
  }

  updateUI() {
    notifyListeners();
  }
}

