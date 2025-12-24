
import 'dart:io';
import 'package:admin/core/data/appwrite/product_images_storage_service.dart';
import 'package:admin/core/data/appwrite/products_appwrite_service.dart';
import 'package:admin/models/variant.dart';
import 'package:admin/utility/User_helper.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;


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

import '../../../utility/snack_bar_helper.dart';

class DashBoardProvider extends ChangeNotifier {
  final DataProvider _dataProvider;
  final ProductsAppwriteService _service = ProductsAppwriteService();

  DashBoardProvider(this._dataProvider);

  final addProductFormKey = GlobalKey<FormState>();

  // Controllers (همانی که UI استفاده می‌کند)
  final TextEditingController productNameCtrl = TextEditingController();
  final TextEditingController productDescCtrl = TextEditingController();
  final TextEditingController productQntCtrl = TextEditingController();
  final TextEditingController productPriceCtrl = TextEditingController();
  final TextEditingController productOffPriceCtrl = TextEditingController();

  // selections
  Category? selectedCategory;
  SubCategory? selectedSubCategory;
  Brand? selectedBrand;
  VariantType? selectedVariantType;

  // multi variants
  List<Variant> selectedVariants = <Variant>[];

  // dropdown dependent lists
  List<SubCategory> subCategoriesByCategory = <SubCategory>[];
  List<Brand> brandsBySubCategory = <Brand>[];
  List<Variant> variantsByVariantType = <Variant>[];

  // images slots (فقط برای UI preview؛ در Appwrite فعلاً باید imageUrls داشته باشی)
  final Set<int> removedImageSlots = {};
  File? selectedMainImage, selectedSecondImage, selectedThirdImage, selectedFourthImage, selectedFifthImage;
  XFile? imgXFile1, imgXFile2, imgXFile3, imgXFile4, imgXFile5;

  // Appwrite model images: URL list
  final List<String> imageUrls = <String>[];

  Product? productForUpdate;
  void setDataForUpdateProduct(Product? product) {
    // ✅ مثل پوستر: اگر null بود یعنی حالت افزودن → پاکسازی کامل
    if (product == null) {
      clearFields();
      return;
    }

    // جلوگیری از loop در rebuild ها
    if (productForUpdate?.sId == product.sId) return;

    setDataForUpdate(product);
  }

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;


  void setDataForUpdate(Product? p) {
    if (p == null) {
      clearFields();
      return;
    }

    productForUpdate = p;

    productNameCtrl.text = p.name ?? '';
    productDescCtrl.text = p.description ?? '';
    productQntCtrl.text = p.quantity ?? '';
    productPriceCtrl.text = p.price ?? '';
    productOffPriceCtrl.text = p.offerPrice ?? '';

    // ✅ تصاویر: در حالت ویرایش، عکس‌ها از URL موجود می‌آیند.
    // انتخاب‌های موقت/حذف‌های موقت را صفر می‌کنیم.
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

    removedImageSlots.clear();

    imageUrls
      ..clear()
      ..addAll(p.imageUrls);

    final catId = p.categoryId;
    final subId = p.subCategoryId;
    final brId = p.brandId;
    final vtId = p.variantTypeId;

    selectedCategory = _dataProvider.categories.firstWhereOrNull((e) => e.sId == catId);
    if (selectedCategory != null) {
      filterSubcategory(selectedCategory!);
      selectedSubCategory = subCategoriesByCategory.firstWhereOrNull((e) => e.sId == subId);
    }

    if (selectedSubCategory != null) {
      filterBrand(selectedSubCategory!);
      selectedBrand = brandsBySubCategory.firstWhereOrNull((e) => e.sId == brId);
    } else {
      selectedBrand = null;
      brandsBySubCategory = <Brand>[];
    }

    selectedVariantType = _dataProvider.variantTypes.firstWhereOrNull((e) => e.sId == vtId);
    if (selectedVariantType != null) {
      filterVariant(selectedVariantType!);
    }

    selectedVariants = <Variant>[];
    final ids = p.variantIds;
    for (final id in ids) {
      final v = _dataProvider.variants.firstWhereOrNull((e) => e.sId == id);
      if (v != null) selectedVariants.add(v);
    }

    notifyListeners();
  }




  final ProductImagesStorageService _imageStorage = ProductImagesStorageService();



