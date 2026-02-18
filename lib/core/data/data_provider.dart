import 'dart:convert';

import 'package:admin/core/data/appwrite/brands_repository.dart';
import 'package:admin/core/data/appwrite/coupon_code_appwrite_service.dart';
import 'package:admin/core/data/appwrite/orders_appwrite_service.dart';
import 'package:admin/core/data/appwrite/products_appwrite_service.dart';
import 'package:admin/core/data/appwrite/sub_category_appwrite_service.dart';
import 'package:admin/core/data/appwrite/variant_types_repository.dart';
import 'package:admin/core/data/appwrite/variants_repository.dart';

import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;


import '../../../models/category.dart';
import '../../models/brand.dart';
import '../../models/coupon.dart';

import '../../models/order.dart';
import '../../models/poster.dart';
import '../../models/product.dart';
import '../../models/sub_category.dart';
import '../../models/variant.dart';
import '../../models/variant_type.dart';

import '../../utility/constants.dart';
import 'dart:async';


import 'appwrite/categories_repository.dart';
import 'appwrite/poster_appwrite_service.dart';





class DataProvider extends ChangeNotifier {

static const int _productsPageSize = 500;

bool _productsLoading = false;
bool _productsLoadingMore = false;
bool _productsHasMore = true;

String? _productsCursorAfter;
String _productKeyword = '';

bool get isProductsLoading => _productsLoading;
bool get isProductsLoadingMore => _productsLoadingMore;
bool get hasMoreProducts => _productsHasMore;

// --- sort helper: newest updatedAt/createdAt first ---
DateTime _productTs(Product p) {
  final u = (p.updatedAt ?? '').trim();
  final c = (p.createdAt ?? '').trim();
  final raw = u.isNotEmpty ? u : c;
  final dt = DateTime.tryParse(raw);
  return dt ?? DateTime.fromMillisecondsSinceEpoch(0);
}

void _sortAllProducts() {
  _allProducts.sort((a, b) => _productTs(b).compareTo(_productTs(a))); // DESC
}

/// ✅ create/update => بیاد اول (بدون reload)
void upsertProductToTop(Product incoming) {
  final id = (incoming.sId ?? '').trim();
  if (id.isEmpty) return;

  incoming.updatedAt ??= DateTime.now().toIso8601String();

  final idx = _allProducts.indexWhere((x) => (x.sId ?? '').trim() == id);
  if (idx != -1) _allProducts.removeAt(idx);

  _allProducts.insert(0, incoming);

  _hydrateProductsNames([incoming]); // مهم: category/subcategory
  _applyProductFilter();
  notifyListeners();
}

/// ✅ حذف محصول از لیست بعد از delete
void removeProductById(String id) {
  final sid = id.trim();
  if (sid.isEmpty) return;
  _allProducts.removeWhere((p) => (p.sId ?? '').trim() == sid);
  _applyProductFilter();
  notifyListeners();
}

Future<List<Product>> getAllProducts({bool showSnack = false}) async {
  return loadInitialProducts(showSnack: showSnack);
}

Future<List<Product>> loadInitialProducts({bool showSnack = false}) async {
  if (_productsLoading) return _filteredProducts;

  _productsLoading = true;
  _productsLoadingMore = false;
  _productsHasMore = true;
  _productsCursorAfter = null;

  _allProducts.clear();
  _filteredProducts = const [];
  notifyListeners();

  try {
    final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
    if (phone.trim().isEmpty) {
      if (showSnack) SnackBarHelper.showErrorSnackBar('شماره تلفن/کد در حافظه یافت نشد!');
      return _filteredProducts;
    }

    // ✅ برای hydrate نام‌ها
    await _ensureCategoriesLoadedForProducts();
    await _ensureSubCategoriesLoadedForProducts();

    final res = await _productsService.getPagedByPhoneNumberCode(
      phone.trim(),
      limit: _productsPageSize,
      cursorAfter: null,
    );

    if (res.isSuccess) {
      final items = res.requireData();

      _hydrateProductsNames(items);
      _allProducts.addAll(items);

      _productsHasMore = items.length >= _productsPageSize;
      _productsCursorAfter = _productsHasMore && items.isNotEmpty ? items.last.sId : null;

      _applyProductFilter();
      if (showSnack) SnackBarHelper.showSuccessSnackBar('Products loaded');
      return _filteredProducts;
    } else {
      if (showSnack) SnackBarHelper.showErrorSnackBar(res.requireError().userMessage);
      return _filteredProducts;
    }
  } finally {
    _productsLoading = false;
    notifyListeners();
  }
}

Future<List<Product>> loadMoreProducts({bool showSnack = false}) async {
  if (_productsLoading || _productsLoadingMore || !_productsHasMore) return _filteredProducts;

  _productsLoadingMore = true;
  notifyListeners();

  try {
    final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
    if (phone.trim().isEmpty) return _filteredProducts;

    await _ensureCategoriesLoadedForProducts();
    await _ensureSubCategoriesLoadedForProducts();

    final res = await _productsService.getPagedByPhoneNumberCode(
      phone.trim(),
      limit: _productsPageSize,
      cursorAfter: _productsCursorAfter,
    );

    if (res.isSuccess) {
      final items = res.requireData();

      if (items.isEmpty) {
        _productsHasMore = false;
        return _filteredProducts;
      }

      _hydrateProductsNames(items);

      // ✅ upsert جلوگیری از تکرار
      for (final p in items) {
        final id = (p.sId ?? '').trim();
        if (id.isEmpty) continue;

        final idx = _allProducts.indexWhere((x) => (x.sId ?? '').trim() == id);
        if (idx == -1) {
          _allProducts.add(p);
        } else {
          _allProducts[idx] = p;
        }
      }

      _productsHasMore = items.length >= _productsPageSize;
      _productsCursorAfter = _productsHasMore ? items.last.sId : null;

      _applyProductFilter();
      return _filteredProducts;
    } else {
      if (showSnack) SnackBarHelper.showErrorSnackBar(res.requireError().userMessage);
      return _filteredProducts;
    }
  } finally {
    _productsLoadingMore = false;
    notifyListeners();
  }
}

void filterProducts(String keyword) {
  _productKeyword = keyword.trim();
  _applyProductFilter();
  notifyListeners();
}

void _applyProductFilter() {
  _sortAllProducts();

  final kw = _productKeyword.trim().toLowerCase();
  if (kw.isEmpty) {
    _filteredProducts = List<Product>.from(_allProducts);
    return;
  }

  _filteredProducts = _allProducts.where((p) {
    final name = (p.name ?? '').toLowerCase();
    final cat = (p.resolvedCategoryName ?? '').toLowerCase();
    final sub = (p.resolvedSubCategoryName ?? '').toLowerCase();
    return name.contains(kw) || cat.contains(kw) || sub.contains(kw);
  }).toList()
    ..sort((a, b) => _productTs(b).compareTo(_productTs(a)));
}

// -------- Hydration (Category/SubCategory names) --------

Future<void> _ensureCategoriesLoadedForProducts() async {
  if (_allCategories.isEmpty) {
    await getAllCategories(showSnack: false);
  }
}

Future<void> _ensureSubCategoriesLoadedForProducts() async {
  if (_allSubCategories.isEmpty) {
    await getAllSubCategories(showSnack: false);
  }
}

void _hydrateProductsNames(List<Product> products) {
  if (products.isEmpty) return;

  final catMap = <String, String>{};
  for (final c in _allCategories) {
    final id = (c.sId ?? '').trim();
    if (id.isNotEmpty) catMap[id] = (c.name ?? '').trim();
  }

  final subMap = <String, String>{};
  for (final s in _allSubCategories) {
    final id = (s.sId ?? '').trim();
    if (id.isNotEmpty) subMap[id] = (s.name ?? '').trim();
  }

  for (final p in products) {
    final cid = (p.categoryId ?? '').trim();
    final sid = (p.subCategoryId ?? '').trim();
    p.resolvedCategoryName = catMap[cid] ?? '';
    p.resolvedSubCategoryName = subMap[sid] ?? '';
  }
}

// ================================
// ✅ COUPONS (Paging + Shimmer + Updated first)
// ================================
static const int _couponsPageSize = 500;

bool _couponsLoading = false;
bool _couponsLoadingMore = false;
bool _couponsHasMore = true;

String? _couponsCursorAfter;
String _couponKeyword = '';

bool get isCouponsLoading => _couponsLoading;
bool get isCouponsLoadingMore => _couponsLoadingMore;
bool get hasMoreCoupons => _couponsHasMore;

DateTime _couponTs(Coupon c) {
  final u = (c.updatedAt ?? '').trim();
  final cr = (c.createdAt ?? '').trim();
  final raw = u.isNotEmpty ? u : cr;
  final dt = DateTime.tryParse(raw);
  return dt ?? DateTime.fromMillisecondsSinceEpoch(0);
}

void _sortAllCoupons() {
  _allCoupons.sort((a, b) => _couponTs(b).compareTo(_couponTs(a)));
}

void _applyCouponFilter() {
  _sortAllCoupons();

  final kw = _couponKeyword.trim().toLowerCase();
  if (kw.isEmpty) {
    _filteredCoupons = List<Coupon>.from(_allCoupons);
    return;
  }

  _filteredCoupons = _allCoupons
      .where((c) => (c.couponCode ?? '').toLowerCase().contains(kw))
      .toList()
    ..sort((a, b) => _couponTs(b).compareTo(_couponTs(a)));
}

Future<List<Coupon>> getAllCoupons({bool showSnack = false}) async {
  return loadInitialCoupons(showSnack: showSnack);
}

Future<List<Coupon>> loadInitialCoupons({bool showSnack = false}) async {
  if (_couponsLoading) return _filteredCoupons;

  _couponsLoading = true;
  _couponsLoadingMore = false;
  _couponsHasMore = true;
  _couponsCursorAfter = null;

  _allCoupons.clear();
  _filteredCoupons = const [];
  notifyListeners();

  try {
    final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
    if (phone.trim().isEmpty) return _filteredCoupons;

    final res = await _couponService.getPagedByPhoneNumberCode(
      phone.trim(),
      limit: _couponsPageSize,
      cursorAfter: null,
    );

    if (res.isSuccess) {
      final items = res.requireData();
      _allCoupons.addAll(items);

      _couponsHasMore = items.length >= _couponsPageSize;
      _couponsCursorAfter = _couponsHasMore && items.isNotEmpty ? items.last.sId : null;

      _applyCouponFilter();
      return _filteredCoupons;
    } else {
      if (showSnack) SnackBarHelper.showErrorSnackBar(res.requireError().userMessage);
      return _filteredCoupons;
    }
  } finally {
    _couponsLoading = false;
    notifyListeners();
  }
}

Future<List<Coupon>> loadMoreCoupons({bool showSnack = false}) async {
  if (_couponsLoading || _couponsLoadingMore || !_couponsHasMore) {
    return _filteredCoupons;
  }

  _couponsLoadingMore = true;
  notifyListeners();

  try {
    final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
    if (phone.trim().isEmpty) return _filteredCoupons;

    final res = await _couponService.getPagedByPhoneNumberCode(
      phone.trim(),
      limit: _couponsPageSize,
      cursorAfter: _couponsCursorAfter,
    );

    if (res.isSuccess) {
      final items = res.requireData();
      if (items.isEmpty) {
        _couponsHasMore = false;
        return _filteredCoupons;
      }

      // upsert جلوگیری از تکرار
      for (final c in items) {
        final id = (c.sId ?? '').trim();
        if (id.isEmpty) continue;

        final idx = _allCoupons.indexWhere((x) => (x.sId ?? '').trim() == id);
        if (idx == -1) {
          _allCoupons.add(c);
        } else {
          _allCoupons[idx] = c;
        }
      }

      _couponsHasMore = items.length >= _couponsPageSize;
      _couponsCursorAfter = _couponsHasMore ? items.last.sId : null;

      _applyCouponFilter();
      return _filteredCoupons;
    } else {
      if (showSnack) SnackBarHelper.showErrorSnackBar(res.requireError().userMessage);
      return _filteredCoupons;
    }
  } finally {
    _couponsLoadingMore = false;
    notifyListeners();
  }
}

void filterCoupons(String keyword) {
  _couponKeyword = keyword.trim();
  _applyCouponFilter();
  notifyListeners();
}