  Future<bool> submitProduct() async {
    if (_isSubmitting) return false;


      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';
      if (phone.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن/کد پیدا نشد!');
        return false;
      }
    final form = addProductFormKey.currentState;
    if (form == null) return false;
    if (!form.validate()) return false;
    form.save();

    _isSubmitting = true;
    notifyListeners();

    bool _isValidUrl(String s) {
      final v = s.trim();
      if (v.isEmpty) return false;
      if (v.startsWith('Instance of')) return false;
      return v.startsWith('http://') || v.startsWith('https://');
    }

    List<String> _ensure5Slots(List<String> input) {
      final out = List<String>.from(input);
      while (out.length < 5) out.add('');
      if (out.length > 5) out.removeRange(5, out.length);
      return out;
    }

    try {
      // ----------- Guards (مثل روال فعلی شما)
      final categoryId = selectedCategory?.sId?.trim();
      final subId = selectedSubCategory?.sId?.trim();
      final brandId = selectedBrand?.sId?.trim();
      final vtId = selectedVariantType?.sId?.trim();

      if (categoryId == null || categoryId.isEmpty) {
        SnackBarHelper.showErrorSnackBar('کتگوری را انتخاب کنید');
        return false;
      }
      if (subId == null || subId.isEmpty) {
        SnackBarHelper.showErrorSnackBar('ساب‌کتگوری را انتخاب کنید');
        return false;
      }
      if (brandId == null || brandId.isEmpty) {
        SnackBarHelper.showErrorSnackBar('برند را انتخاب کنید');
        return false;
      }
      if (vtId == null || vtId.isEmpty) {
        SnackBarHelper.showErrorSnackBar('VariantType را انتخاب کنید');
        return false;
      }

      final variantIds = selectedVariants
          .map((e) => (e.sId ?? '').trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final isUpdate =
          productForUpdate != null && (productForUpdate!.sId?.trim().isNotEmpty ?? false);

      // ✅ برای حذف عکس‌های قبلی بعد از آپدیت موفق
      final oldUrls = List<String>.from(productForUpdate?.imageUrls ?? const []);

      // ----------- Base urls (برای update از دیتای قبلی، برای create از وضعیت فعلی)
      final baseUrls = isUpdate
          ? List<String>.from(productForUpdate!.imageUrls)
          : List<String>.from(imageUrls);

      final updatedSlots = _ensure5Slots(baseUrls);

      // ----------- اعمال حذف اسلات‌ها
      for (final slot in removedImageSlots) {
        final i = slot - 1;
        if (i >= 0 && i < updatedSlots.length) {
          updatedSlots[i] = '';
        }
      }

      // ----------- جمع کردن فایل‌های انتخاب‌شده برای آپلود
      final List<(int slot, XFile file)> picked = [];
      if (imgXFile1 != null) picked.add((1, imgXFile1!));
      if (imgXFile2 != null) picked.add((2, imgXFile2!));
      if (imgXFile3 != null) picked.add((3, imgXFile3!));
      if (imgXFile4 != null) picked.add((4, imgXFile4!));
      if (imgXFile5 != null) picked.add((5, imgXFile5!));

      // ----------- آپلود و جایگزینی URL در اسلات مربوطه
      for (final item in picked) {
        final slot = item.$1;
        final file = item.$2;

        final uploaded = await _imageStorage.upload(file: file); // ✅ مثل پوستر
        final i = slot - 1;

        if (i >= 0 && i < updatedSlots.length) {
          updatedSlots[i] = uploaded.viewUrl; // ✅ فقط URL
        }
      }

      // ----------- خروجی نهایی imageUrls برای دیتابیس
      final dbUrls = updatedSlots.where(_isValidUrl).toList();

      // برای هماهنگ شدن UI بعد از سابمیت
      imageUrls
        ..clear()
        ..addAll(dbUrls);

      // ----------- ساخت مدل
      final model = Product(
        sId: productForUpdate?.sId,
        name: productNameCtrl.text.trim(),
        description: productDescCtrl.text.trim(),
        quantity: productQntCtrl.text.trim(),
        price: productPriceCtrl.text.trim(),
        offerPrice: productOffPriceCtrl.text.trim(),
        phoneNumberCode: phone,
        imageUrls: List<String>.from(dbUrls),

        categoryId: categoryId,
        subCategoryId: subId,
        brandId: brandId,
        variantTypeId: vtId,
        variantIds: variantIds,
      );

      // ----------- Create / Update
      if (!isUpdate) {
        final res = await _service.createProduct(
          data: model.toAppwriteData(forUpdate: false),
        );

        if (res.isSuccess) {
          SnackBarHelper.showSuccessSnackBar('محصول ایجاد شد');
          await _dataProvider.getAllProducts(showSnack: false);
          clearFields();
          return true;
        }

        final err = res.requireError();
        SnackBarHelper.showErrorSnackBar(
          err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'خطا'),
        );
        return false;
      } else {
        final id = productForUpdate!.sId!.trim();

        final res = await _service.updateProduct(
          documentId: id,
          data: model.toAppwriteData(forUpdate: true),
        );

        if (res.isSuccess) {
          // ✅ حذف عکس‌های قدیمی که دیگر در محصول نیستند
          final oldSet = oldUrls.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
          final newSet = dbUrls.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();

          final urlsToDelete = oldSet.difference(newSet).toList();
          await _imageStorage.deleteManyByViewUrls(urlsToDelete);

          SnackBarHelper.showSuccessSnackBar('محصول بروزرسانی شد');
          await _dataProvider.getAllProducts(showSnack: false);
          clearFields();
          return true;
        }

        final err = res.requireError();
        SnackBarHelper.showErrorSnackBar(
          err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'خطا'),
        );
        return false;
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('خطا: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(Product p) async {
    final id = p.sId ?? '';
    if (id.isEmpty) {
      SnackBarHelper.showErrorSnackBar('ID محصول نامعتبر است');
      return;
    }

    // قبل از حذف سند، URLها را نگه می‌داریم
    final oldUrls = List<String>.from(p.imageUrls);

    final res = await _service.deleteProduct(id);
    if (res.isSuccess) {
      // بعد از حذف محصول، همه عکس‌ها حذف شوند
      await _imageStorage.deleteManyByViewUrls(oldUrls);

      SnackBarHelper.showSuccessSnackBar('محصول حذف شد');
      await _dataProvider.getAllProducts(showSnack: false);
    } else {
      final err = res.requireError();
      SnackBarHelper.showErrorSnackBar(
        err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'خطا'),
      );
    }
  }


  void setSelectedVariants(List<Variant> items) {
    selectedVariants = List<Variant>.from(items);
    notifyListeners();
  }

  // ---------- Filters
  void filterSubcategory(Category category) {
    selectedCategory = category;
    selectedSubCategory = null;
    selectedBrand = null;

    subCategoriesByCategory = _dataProvider.subCategories
        .where((s) => s.categoryId?.sId == category.sId)
        .toList();

    subCategoriesByCategory.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

    brandsBySubCategory = <Brand>[];
    notifyListeners();
  }

  void filterBrand(SubCategory subCategory) {
    selectedSubCategory = subCategory;
    selectedBrand = null;

    brandsBySubCategory = _dataProvider.brands
        .where((b) => b.subcategory == subCategory.sId || b.subCategoryId?.sId == subCategory.sId)
        .toList();

    brandsBySubCategory.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

    notifyListeners();
  }

  void filterVariant(VariantType type) {
    selectedVariantType = type;

    final vtId = type.sId;
    variantsByVariantType = _dataProvider.variants
        .where((v) => (v.variantType ?? v.variantTypeId?.sId) == vtId)
        .toList();

    variantsByVariantType.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

    // اگر قبلاً انتخاب داشتیم، آنهایی که دیگر زیر این type نیستند حذف شوند
    selectedVariants = selectedVariants
        .where((sel) => variantsByVariantType.any((v) => v.sId == sel.sId))
        .toList();

    notifyListeners();
  }


  Future<void> pickImage({required int imageCardNumber}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    // ✅ اول XFile ست شود تا اگر File روی وب مشکل داشت، Submit از کار نیفتد
    switch (imageCardNumber) {
      case 1:
        imgXFile1 = image;
        break;
      case 2:
        imgXFile2 = image;
        break;
      case 3:
        imgXFile3 = image;
        break;
      case 4:
        imgXFile4 = image;
        break;
      case 5:
        imgXFile5 = image;
        break;
      default:
        return;
    }

    // برای Preview
    try {
      final f = File(image.path);
      switch (imageCardNumber) {
        case 1:
          selectedMainImage = f;
          break;
        case 2:
          selectedSecondImage = f;
          break;
        case 3:
          selectedThirdImage = f;
          break;
        case 4:
          selectedFourthImage = f;
          break;
        case 5:
          selectedFifthImage = f;
          break;
      }
    } catch (_) {
      switch (imageCardNumber) {
        case 1:
          selectedMainImage = null;
          break;
        case 2:
          selectedSecondImage = null;
          break;
        case 3:
          selectedThirdImage = null;
          break;
        case 4:
          selectedFourthImage = null;
          break;
        case 5:
          selectedFifthImage = null;
          break;
      }
    }

    removedImageSlots.remove(imageCardNumber);
    notifyListeners();
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
    removedImageSlots.add(slot);
    notifyListeners();
  }


  void clearFields() {
    productForUpdate = null;

    productNameCtrl.clear();
    productDescCtrl.clear();
    productQntCtrl.clear();
    productPriceCtrl.clear();
    productOffPriceCtrl.clear();

    selectedCategory = null;
    selectedSubCategory = null;
    selectedBrand = null;
    selectedVariantType = null;

    selectedVariants = <Variant>[];
    subCategoriesByCategory = <SubCategory>[];
    brandsBySubCategory = <Brand>[];
    variantsByVariantType = <Variant>[];

    // ✅ تصاویر
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

    removedImageSlots.clear();
    imageUrls.clear();

    notifyListeners();
  }

  void updateUI() => notifyListeners();

  @override
  void dispose() {
    productNameCtrl.dispose();
    productDescCtrl.dispose();
    productQntCtrl.dispose();
    productPriceCtrl.dispose();
    productOffPriceCtrl.dispose();
    super.dispose();
  }
}