  static const int _brandsPageSize = 500;

  bool _brandsLoading = false;
  bool _brandsLoadingMore = false;
  bool _brandsHasMore = true;

  String? _brandsCursorAfter;
  final Set<String> _loadedBrandIds = {};

  String _brandKeyword = '';

  bool get isBrandsLoading => _brandsLoading;
  bool get isBrandsLoadingMore => _brandsLoadingMore;
  bool get hasMoreBrands => _brandsHasMore;

// --- Sort helper: newest updatedAt/createdAt first ---
  DateTime _brandTs(Brand b) {
    final u = (b.updatedAt ?? '').trim();
    final c = (b.createdAt ?? '').trim();
    final raw = u.isNotEmpty ? u : c;
    final dt = DateTime.tryParse(raw);
    return dt ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _sortAllBrands() {
    _allBrands.sort((a, b) => _brandTs(b).compareTo(_brandTs(a))); // DESC
  }

  /// ✅ create/update برند => بیاد اول (بدون reload)
  void upsertBrandToTop(Brand incoming) {
    final id = (incoming.sId ?? '').trim();
    if (id.isEmpty) return;

    incoming.updatedAt ??= DateTime.now().toIso8601String();

    final idx = _allBrands.indexWhere((x) => (x.sId ?? '').trim() == id);
    if (idx != -1) _allBrands.removeAt(idx);

    _allBrands.insert(0, incoming);

    _applyBrandFilter();
    notifyListeners();
  }

  /// ✅ حذف از لیست (بعد از delete)
  void removeBrandById(String id) {
    final sid = id.trim();
    if (sid.isEmpty) return;

    _allBrands.removeWhere((b) => (b.sId ?? '').trim() == sid);
    _applyBrandFilter();
    notifyListeners();
  }

// -------- SubCategory cache for brands (برای اینکه نام زیر‌دسته همیشه بیاد) --------
  final Map<String, SubCategory> _scCacheForBrands = {};
  String? _scCachePhoneForBrands;

  Future<void> _ensureSubCategoryCacheForBrands(String phone, List<Brand> brands) async {
    if (_scCachePhoneForBrands != phone) {
      _scCachePhoneForBrands = phone;
      _scCacheForBrands.clear();
    }

    // seed from already loaded subcategories
    for (final sc in _allSubCategories) {
      final id = (sc.sId ?? '').trim();
      if (id.isNotEmpty) _scCacheForBrands[id] = sc;
    }

    final missing = <String>{};
    for (final b in brands) {
      final subId = (b.subcategory ?? b.subcategoriesId ?? b.subCategoryId?.sId ?? '').toString().trim();
      if (subId.isNotEmpty && !_scCacheForBrands.containsKey(subId)) {
        missing.add(subId);
      }
    }

    // fetch missing ones (page size کوچیکه، مشکلی نیست)
    for (final id in missing) {
      final res = await _subCategoryService.getById(id);
      if (res.isSuccess) {
        final sc = res.requireData();
        final sid = (sc.sId ?? '').trim();
        if (sid.isNotEmpty) _scCacheForBrands[sid] = sc;
      }
    }
  }

  void _hydrateBrandsWithSubCategoryNames(List<Brand> brands) {
    for (final b in brands) {
      final subId = (b.subcategory ?? b.subcategoriesId ?? b.subCategoryId?.sId ?? '').toString().trim();
      if (subId.isEmpty) continue;

      final sc = _scCacheForBrands[subId];
      if (sc == null) continue;

      b.subCategoryId = SubcategoryId(
        sId: sc.sId,
        name: sc.name,
      );
    }
  }

  void filterBrands(String keyword) {
    _brandKeyword = keyword.trim();
    _applyBrandFilter();
    notifyListeners();
  }

  Future<List<Brand>> getAllBrands({bool showSnack = false}) async {
    return loadInitialBrands(showSnack: showSnack);
  }

  Future<List<Brand>> loadInitialBrands({bool showSnack = false}) async {
    if (_brandsLoading) return _filteredBrands;

    _brandsLoading = true;
    _brandsLoadingMore = false;
    _brandsHasMore = true;
    _brandsCursorAfter = null;
    _loadedBrandIds.clear();

    _allBrands.clear();
    _filteredBrands = const [];
    notifyListeners();

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
      if (phone.trim().isEmpty) {
        if (showSnack) SnackBarHelper.showErrorSnackBar('شماره تلفن/کد در حافظه یافت نشد!');
        return _filteredBrands;
      }

      // حداقل صفحه اول subcategories برای dropdownها
      await _ensureSubCategoriesLoadedForBrands();

      final res = await brandsRepoAppwrite.getPagedByPhoneNumberCode(
        phone.trim(),
        limit: _brandsPageSize,
        cursorAfter: null,
      );

      if (res.isSuccess) {
        final items = res.requireData();

        await _ensureSubCategoryCacheForBrands(phone.trim(), items);
        _hydrateBrandsWithSubCategoryNames(items);

        _allBrands.addAll(items);

        _brandsHasMore = items.length >= _brandsPageSize;
        _brandsCursorAfter = _brandsHasMore && items.isNotEmpty ? items.last.sId : null;

        _applyBrandFilter();
        notifyListeners();

        if (showSnack) SnackBarHelper.showSuccessSnackBar('Brands loaded');
        return _filteredBrands;
      } else {
        final err = res.requireError();
        if (showSnack) SnackBarHelper.showErrorSnackBar(err.userMessage);
        return _filteredBrands;
      }
    } finally {
      _brandsLoading = false;
      notifyListeners();
    }
  }

  Future<List<Brand>> loadMoreBrands({bool showSnack = false}) async {
    if (_brandsLoading || _brandsLoadingMore || !_brandsHasMore) return _filteredBrands;

    _brandsLoadingMore = true;
    notifyListeners();

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
      if (phone.trim().isEmpty) return _filteredBrands;

      final res = await brandsRepoAppwrite.getPagedByPhoneNumberCode(
        phone.trim(),
        limit: _brandsPageSize,
        cursorAfter: _brandsCursorAfter,
      );

      if (res.isSuccess) {
        final items = res.requireData();
        if (items.isEmpty) {
          _brandsHasMore = false;
          return _filteredBrands;
        }

        await _ensureSubCategoriesLoadedForBrands();
        await _ensureSubCategoryCacheForBrands(phone.trim(), items);
        _hydrateBrandsWithSubCategoryNames(items);

        // upsert + جلوگیری از تکرار
        for (final b in items) {
          final id = (b.sId ?? '').trim();
          if (id.isEmpty) continue;

          final idx = _allBrands.indexWhere((x) => (x.sId ?? '').trim() == id);
          if (idx == -1) {
            _allBrands.add(b);
          } else {
            _allBrands[idx] = b;
          }
          _loadedBrandIds.add(id);
        }

        _brandsHasMore = items.length >= _brandsPageSize;
        _brandsCursorAfter = _brandsHasMore ? items.last.sId : null;

        _applyBrandFilter();
        return _filteredBrands;
      } else {
        final err = res.requireError();
        if (showSnack) SnackBarHelper.showErrorSnackBar(err.userMessage);
        return _filteredBrands;
      }
    } finally {
      _brandsLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> _ensureSubCategoriesLoadedForBrands() async {
    if (_allSubCategories.isEmpty) {
      await getAllSubCategories(showSnack: false);
    }
  }

  void _applyBrandFilter() {
    _sortAllBrands();

    final kw = _brandKeyword.trim().toLowerCase();
    if (kw.isEmpty) {
      _filteredBrands = List<Brand>.from(_allBrands);
      return;
    }

    _filteredBrands = _allBrands
        .where((b) => (b.name ?? '').toLowerCase().contains(kw))
        .toList()
      ..sort((a, b) => _brandTs(b).compareTo(_brandTs(a)));
  }


// ================================
// ✅ SubCategory cache for Brands hydration
// ================================


// ================================
// ✅ POSTERS (Paging + Shimmer)
// ================================

// --- Sort helper: newest updatedAt/createdAt first ---
  DateTime _posterTs(Poster p) {
    final u = (p.updatedAt ?? '').trim();
    final c = (p.createdAt ?? '').trim();
    final raw = u.isNotEmpty ? u : c;
    final dt = DateTime.tryParse(raw);
    return dt ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _sortAllPosters() {
    _allPosters.sort((a, b) => _posterTs(b).compareTo(_posterTs(a))); // DESC
  }

  /// ✅ create/update => بیاد اول (بدون نیاز به reload)
  void upsertPosterToTop(Poster incoming) {
    final id = (incoming.sId ?? '').trim();
    if (id.isEmpty) return;

    // اگر updatedAt از سرور نیومده بود، برای نمایش درست
    incoming.updatedAt ??= DateTime.now().toIso8601String();

    final idx = _allPosters.indexWhere((x) => (x.sId ?? '').trim() == id);
    if (idx != -1) _allPosters.removeAt(idx);

    _allPosters.insert(0, incoming);

    _applyPosterFilter();
    notifyListeners();
  }

  static const int _postersPageSize = 500;

  bool _postersLoading = false;
  bool _postersLoadingMore = false;
  bool _postersHasMore = true;

  String? _postersCursorAfter;
  String _posterKeyword = '';

  bool get isPostersLoading => _postersLoading;
  bool get isPostersLoadingMore => _postersLoadingMore;
  bool get hasMorePosters => _postersHasMore;

  Future<List<Poster>> getAllPosters({bool showSnack = false}) async {
    return loadInitialPosters(showSnack: showSnack);
  }

  Future<List<Poster>> loadInitialPosters({bool showSnack = false}) async {
    if (_postersLoading) return _filteredPosters;

    _postersLoading = true;
    _postersLoadingMore = false;
    _postersHasMore = true;
    _postersCursorAfter = null;

    _allPosters.clear();
    _filteredPosters = const [];
    notifyListeners();

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
      if (phone.trim().isEmpty) {
        if (showSnack) SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredPosters;
      }

      final res = await _posterService.getPagedByPhoneNumberCode(
        phone.trim(),
        limit: _postersPageSize,
        cursorAfter: null,
      );

      if (res.isSuccess) {
        final items = res.requireData();

        _allPosters.addAll(items);

        _postersHasMore = items.length >= _postersPageSize;
        _postersCursorAfter =
        _postersHasMore && items.isNotEmpty ? items.last.sId : null;

        _applyPosterFilter();
        if (showSnack) SnackBarHelper.showSuccessSnackBar('پوسترها لود شدند');
        return _filteredPosters;
      } else {
        final err = res.requireError();
        if (showSnack) SnackBarHelper.showErrorSnackBar(err.userMessage);
        return _filteredPosters;
      }
    } finally {
      _postersLoading = false;
      notifyListeners();
    }
  }

  Future<List<Poster>> loadMorePosters({bool showSnack = false}) async {
    if (_postersLoading || _postersLoadingMore || !_postersHasMore) {
      return _filteredPosters;
    }

    _postersLoadingMore = true;
    notifyListeners();

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
      if (phone.trim().isEmpty) return _filteredPosters;

      final res = await _posterService.getPagedByPhoneNumberCode(
        phone.trim(),
        limit: _postersPageSize,
        cursorAfter: _postersCursorAfter,
      );

      if (res.isSuccess) {
        final items = res.requireData();

        if (items.isEmpty) {
          _postersHasMore = false;
          return _filteredPosters;
        }

        // upsert + جلوگیری از تکرار
        for (final p in items) {
          final id = (p.sId ?? '').trim();
          if (id.isEmpty) continue;

          final idx = _allPosters.indexWhere((x) => (x.sId ?? '').trim() == id);
          if (idx == -1) {
            _allPosters.add(p);
          } else {
            _allPosters[idx] = p;
          }
        }

        _postersHasMore = items.length >= _postersPageSize;
        _postersCursorAfter = _postersHasMore ? items.last.sId : null;

        _applyPosterFilter();
        return _filteredPosters;
      } else {
        final err = res.requireError();
        if (showSnack) SnackBarHelper.showErrorSnackBar(err.userMessage);
        return _filteredPosters;
      }
    } finally {
      _postersLoadingMore = false;
      notifyListeners();
    }
  }

  void filterPosters(String keyword) {
    _posterKeyword = keyword.trim();
    _applyPosterFilter();
    notifyListeners();
  }

  void _applyPosterFilter() {
    _sortAllPosters();

    final kw = _posterKeyword.trim().toLowerCase();
    if (kw.isEmpty) {
      _filteredPosters = List<Poster>.from(_allPosters);
      return;
    }

    _filteredPosters = _allPosters
        .where((p) => (p.posterName ?? '').toLowerCase().contains(kw))
        .toList()
      ..sort((a, b) => _posterTs(b).compareTo(_posterTs(a)));
  }

  // ================================
// ✅ VARIANTS (Paging + Shimmer + Hydration by VariantTypes)
// ================================
  static const int _variantsPageSize = 500;

  bool _variantsLoading = false;
  bool _variantsLoadingMore = false;
  bool _variantsHasMore = true;

  String? _variantsCursorAfter;
  String _variantKeyword = '';

  bool get isVariantsLoading => _variantsLoading;
  bool get isVariantsLoadingMore => _variantsLoadingMore;
  bool get hasMoreVariants => _variantsHasMore;

// cache برای map کردن نام تایپ‌ها
  Map<String, VariantType> _vtMapForVariants = {};
  String? _vtMapPhoneForVariants;

  Future<void> _ensureVariantTypeMapForVariants(String phone) async {
    if (_vtMapPhoneForVariants == phone && _vtMapForVariants.isNotEmpty) return;

    final allVts = await _getVariantTypesForHydration(phone);
    final map = <String, VariantType>{};
    for (final vt in allVts) {
      final id = (vt.sId ?? '').trim();
      if (id.isNotEmpty) map[id] = vt;
    }

    _vtMapForVariants = map;
    _vtMapPhoneForVariants = phone;
  }

  void _hydrateVariantsTypeNames(List<Variant> vars) {
    if (_vtMapForVariants.isEmpty) return;

    for (final v in vars) {
      final vtId = (v.variantType ?? v.variantTypeId?.sId ?? '').trim();
      if (vtId.isEmpty) continue;

      final vt = _vtMapForVariants[vtId];
      if (vt == null) continue;

      v.variantTypeId = VariantTypeId(
        sId: vt.sId,
        name: vt.name,
        type: vt.type,
      );
    }
  }

  Future<List<Variant>> getAllVariants({bool showSnack = false}) async {
    return loadInitialVariants(showSnack: showSnack);
  }

  Future<List<Variant>> loadInitialVariants({bool showSnack = false}) async {
    if (_variantsLoading) return _filteredVariants;

    _variantsLoading = true;
    _variantsLoadingMore = false;
    _variantsHasMore = true;
    _variantsCursorAfter = null;

    _allVariants.clear();
    _filteredVariants = const [];
    notifyListeners();

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
      if (phone.trim().isEmpty) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('شماره تلفن/کد در حافظه یافت نشد!');
        }
        return _filteredVariants;
      }

      // ✅ برای اینکه اسم تایپ‌ها همیشه درست hydrate بشه (حتی اگر VariantTypes صفحه‌بندی شده باشد)
      await _ensureVariantTypeMapForVariants(phone.trim());

      final res = await variantsRepoAppwrite.getPagedByPhoneNumberCode(
        phone.trim(),
        limit: _variantsPageSize,
        cursorAfter: null,
      );

      if (res.isSuccess) {
        final items = res.requireData();

        _hydrateVariantsTypeNames(items);

        _allVariants.addAll(items);

        _variantsHasMore = items.length >= _variantsPageSize;
        _variantsCursorAfter =
        _variantsHasMore && items.isNotEmpty ? items.last.sId : null;

        _applyVariantFilter();
        if (showSnack) SnackBarHelper.showSuccessSnackBar('Variants loaded');
        return _filteredVariants;
      } else {
        final err = res.requireError();
        if (showSnack) SnackBarHelper.showErrorSnackBar(err.userMessage);
        return _filteredVariants;
      }
    } finally {
      _variantsLoading = false;
      notifyListeners();
    }
  }

  Future<List<Variant>> loadMoreVariants({bool showSnack = false}) async {
    if (_variantsLoading || _variantsLoadingMore || !_variantsHasMore) {
      return _filteredVariants;
    }

    _variantsLoadingMore = true;
    notifyListeners();

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
      if (phone.trim().isEmpty) return _filteredVariants;

      await _ensureVariantTypeMapForVariants(phone.trim());

      final res = await variantsRepoAppwrite.getPagedByPhoneNumberCode(
        phone.trim(),
        limit: _variantsPageSize,
        cursorAfter: _variantsCursorAfter,
      );

      if (res.isSuccess) {
        final items = res.requireData();

        if (items.isEmpty) {
          _variantsHasMore = false;
          return _filteredVariants;
        }

        _hydrateVariantsTypeNames(items);

        // upsert + جلوگیری از تکرار
        for (final v in items) {
          final id = (v.sId ?? '').trim();
          if (id.isEmpty) continue;

          final idx = _allVariants.indexWhere((x) => (x.sId ?? '').trim() == id);
          if (idx == -1) {
            _allVariants.add(v);
          } else {
            _allVariants[idx] = v;
          }
        }

        _variantsHasMore = items.length >= _variantsPageSize;
        _variantsCursorAfter = _variantsHasMore ? items.last.sId : null;

        _applyVariantFilter();
        return _filteredVariants;
      } else {
        final err = res.requireError();
        if (showSnack) SnackBarHelper.showErrorSnackBar(err.userMessage);
        return _filteredVariants;
      }
    } finally {
      _variantsLoadingMore = false;
      notifyListeners();
    }
  }

// ✅ فیلتر (مثل بقیه paging ها)
  void filterVariants(String keyword) {
    _variantKeyword = keyword.trim();
    _applyVariantFilter();
    notifyListeners();
  }

  void _applyVariantFilter() {
    final kw = _variantKeyword.trim().toLowerCase();
    if (kw.isEmpty) {
      _filteredVariants = List<Variant>.from(_allVariants);
      return;
    }

    _filteredVariants = _allVariants
        .where((v) => (v.name ?? '').toLowerCase().contains(kw))
        .toList();
  }

// ================================
// ✅ VARIANT TYPES (Paging + Shimmer + Updated items first)
// ================================
  static const int _variantTypesPageSize = 500;

  bool _variantTypesLoading = false;
  bool _variantTypesLoadingMore = false;
  bool _variantTypesHasMore = true;

  String? _variantTypesCursorAfter;
  String _variantTypeKeyword = '';

  bool get isVariantTypesLoading => _variantTypesLoading;
  bool get isVariantTypesLoadingMore => _variantTypesLoadingMore;
  bool get hasMoreVariantTypes => _variantTypesHasMore;

// --- Sort helper: newest updatedAt/createdAt first ---
  DateTime _vtTs(VariantType v) {
    final u = (v.updatedAt ?? '').trim();
    final c = (v.createdAt ?? '').trim();
    final raw = u.isNotEmpty ? u : c;
    final dt = DateTime.tryParse(raw);
    return dt ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _sortAllVariantTypes() {
    _allVariantTypes.sort((a, b) => _vtTs(b).compareTo(_vtTs(a))); // DESC
  }

  /// ✅ create/update => بیاد اول (بدون نیاز به reload)
  void upsertVariantTypeToTop(VariantType incoming) {
    final id = (incoming.sId ?? '').trim();
    if (id.isEmpty) return;

    // اگر updatedAt از سرور نیومده بود، برای نمایش درست
    incoming.updatedAt ??= DateTime.now().toIso8601String();

    final idx = _allVariantTypes.indexWhere((x) => (x.sId ?? '').trim() == id);
    if (idx != -1) _allVariantTypes.removeAt(idx);

    _allVariantTypes.insert(0, incoming);

    _applyVariantTypeFilter();
    notifyListeners();
  }

  Future<List<VariantType>> getAllVariantTypes({bool showSnack = false}) async {
    return loadInitialVariantTypes(showSnack: showSnack);
  }

  Future<List<VariantType>> loadInitialVariantTypes({bool showSnack = false}) async {
    if (_variantTypesLoading) return _filteredVariantTypes;

    _variantTypesLoading = true;
    _variantTypesLoadingMore = false;
    _variantTypesHasMore = true;
    _variantTypesCursorAfter = null;

    _allVariantTypes.clear();
    _filteredVariantTypes = const [];
    notifyListeners();

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
      if (phone.trim().isEmpty) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('شماره تلفن/کد در حافظه یافت نشد!');
        }
        return _filteredVariantTypes;
      }

      final res = await variantTypesRepoAppwrite.getPagedByPhoneNumberCode(
        phone.trim(),
        limit: _variantTypesPageSize,
        cursorAfter: null,
      );

      if (res.isSuccess) {
        final items = res.requireData();

        _allVariantTypes.addAll(items);

        _variantTypesHasMore = items.length >= _variantTypesPageSize;
        _variantTypesCursorAfter =
        _variantTypesHasMore && items.isNotEmpty ? items.last.sId : null;

        _applyVariantTypeFilter();
        if (showSnack) SnackBarHelper.showSuccessSnackBar('Variant types loaded');
        return _filteredVariantTypes;
      } else {
        final err = res.requireError();
        if (showSnack) SnackBarHelper.showErrorSnackBar(err.userMessage);
        return _filteredVariantTypes;
      }
    } finally {
      _variantTypesLoading = false;
      notifyListeners();
    }
  }

  Future<List<VariantType>> loadMoreVariantTypes({bool showSnack = false}) async {
    if (_variantTypesLoading || _variantTypesLoadingMore || !_variantTypesHasMore) {
      return _filteredVariantTypes;
    }

    _variantTypesLoadingMore = true;
    notifyListeners();

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
      if (phone.trim().isEmpty) return _filteredVariantTypes;

      final res = await variantTypesRepoAppwrite.getPagedByPhoneNumberCode(
        phone.trim(),
        limit: _variantTypesPageSize,
        cursorAfter: _variantTypesCursorAfter,
      );

      if (res.isSuccess) {
        final items = res.requireData();

        if (items.isEmpty) {
          _variantTypesHasMore = false;
          return _filteredVariantTypes;
        }

        // upsert + جلوگیری از تکرار
        for (final vt in items) {
          final id = (vt.sId ?? '').trim();
          if (id.isEmpty) continue;

          final idx = _allVariantTypes.indexWhere((x) => (x.sId ?? '').trim() == id);
          if (idx == -1) {
            _allVariantTypes.add(vt);
          } else {
            _allVariantTypes[idx] = vt;
          }
        }

        _variantTypesHasMore = items.length >= _variantTypesPageSize;
        _variantTypesCursorAfter = _variantTypesHasMore ? items.last.sId : null;

        _applyVariantTypeFilter();
        return _filteredVariantTypes;
      } else {
        final err = res.requireError();
        if (showSnack) SnackBarHelper.showErrorSnackBar(err.userMessage);
        return _filteredVariantTypes;
      }
    } finally {
      _variantTypesLoadingMore = false;
      notifyListeners();
    }
  }

  void filterVariantTypes(String keyword) {
    _variantTypeKeyword = keyword.trim();
    _applyVariantTypeFilter();
    notifyListeners();
  }

  void _applyVariantTypeFilter() {
    _sortAllVariantTypes();

    final kw = _variantTypeKeyword.trim().toLowerCase();
    if (kw.isEmpty) {
      _filteredVariantTypes = List<VariantType>.from(_allVariantTypes);
      return;
    }

    _filteredVariantTypes = _allVariantTypes
        .where((v) => (v.name ?? '').toLowerCase().contains(kw))
        .toList()
      ..sort((a, b) => _vtTs(b).compareTo(_vtTs(a)));
  }

  /// ✅ برای اینکه mapping داخل getAllVariants خراب نشه (اگر VariantTypes صفحه‌بندی شد)
  Future<List<VariantType>> _getVariantTypesForHydration(String phone) async {
    final res = await variantTypesRepoAppwrite.getByPhoneNumberCode(phone);
    if (res.isSuccess) return res.requireData();
    return _allVariantTypes;
  }

// ================================
// ✅ VARIANT TYPES (Paging + Shimmer + Updated items first)
// ================================


// ================================
// ✅ SUBCATEGORIES (Paging + Updated items first)
// ================================
  static const int _subCategoriesPageSize = 500;

  bool _subCategoriesLoading = false;
  bool _subCategoriesLoadingMore = false;
  bool _subCategoriesHasMore = true;

  String? _subCategoriesCursorAfter;
  String _subCategoryKeyword = '';

  bool get isSubCategoriesLoading => _subCategoriesLoading;
  bool get isSubCategoriesLoadingMore => _subCategoriesLoadingMore;
  bool get hasMoreSubCategories => _subCategoriesHasMore;

// --- Sort helper: newest updatedAt/createdAt first ---
  DateTime _subTs(SubCategory s) {
    final raw = (s.updatedAt ?? '').trim().isNotEmpty ? s.updatedAt! : (s.createdAt ?? '');
    final dt = DateTime.tryParse(raw);
    return dt ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _sortAllSubCategories() {
    _allSubCategories.sort((a, b) => _subTs(b).compareTo(_subTs(a))); // DESC
  }

// ✅ ایجاد یا بروزرسانی زیر‌دسته و آوردن به اول (با مرتب‌سازی بر اساس updatedAt)
  void upsertSubCategoryToTop(SubCategory incoming) {
    final id = (incoming.sId ?? '').trim();
    if (id.isEmpty) return;

    // اگر updatedAt از سرور نیومده بود، برای نمایش درست، همین‌جا ست می‌کنیم
    incoming.updatedAt ??= DateTime.now().toIso8601String();

    final idx = _allSubCategories.indexWhere((x) => (x.sId ?? '').trim() == id);
    if (idx != -1) _allSubCategories.removeAt(idx);

    _allSubCategories.insert(0, incoming);

    _applySubCategoryFilter(); // داخلش sort هم انجام میشه
    notifyListeners();
  }

// ✅ (اختیاری ولی کاربردی) create/update که خودش بعد از موفقیت میاره اول
  Future<void> createSubCategory({
    required String name,
    required String categoryId,
    bool showSnack = false,
  }) async {
    final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
    if (phone.trim().isEmpty) {
      if (showSnack) SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
      return;
    }

    final res = await _subCategoryService.createSubCategory(
      name: name.trim(),
      phoneNumberCode: phone.trim(),
      categoryId: categoryId,
    );

    if (res.isSuccess) {
      final saved = res.requireData();
      upsertSubCategoryToTop(saved);
      if (showSnack) SnackBarHelper.showSuccessSnackBar('Subcategory created');
    } else {
      if (showSnack) SnackBarHelper.showErrorSnackBar(res.requireError().userMessage);
    }
  }

  Future<void> updateSubCategory({
    required String documentId,
    required String name,
    required String categoryId,
    bool showSnack = false,
  }) async {
    final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
    if (phone.trim().isEmpty) {
      if (showSnack) SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
      return;
    }

    final res = await _subCategoryService.updateSubCategory(
      documentId: documentId,
      name: name.trim(),
      phoneNumberCode: phone.trim(),
      categoryId: categoryId,
    );

    if (res.isSuccess) {
      final saved = res.requireData();
      upsertSubCategoryToTop(saved); // ✅ همین باعث میشه آپدیت بیاد اول
      if (showSnack) SnackBarHelper.showSuccessSnackBar('Subcategory updated');
    } else {
      if (showSnack) SnackBarHelper.showErrorSnackBar(res.requireError().userMessage);
    }
  }

  Future<void> deleteSubCategory(SubCategory sub, {bool showSnack = false}) async {
    final id = (sub.sId ?? '').trim();
    if (id.isEmpty) return;

    final res = await _subCategoryService.deleteSubCategory(documentId: id);
    if (res.isSuccess) {
      _allSubCategories.removeWhere((x) => (x.sId ?? '').trim() == id);
      _applySubCategoryFilter();
      notifyListeners();
      if (showSnack) SnackBarHelper.showSuccessSnackBar('Subcategory deleted');
    } else {
      if (showSnack) SnackBarHelper.showErrorSnackBar(res.requireError().userMessage);
    }
  }

// ✅ لود اولیه
  Future<List<SubCategory>> getAllSubCategories({bool showSnack = false}) async {
    return loadInitialSubCategories(showSnack: showSnack);
  }

  Future<List<SubCategory>> loadInitialSubCategories({bool showSnack = false}) async {
    if (_subCategoriesLoading) return _filteredSubCategories;

    _subCategoriesLoading = true;
    _subCategoriesLoadingMore = false;
    _subCategoriesHasMore = true;
    _subCategoriesCursorAfter = null;

    _allSubCategories.clear();
    _filteredSubCategories = const [];
    notifyListeners();

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
      if (phone.trim().isEmpty) {
        if (showSnack) SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredSubCategories;
      }

      final result = await _subCategoryService.getPagedByPhoneNumberCode(
        phone.trim(),
        limit: _subCategoriesPageSize,
        cursorAfter: null,
      );

      if (result.isSuccess) {
        final items = result.requireData();
        _allSubCategories.addAll(items);

        _subCategoriesHasMore = items.length >= _subCategoriesPageSize;
        _subCategoriesCursorAfter =
        _subCategoriesHasMore ? (items.isNotEmpty ? items.last.sId : null) : null;

        _applySubCategoryFilter(); // ✅ includes sort (updated first)
        notifyListeners();

        if (showSnack) SnackBarHelper.showSuccessSnackBar('Subcategories loaded');
        return _filteredSubCategories;
      } else {
        final err = result.requireError();
        if (showSnack) SnackBarHelper.showErrorSnackBar(err.userMessage);
        return _filteredSubCategories;
      }
    } finally {
      _subCategoriesLoading = false;
      notifyListeners();
    }
  }

// ✅ لود بیشتر (Paging)
  Future<List<SubCategory>> loadMoreSubCategories({bool showSnack = false}) async {
    if (_subCategoriesLoading || _subCategoriesLoadingMore || !_subCategoriesHasMore) {
      return _filteredSubCategories;
    }

    _subCategoriesLoadingMore = true;
    notifyListeners();

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
      if (phone.trim().isEmpty) return _filteredSubCategories;

      final result = await _subCategoryService.getPagedByPhoneNumberCode(
        phone.trim(),
        limit: _subCategoriesPageSize,
        cursorAfter: _subCategoriesCursorAfter,
      );

      if (result.isSuccess) {
        final items = result.requireData();

        if (items.isEmpty) {
          _subCategoriesHasMore = false;
          return _filteredSubCategories;
        }

        // upsert (بدون تغییر ترتیب دستی؛ ترتیب با sort درست میشه)
        for (final s in items) {
          final id = (s.sId ?? '').trim();
          if (id.isEmpty) continue;

          final idx = _allSubCategories.indexWhere((x) => (x.sId ?? '').trim() == id);
          if (idx == -1) {
            _allSubCategories.add(s);
          } else {
            _allSubCategories[idx] = s;
          }
        }

        _subCategoriesHasMore = items.length >= _subCategoriesPageSize;
        _subCategoriesCursorAfter = _subCategoriesHasMore ? items.last.sId : null;

        _applySubCategoryFilter(); // ✅ includes sort (updated first)
        return _filteredSubCategories;
      } else {
        final err = result.requireError();
        if (showSnack) SnackBarHelper.showErrorSnackBar(err.userMessage);
        return _filteredSubCategories;
      }
    } finally {
      _subCategoriesLoadingMore = false;
      notifyListeners();
    }
  }

// ✅ فیلتر
  void filterSubCategories(String keyword) {
    _subCategoryKeyword = keyword.trim();
    _applySubCategoryFilter();
    notifyListeners();
  }

// ✅ اعمال فیلتر + مرتب‌سازی (آپدیت‌ها اول)
  void _applySubCategoryFilter() {
    _sortAllSubCategories();

    final kw = _subCategoryKeyword.trim().toLowerCase();
    if (kw.isEmpty) {
      _filteredSubCategories = List<SubCategory>.from(_allSubCategories);
      return;
    }

    _filteredSubCategories = _allSubCategories
        .where((s) => (s.name ?? '').toLowerCase().contains(kw))
        .toList()
      ..sort((a, b) => _subTs(b).compareTo(_subTs(a))); // برای حالت فیلتر هم
  }



  // داخل DataProvider

// ================================
// ✅ SUBCATEGORIES PAGING (Appwrite)
// ================================


  //////////////////////////////////category
  Future<List<Category>> getAllCategories({bool showSnack = false}) async {
    return loadInitialCategories(showSnack: showSnack);
  }

  Future<List<Category>> loadInitialCategories({bool showSnack = false}) async {
    if (_categoriesLoading) return _filteredCategories;

    _categoriesLoading = true;
    _categoriesLoadingMore = false;
    _categoriesHasMore = true;
    _categoriesCursorAfter = null;

    _allCategories.clear();
    _filteredCategories = const [];
    notifyListeners();

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
      if (phone.trim().isEmpty) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        }
        return _filteredCategories;
      }

      final result = await categoriesRepoAppwrite.getPagedByPhoneNumberCode(
        phone.trim(),
        limit: _categoriesPageSize,
        cursorAfter: null,
      );

      if (result.isSuccess) {
        final items = result.requireData();

        _allCategories.addAll(items);

        _categoriesHasMore = items.length >= _categoriesPageSize;
        _categoriesCursorAfter =
        _categoriesHasMore ? (items.isNotEmpty ? items.last.sId : null) : null;

        _applyCategoryFilter();
        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar('دسته‌بندی‌ها بروزرسانی شدند');
        }

        return _filteredCategories;
      } else {
        final error = result.requireError();
        if (showSnack) SnackBarHelper.showErrorSnackBar(error.userMessage);
        return _filteredCategories;
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar('خطا در لود دسته‌بندی‌ها: $e');
      rethrow;
    } finally {
      _categoriesLoading = false;
      notifyListeners();
    }
  }

  Future<List<Category>> loadMoreCategories({bool showSnack = false}) async {
    if (_categoriesLoading || _categoriesLoadingMore || !_categoriesHasMore) {
      return _filteredCategories;
    }

    _categoriesLoadingMore = true;
    notifyListeners();

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
      if (phone.trim().isEmpty) return _filteredCategories;

      final result = await categoriesRepoAppwrite.getPagedByPhoneNumberCode(
        phone.trim(),
        limit: _categoriesPageSize,
        cursorAfter: _categoriesCursorAfter,
      );

      if (result.isSuccess) {
        final items = result.requireData();

        if (items.isEmpty) {
          _categoriesHasMore = false;
          return _filteredCategories;
        }

        // جلوگیری از تکرار (simple)
        for (final c in items) {
          final id = (c.sId ?? '').trim();
          if (id.isEmpty) continue;

          final idx = _allCategories.indexWhere((x) => (x.sId ?? '') == id);
          if (idx == -1) {
            _allCategories.add(c);
          } else {
            _allCategories[idx] = c;
          }
        }

        _categoriesHasMore = items.length >= _categoriesPageSize;
        _categoriesCursorAfter = _categoriesHasMore ? items.last.sId : null;

        _applyCategoryFilter();
        return _filteredCategories;
      } else {
        final err = result.requireError();
        if (showSnack) SnackBarHelper.showErrorSnackBar(err.userMessage);
        return _filteredCategories;
      }
    } finally {
      _categoriesLoadingMore = false;
      notifyListeners();
    }
  }

  void filterCategories(String keyword) {
    _categoryKeyword = keyword.trim();
    _applyCategoryFilter();
    notifyListeners();
  }

  void _applyCategoryFilter() {
    final kw = _categoryKeyword.trim().toLowerCase();
    if (kw.isEmpty) {
      _filteredCategories = List<Category>.from(_allCategories);
      return;
    }

    _filteredCategories = _allCategories
        .where((c) => (c.name ?? '').toLowerCase().contains(kw))
        .toList();
  }

  // ================================
// ✅ CATEGORIES PAGING (Appwrite)
// ================================
  static const int _categoriesPageSize = 500;

  bool _categoriesLoading = false;
  bool _categoriesLoadingMore = false;
  bool _categoriesHasMore = true;

  String? _categoriesCursorAfter;
  String _categoryKeyword = '';

  bool get isCategoriesLoading => _categoriesLoading;
  bool get isCategoriesLoadingMore => _categoriesLoadingMore;
  bool get hasMoreCategories => _categoriesHasMore;


// ================================
// ✅ BRANDS PAGING (Appwrite)
// ================================



// ================================
// ✅ ORDERS SECTION (Appwrite)
// ================================

  final OrdersAppwriteService ordersAppwriteService = OrdersAppwriteService();
  RealtimeSubscription? _ordersSub;

  Timer? _notifyDebounce;
  void _safeNotify() {
    _notifyDebounce?.cancel();
    _notifyDebounce = Timer(const Duration(milliseconds: 120), () {
      notifyListeners();
    });
  }

  bool _isPaidStatus(String? s) => (s ?? '').trim().toLowerCase() == 'paid';

// --- In Progress (Dashboard) ---
  final List<Order> _allsOrders = [];
  List<Order> _filteredOrdersall = [];
  List<Order> get allsOrders => _filteredOrdersall;

// --- Paid (Orders page, pagination) ---
  final int _ordersPageSize = 500;
  int _ordersPage = 1;
  bool _ordersHasMore = true;
  bool _ordersLoading = false;

  bool get isOrdersLoading => _ordersLoading;
  bool get hasMoreOrders => _ordersHasMore;

  final List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  List<Order> get orders => _filteredOrders;

// اگر menu_type == menu_one باشد، بخش سفارش‌ها غیرفعال است
  Future<bool> _isOrdersEnabled() async {
    try {
      final info = await UserSaveHelper.getUserInfo(showError: false);
      final menuType = (info?['menu_type'] ?? '').toString().trim().toLowerCase();
      return menuType != 'menu_one';
    } catch (_) {
      return true;
    }
  }
  // Future<void> initOrdersRealtime() async {
  //   await disposeOrdersRealtime();
  //   try {
  //     final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
  //     if (phone.trim().isEmpty) return;
  //
  //     print('Trying to connect to Appwrite Realtime...');
  //     _ordersSub = ordersAppwriteService.subscribeOrders((msg) {
  //       print('✅ Realtime message received: ${msg.events}');
  //       _applyOrdersRealtime(msg, phoneNumberCode: phone.trim());
  //     });
  //     print('Realtime subscription created');
  //   } catch (e) {
  //     print('❌ Failed to init realtime: $e');
  //   }
  // }
  Future<void> _bootOrders() async {
    if (!await _isOrdersEnabled()) {
      await disposeOrdersPolling();
      await disposeOrdersRealtime();
      return;
    }

    // همیشه اول سفارشات در جریان رو لود کن
    await getAllsOrders(showSnack: false);
    await getAllCoupons();

    // اول هر دو رو ببند (برای اطمینان کامل)
    await disposeOrdersRealtime();
    await disposeOrdersPolling();

    if (kIsWeb) {
      print('Flutter Web detected → using Polling only');
      await initOrdersPolling();
    } else {
      print('Native platform detected → using Realtime');
      // await initOrdersRealtime();
    }
  }
  Timer? _pollingTimer;

// جایگزین initOrdersRealtime با این متد
  Future<void> initOrdersPolling() async {
    await disposeOrdersPolling(); // اگر قبلاً فعال بود

    // هر ۱۰ ثانیه سفارشات در جریان رو رفرش کن
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        await getAllsOrders(showSnack: false);
        // اگر صفحه Paid بازه، اونم رفرش کن (اختیاری)
        // if (currentRoute == '/orders_paid') await loadMoreOrders();
      } catch (e) {
        print('Polling error: $e');
      }
    });

    // اولین بار هم لود کن
    await getAllsOrders(showSnack: false);
  }

  Future<void> disposeOrdersPolling() async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
// -------------------------------
// ✅ Dashboard: دریافت همه سفارشات در جریان (بدون پیجین)
// -------------------------------
  Future<List<Order>> getAllsOrders({bool showSnack = false}) async {
    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
      if (phone.trim().isEmpty) {
        if (showSnack) SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _allsOrders;
      }

      final data = await ordersAppwriteService.fetchAllInProgress(

        phoneNumberCode: phone.trim(),
        batchSize: 200,

      );

      _allsOrders
        ..clear()
        ..addAll(data);

      _filteredOrdersall = List.unmodifiable(_allsOrders);

      notifyListeners();
      if (showSnack) SnackBarHelper.showSuccessSnackBar('Orders (in progress) loaded');
      return _allsOrders;
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar('Failed to load in-progress orders: $e');
      rethrow;
    }
  }

// -------------------------------
// ✅ Paid Orders: Pagination
// -------------------------------
  Future<List<Order>> loadInitialOrders({bool showSnack = false}) async {
    if (_ordersLoading) return _filteredOrders;
    _ordersPage = 1;
    _ordersHasMore = true;
    _allOrders.clear();
    _filteredOrders = const [];
    notifyListeners();
    return _fetchPaidOrdersPage(_ordersPage, showSnack: showSnack);
  }

  Future<List<Order>> loadMoreOrders({bool showSnack = false}) async {
    if (_ordersLoading || !_ordersHasMore) return _filteredOrders;
    _ordersPage += 1;
    return _fetchPaidOrdersPage(_ordersPage, showSnack: showSnack);
  }

  Future<List<Order>> _fetchPaidOrdersPage(int page, {bool showSnack = false}) async {
    if (_ordersLoading) return _filteredOrders;
    _ordersLoading = true;
    notifyListeners();

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
      if (phone.trim().isEmpty) {
        if (showSnack) SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredOrders;
      }

      final res = await ordersAppwriteService.fetchPaidPaged(
        phoneNumberCode: phone.trim(),
        page: page,
        perPage: _ordersPageSize,
      );

      if (page == 1) _allOrders.clear();
      _allOrders.addAll(res.orders);
      _filteredOrders = List.unmodifiable(_allOrders);
      _ordersHasMore = res.hasMore;

      if (showSnack) SnackBarHelper.showSuccessSnackBar('Paid orders loaded');
      return _filteredOrders;
    } catch (e) {
      if (_ordersPage > 1) _ordersPage -= 1;
      if (showSnack) SnackBarHelper.showErrorSnackBar('Failed to load paid orders: $e');
      rethrow;
    } finally {
      _ordersLoading = false;
      notifyListeners();
    }
  }

// -------------------------------
// ✅ Realtime (Appwrite)
// -------------------------------


  void _applyOrdersRealtime(RealtimeMessage msg, {required String phoneNumberCode}) {
    try {
      // ✅ مهم: payload ممکن است String باشد (JSON encoded)
      dynamic payload = msg.payload;

      if (payload is String) {
        try {
          payload = jsonDecode(payload);
        } catch (_) {
          return; // اگر JSON معتبر نبود، نادیده بگیر
        }
      }

      if (payload is! Map<String, dynamic>) {
        return;
      }

      final doc = Map<String, dynamic>.from(payload);

      // نرمال‌سازی متا
      final normalized = <String, dynamic>{
        ...doc,
        'id': doc['id'] ?? doc[r'$id'],
        'created': doc['created'] ?? doc[r'$createdAt'],
      };

      final order = Order.fromJson(normalized);

      // فیلتر tenant
      final p = (order.phoneNumberCode ?? '').trim();
      if (p.isNotEmpty && p != phoneNumberCode) return;

      final id = (order.sId ?? '').trim();
      if (id.isEmpty) return;

      final action = _actionFromEvents(msg.events);

      if (action == 'delete') {
        _removeOrderFromList(_allsOrders, id);
        _removeOrderFromList(_allOrders, id);
      } else if (action == 'create' || action == 'update') {
        if (_isPaidStatus(order.orderStatus)) {
          _removeOrderFromList(_allsOrders, id);
          final idx = _allOrders.indexWhere((o) => (o.sId ?? '') == id);
          if (idx >= 0) {
            _allOrders[idx] = order;
          } else if (_ordersPage <= 1) {
            _allOrders.insert(0, order);
          }
        } else {
          _upsertOrderInList(_allsOrders, order);
          _removeOrderFromList(_allOrders, id);
        }
      }

      _filteredOrdersall = List.unmodifiable(_allsOrders);
      _filteredOrders = List.unmodifiable(_allOrders);
      _safeNotify();
    } catch (e, st) {
      // لاگ خطا (اختیاری)
      print('Error in realtime handler: $e\n$st');
    }
  }

  // Future<void> initOrdersRealtime() async {
  //   await disposeOrdersRealtime();
  //
  //   try {
  //     final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
  //     if (phone.trim().isEmpty) return;
  //
  //     _ordersSub = ordersAppwriteService.subscribeOrders((msg) {
  //       _applyOrdersRealtime(msg, phoneNumberCode: phone.trim());
  //     });
  //   } catch (_) {}
  // }
  // Future<void> initOrdersRealtime() async {
  //   await disposeOrdersRealtime();
  //   try {
  //     final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
  //     if (phone.trim().isEmpty) return;
  //
  //     print('Trying to connect to Appwrite Realtime...');
  //     _ordersSub = ordersAppwriteService.subscribeOrders((msg) {
  //       print('✅ Realtime message received: ${msg.events}');
  //       _applyOrdersRealtime(msg, phoneNumberCode: phone.trim());
  //     });
  //     print('Realtime subscription created');
  //   } catch (e) {
  //     print('❌ Failed to init realtime: $e');
  //   }
  // }
  Future<void> disposeOrdersRealtime() async {
    try {
      await _ordersSub?.close();
      _ordersSub = null;
    } catch (_) {}
  }

  String _actionFromEvents(List<String> events) {
    if (events.any((e) => e.endsWith('.delete'))) return 'delete';
    if (events.any((e) => e.endsWith('.create'))) return 'create';
    if (events.any((e) => e.endsWith('.update'))) return 'update';
    return 'unknown';
  }


  void _upsertOrderInList(List<Order> list, Order incoming) {
    final incomingId = (incoming.sId ?? '').toString();
    final idx = list.indexWhere((o) => (o.sId ?? '').toString() == incomingId);
    if (idx == -1) {
      list.insert(0, incoming);
    } else {
      list[idx] = incoming;
    }
  }

  void _removeOrderFromList(List<Order> list, String id) {
    list.removeWhere((o) => (o.sId ?? '').toString() == id);
  }

// -------------------------------
// ✅ Filters/Search
// -------------------------------
  void filterAllOrders(String status) {
    if (status == ORDER_STATUS_ALL || status.isEmpty) {
      _filteredOrdersall = List.unmodifiable(_allsOrders);
    } else {
      final s = status.toLowerCase();
      _filteredOrdersall = List.unmodifiable(
        _allsOrders.where((o) => (o.orderStatus ?? '').toLowerCase() == s),
      );
    }
    notifyListeners();
  }

  void searchAllOrders(String query) {
    if (query.isEmpty) {
      _filteredOrdersall = List.unmodifiable(_allsOrders);
    } else {
      final q = query.toLowerCase();
      _filteredOrdersall = List.unmodifiable(
        _allsOrders.where((o) =>
        (o.userID ?? '').toLowerCase().contains(q) ||
            (o.orderStatus ?? '').toLowerCase().contains(q) ||
            (o.sId ?? '').toLowerCase().contains(q)),
      );
    }
    notifyListeners();
  }

  void searchOrders(String query) {
    if (query.isEmpty) {
      _filteredOrders = List.unmodifiable(_allOrders);
    } else {
      final q = query.toLowerCase();
      _filteredOrders = List.unmodifiable(
        _allOrders.where((o) =>
        (o.userID ?? '').toLowerCase().contains(q) ||
            (o.orderStatus ?? '').toLowerCase().contains(q) ||
            (o.sId ?? '').toLowerCase().contains(q)),
      );
    }
    notifyListeners();
  }

// در dispose اصلی DataProvider این‌ها را نگه دار:
//   @override
//   void dispose() {
//     _notifyDebounce?.cancel();
//     disposeOrdersRealtime();
//     super.dispose();
//   }
  @override
  void dispose() {
    _notifyDebounce?.cancel();
    disposeOrdersRealtime();
    disposeOrdersPolling(); // ← این خط رو اضافه کن
    super.dispose();
  }

  // final CategoryRepository categoryRepo = CategoryRepository();
  final CategoriesRepository categoriesRepoAppwrite = CategoriesRepository();
  // final BrandRepository brandRepo = BrandRepository();
  final BrandsRepository brandsRepoAppwrite = BrandsRepository();

  // final SubCategoryRepository subCategoryRepo = SubCategoryRepository();
  final SubCategoryAppwriteService _subCategoryService =
  SubCategoryAppwriteService();

  // final VariantTypeRepository variantTypeRepo = VariantTypeRepository();
  final VariantTypesRepository variantTypesRepoAppwrite = VariantTypesRepository();

  // final VariantRepository variantRepo = VariantRepository();
  final VariantsRepository variantsRepoAppwrite = VariantsRepository();
  // final ProductRepository productRepo = ProductRepository();
  final ProductsAppwriteService _productsService = ProductsAppwriteService();

  // final PosterRepository posterRepo = PosterRepository();
  final PosterAppwriteService _posterService = PosterAppwriteService();

  // final CouponRepository couponRepo = CouponRepository();
  final CouponCodeAppwriteService _couponService = CouponCodeAppwriteService();




  bool _initialized = false;


  // اگر جایی هنوز از این استفاده می‌کنی، این فقط یک شورت‌کات به لود اولیه است
  Future<List<Order>> getAllOrders({bool showSnack = false}) async {
    return loadInitialOrders(showSnack: showSnack);
  }

  // ... بقیه‌ی کلاس مثل قبل ...

  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];

  List<Category> get categories => _filteredCategories;

  List<SubCategory> _allSubCategories = [];
  List<SubCategory> _filteredSubCategories = [];

  List<SubCategory> get subCategories => _filteredSubCategories;

  List<Brand> _allBrands = [];
  List<Brand> _filteredBrands = [];

  List<Brand> get brands => _filteredBrands;

  List<VariantType> _allVariantTypes = [];
  List<VariantType> _filteredVariantTypes = [];

  List<VariantType> get variantTypes => _filteredVariantTypes;

  List<Variant> _allVariants = [];
  List<Variant> _filteredVariants = [];

  List<Variant> get variants => _filteredVariants;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  List<Product> get products => _filteredProducts;

  String _filteredProductsType = ALL_PRODUCTS;

  String get productsType => _filteredProductsType;

  List<Coupon> _allCoupons = [];
  List<Coupon> _filteredCoupons = [];

  List<Coupon> get coupons => _filteredCoupons;

  List<Poster> _allPosters = [];
  List<Poster> _filteredPosters = [];

  List<Poster> get posters => _filteredPosters;

  DataProvider() {
    _maybeInitOnStartup();
  }

  Future<void> _maybeInitOnStartup() async {
    final phone = await UserSaveHelper.getPhoneNumber(showError: false);
    if (phone == null || phone.isEmpty) return;
    await initAll();
  }

  Future<void> initAll() async {
    if (_initialized) return;
    _initialized = true;

    await _bootOrders();
    await  getAllCategories();
      await getAllSubCategories();
      await  getAllBrands();
      await  getAllVariantTypes();
      await   getAllVariants();
      await   getAllPosters();
      await  getAllProducts();


  }

  Future<void> initAfterLogin() async {
    await initAll();
  }









  int calculateOrdersWithStatus({String? status}) {
    int totalOrders = 0;

    if (status == null) {
      totalOrders = _allsOrders.length;
    } else {
      for (Order order in _allsOrders) {
        if (order.orderStatus == status) {
          totalOrders++;
        }
      }
    }

    return totalOrders;
  }


  void filterProductsByQuantity(String productQntType, {bool showSnack = false}) {
    _filteredProductsType = productQntType.isEmpty ? ALL_PRODUCTS : productQntType;

    if (_filteredProductsType == ALL_PRODUCTS) {
      _filteredProducts = List<Product>.from(_allProducts);

    } else if (_filteredProductsType == STOCK_OUT_PRODUCTS) {
      _filteredProducts = _allProducts.where((p) => (_qtyOf(p) ?? -1) == 0).toList();

    } else if (_filteredProductsType == LIMITED_STOCK_PRODUCTS) {
      _filteredProducts = _allProducts.where((p) => (_qtyOf(p) ?? -1) == 1).toList();

    } else if (_filteredProductsType == OTHER_PRODUCTS) {
      _filteredProducts = _allProducts.where((p) {
        final q = _qtyOf(p);
        return q == null || (q != 0 && q != 1); // null هم میره تو سایر
      }).toList();

    } else {
      _filteredProducts = List<Product>.from(_allProducts);
    }

    if (showSnack) {
      SnackBarHelper.showSuccessSnackBar('${_filteredProductsType} retrieved successfully!');
    }

    notifyListeners();
  }

  int calculateProductWithQuantity({int? quantity}) {
    if (quantity == null) return _allProducts.length;

    int total = 0;
    for (final p in _allProducts) {
      final q = _qtyOf(p);
      if (q == quantity) total++;
    }
    return total;
  }
  int? _tryInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }

  int? _qtyOf(Product p) => _tryInt(p.quantity);




  // ✅ اینو آخر کلاس DataProvider اضافه کن
  Future<void> logoutCleanup() async {
    // 1) realtime رو ببند
    await disposeOrdersRealtime();

    // 2) debounce رو خاموش کن
    _notifyDebounce?.cancel();
    _notifyDebounce = null;

    // 3) فلگ init رو ریست کن تا بعد از لاگین دوباره initAll اجرا بشه
    _initialized = false;

    // 4) state سفارش‌ها رو ریست کن
    _allsOrders.clear();
    _filteredOrdersall = const <Order>[];

    _allOrders.clear();
    _filteredOrders = const <Order>[];

    _ordersPage = 1;
    _ordersHasMore = true;
    _ordersLoading = false;

    // 5) بقیه دیتاها رو پاک کن
    _allCategories.clear();
    _filteredCategories = const <Category>[];

    _allSubCategories.clear();
    _filteredSubCategories = const <SubCategory>[];

    _allBrands.clear();
    _filteredBrands = const <Brand>[];

    _allVariantTypes.clear();
    _filteredVariantTypes = const <VariantType>[];

    _allVariants.clear();
    _filteredVariants = const <Variant>[];

    _allProducts.clear();
    _filteredProducts = const <Product>[];
    _filteredProductsType = ALL_PRODUCTS;

    _allCoupons.clear();
    _filteredCoupons = const <Coupon>[];

    _allPosters.clear();
    _filteredPosters = const <Poster>[];
    _variantsLoading = false;
    _variantsLoadingMore = false;
    _variantsHasMore = true;
    _variantsCursorAfter = null;
    _variantKeyword = '';
    _vtMapForVariants.clear();
    _vtMapPhoneForVariants = null;
    _postersLoading = false;
    _postersLoadingMore = false;
    _postersHasMore = true;
    _postersCursorAfter = null;
    _posterKeyword = '';

    notifyListeners();
  }

}