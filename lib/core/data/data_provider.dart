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
  final int _ordersPageSize = 50;
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

  Future<void> _bootOrders() async {
    if (!await _isOrdersEnabled()) {
      await disposeOrdersRealtime();
      return;
    }

    // داشبورد: همه سفارشات در جریان (به جز Paid)
    await getAllsOrders(showSnack: false);

    // صفحه Paid ها با پیجین (اگه لازم داری همون اول لود شه)
    // await loadInitialOrders(showSnack: false);

    // realtime
    await initOrdersRealtime();
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
  Future<void> initOrdersRealtime() async {
    await disposeOrdersRealtime();

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '';
      if (phone.trim().isEmpty) return;

      _ordersSub = ordersAppwriteService.subscribeOrders((msg) {
        _applyOrdersRealtime(msg, phoneNumberCode: phone.trim());
      });
    } catch (_) {}
  }

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

  void _applyOrdersRealtime(RealtimeMessage msg, {required String phoneNumberCode}) {
    try {
      final action = _actionFromEvents(msg.events);
      final payload = msg.payload;
      if (payload is! Map) return;

      final doc = Map<String, dynamic>.from(payload as Map);
      final normalized = <String, dynamic>{
        ...doc,
        'id': doc['id'] ?? doc[r'$id'],
        'created': doc['created'] ?? doc[r'$createdAt'],
      };

      final order = Order.fromJson(normalized);

      // tenant filter
      final p = (order.phoneNumberCode ?? '').trim();
      if (p.isNotEmpty && p != phoneNumberCode) return;

      final id = (order.sId ?? '').trim();
      if (id.isEmpty) return;

      if (action == 'delete') {
        _removeOrderFromList(_allsOrders, id); // in-progress
        _removeOrderFromList(_allOrders, id);  // paid
      } else if (action == 'create' || action == 'update') {
        if (_isPaidStatus(order.orderStatus)) {
          // Paid => از داشبورد حذف
          _removeOrderFromList(_allsOrders, id);

          // Paid list => اگر لیست Paid لود شده، آپدیت/اضافه کن
          final idx = _allOrders.indexWhere((o) => (o.sId ?? '') == id);
          if (idx >= 0) {
            _allOrders[idx] = order;
          } else {
            // فقط اگر صفحه اول یا قبلاً لیست رو داری
            if (_ordersPage <= 1) _allOrders.insert(0, order);
          }
        } else {
          // Non-Paid => در جریان
          _upsertOrderInList(_allsOrders, order);

          // اگر قبلاً Paid بوده، از لیست Paid حذف
          _removeOrderFromList(_allOrders, id);
        }
      }

      _filteredOrdersall = List.unmodifiable(_allsOrders);
      _filteredOrders = List.unmodifiable(_allOrders);

      _safeNotify();
    } catch (_) {}
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
  @override
  void dispose() {
    _notifyDebounce?.cancel();
    disposeOrdersRealtime();
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
    await Future.wait([
      getAllProducts(),
      getAllCategories(),
      getAllSubCategories(),
      getAllBrands(),
      getAllVariantTypes(),
      getAllVariants(),
      getAllPosters(),
    ]);
    await _bootOrders();
  }

  Future<void> initAfterLogin() async {
    await initAll();
  }


  Future<List<Category>> getAllCategories({bool showSnack = false}) async {
    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredCategories;
      }

      // ✅ نسخه جدید: خواندن از Appwrite
      final result =
      await categoriesRepoAppwrite.getByPhoneNumberCode(phone);

      if (result.isSuccess) {
        final data = result.requireData();
        // 🔍 لاگ دقیق تمام آیتم‌های برگردانده‌شده
        if (kDebugMode) {
          print('===== CATEGORIES FROM APPWRITE (MAPPED TO MODEL) =====');
          print('count: ${data.length}');
          for (final c in data) {
            print('----------------------------------------');
            print('id       : ${c.sId}');
            print('name     : ${c.name}');
            // اگر توی مدل Category فیلد phone_number_code رو نگه می‌داری:
            // print('phoneCode: ${c.phoneNumberCode}');
            print('toJson() : ${c.toJson()}');
          }
          print('========================================');
        }

        _allCategories = data;
        _filteredCategories = List<Category>.from(_allCategories);

        if (kDebugMode) {
          print('✅ Categories loaded from Appwrite: ${_allCategories.length} items');
        }

        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(
            'دسته‌بندی‌ها با موفقیت از Appwrite لود شدند',
          );
        }

        return _filteredCategories;
      } else {
        final error = result.requireError();
        if (kDebugMode) {
          print('❌ Appwrite error in getAllCategories: $error');
        }
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar(error.userMessage);
        }
        return _filteredCategories;
      }
    } catch (e) {
      print('❌ Exception in getAllCategories: $e');
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('خطا در لود دسته‌بندی‌ها: $e');
      }
      rethrow;
    }
  }


  void filterCategories(String keyword) {
    keyword = keyword.trim();

    if (keyword.isEmpty) {
      _filteredCategories = List.from(_allCategories);
    } else {
      final lowerKeyword = keyword.trim().toLowerCase();
      _filteredCategories = _allCategories.where((category) {
        return (category.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }

    notifyListeners();
  }


  Future<List<SubCategory>> getAllSubCategories({bool showSnack = false}) async {
    try {
      // ✅ خواندن از Appwrite

      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredSubCategories;
      }


      final result = await _subCategoryService.getByPhoneNumberCode(phone);

      if (result.isSuccess) {
        final subs = result.requireData();

        // 🔍 لاگ دقیق تمام ساب‌کتگوری‌ها
        if (kDebugMode) {
          print('===== SUBCATEGORIES FROM APPWRITE (MAPPED TO MODEL) =====');
          print('count: ${subs.length}');
          for (final s in subs) {
            print('----------------------------------------');
            print('id              : ${s.sId}');
            print('name            : ${s.name}');
            print('category (ID)   : ${s.category}');              // از فیلد categories[]
            print('expandCatId     : ${s.categoryId?.sId}');       // اگر از بک‌اند قدیمی باشد
            print('expandCatName   : ${s.categoryId?.name}');
            print('createdAt       : ${s.createdAt}');
            print('updatedAt       : ${s.updatedAt}');
            print('toJson()        : ${s.toJson()}');
          }
          print('=========================================================');
        }

        _allSubCategories = subs;
        _filteredSubCategories = List<SubCategory>.from(_allSubCategories);

        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(
            'Subcategories loaded successfully',
          );
        }

        return _filteredSubCategories;
      } else {
        final error = result.requireError();
        if (kDebugMode) {
          print('❌ Appwrite error in getAllSubCategories: $error');
        }
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar(
            error.userMessage.isNotEmpty
                ? error.userMessage
                : (error.devMessage ?? 'Failed to load subcategories'),
          );
        }
        return _filteredSubCategories;
      }
    } catch (e) {
      print('❌ Error in getAllSubCategories: $e');
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load subcategories: $e');
      }
      rethrow;
    }
  }


  void filterSubCategories(String keyword) {
    keyword = keyword.trim();

    if (keyword.isEmpty) {
      _filteredSubCategories = List.from(_allSubCategories);
    } else {
      final lowerKeyword = keyword.trim().toLowerCase();
      _filteredSubCategories = _allSubCategories.where((category) {
        return (category.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }

    notifyListeners();
  }


  Future<List<Brand>> getAllBrands({bool showSnack = false}) async {
    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';

      if (phone == null || phone.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن/کد در حافظه یافت نشد!');
        return _filteredBrands;
      }

      // برای اینکه نام ساب‌کتگوری در لیست برندها نمایش داده شود
      if (_allSubCategories.isEmpty) {
        await getAllSubCategories(showSnack: false);
      }

      final result = await brandsRepoAppwrite.getByPhoneNumberCode(phone.trim());

      if (result.isSuccess) {
        final brands = result.requireData();

        // مپ ساب‌کتگوری‌ها برای پر کردن نام
        final scMap = <String, SubCategory>{};
        for (final sc in _allSubCategories) {
          final id = sc.sId;
          if (id != null && id.isNotEmpty) scMap[id] = sc;
        }

        for (final b in brands) {
          final subId = b.subcategory ?? b.subcategoriesId;
          if (subId != null && scMap.containsKey(subId)) {
            final sc = scMap[subId]!;
            b.subCategoryId = SubcategoryId(
              sId: sc.sId,
              name: sc.name,
              // اگر خواستی: category: sc.category,
            );
          }
        }

        _allBrands = brands;
        _filteredBrands = List.from(_allBrands);

        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar('Brands loaded successfully');
        }

        return _filteredBrands;
      } else {
        final err = result.requireError();
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar(
            err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'Failed to load brands'),
          );
        }
        return _filteredBrands;
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load brands: $e');
      }
      rethrow;
    }
  }


  void filterBrands(String keyword) {
    keyword = keyword.trim();

    if (keyword.isEmpty) {
      _filteredBrands = List.from(_allBrands);
    } else {
      final lowerKeyword = keyword.trim().toLowerCase();
      _filteredBrands = _allBrands.where((category) {
        return (category.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }

    notifyListeners();
  }

  Future<List<VariantType>> getAllVariantTypes({bool showSnack = false}) async {
    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';
      if (phone.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن/کد در حافظه یافت نشد!');
        return _filteredVariantTypes;
      }

      final result = await variantTypesRepoAppwrite.getByPhoneNumberCode(phone.trim());

      if (result.isSuccess) {
        final data = result.requireData();

        _allVariantTypes = data;
        _filteredVariantTypes = List.from(_allVariantTypes);

        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar('Variant types loaded successfully');
        }

        return _filteredVariantTypes;
      } else {
        final err = result.requireError();
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar(
            err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'Failed to load variant types'),
          );
        }
        return _filteredVariantTypes;
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load variant types: $e');
      }
      rethrow;
    }
  }


  void filterVariantTypes(String keyword) {
    keyword = keyword.trim();

    if (keyword.isEmpty) {
      _filteredVariantTypes = List.from(_allVariantTypes);
    } else {
      final lowerKeyword = keyword.trim().toLowerCase();
      _filteredVariantTypes = _allVariantTypes.where((category) {
        return (category.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }

    notifyListeners();
  }



  Future<List<Variant>> getAllVariants({bool showSnack = false}) async {
    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';
      if (phone.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن/کد در حافظه یافت نشد!');
        return _filteredVariants;
      }

      // برای نمایش نام تایپ در لیست variants
      if (_allVariantTypes.isEmpty) {
        await getAllVariantTypes(showSnack: false);
      }

      final result = await variantsRepoAppwrite.getByPhoneNumberCode(phone.trim());

      if (result.isSuccess) {
        final data = result.requireData();
        _allVariants = data;
        _filteredVariants = List.from(_allVariants);

        // مپ نام تایپ
        final map = <String, VariantType>{};
        for (final vt in _allVariantTypes) {
          final id = vt.sId;
          if (id != null && id.isNotEmpty) map[id] = vt;
        }

        for (final v in _filteredVariants) {
          final vtId = v.variantType ?? v.variantTypeId?.sId;
          if (vtId != null && map.containsKey(vtId)) {
            final vt = map[vtId]!;
            v.variantTypeId = VariantTypeId(
              sId: vt.sId,
              name: vt.name,
              type: vt.type,
            );
          }
        }

        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar('Variants loaded successfully');
        }
        return _filteredVariants;
      } else {
        final err = result.requireError();
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar(
            err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'Failed to load variants'),
          );
        }
        return _filteredVariants;
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load variants: $e');
      }
      rethrow;
    }
  }


  void filterVariants(String keyword) {
    keyword = keyword.trim();

    if (keyword.isEmpty) {
      _filteredVariants = List.from(_allVariants);
    } else {
      final lowerKeyword = keyword.trim().toLowerCase();
      _filteredVariants = _allVariants.where((category) {
        return (category.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }

    notifyListeners();
  }


  Future<List<Product>> getAllProducts({bool showSnack = false}) async {
    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';
      if (phone.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن/کد در حافظه یافت نشد!');
        return _filteredProducts;
      }

      // برای اینکه dropdownها/نام‌ها آماده باشند (اگر لازم شد در UI)
      if (_allCategories.isEmpty) await getAllCategories(showSnack: false);
      if (_allSubCategories.isEmpty) await getAllSubCategories(showSnack: false);
      if (_allVariantTypes.isEmpty) await getAllVariantTypes(showSnack: false);
      if (_allVariants.isEmpty) await getAllVariants(showSnack: false);
      if (_allBrands.isEmpty) await getAllBrands(showSnack: false);

      final result = await _productsService.getByPhoneNumberCode(phone.trim());

      if (result.isSuccess) {
        _allProducts = result.requireData();
        _filteredProducts = List.from(_allProducts);
        final catMap = <String, String>{};
        for (final c in _allCategories) {
          final id = c.sId ?? '';
          if (id.isNotEmpty) catMap[id] = c.name ?? '';
        }

        final subMap = <String, String>{};
        for (final s in _allSubCategories) {
          final id = s.sId ?? '';
          if (id.isNotEmpty) subMap[id] = s.name ?? '';
        }

        for (final p in _allProducts) {
          final cid = p.categoryId ?? '';
          final sid = p.subCategoryId ?? '';
          p.resolvedCategoryName = catMap[cid] ?? '';
          p.resolvedSubCategoryName = subMap[sid] ?? '';
        }

        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar('Products loaded successfully');
        }
        return _filteredProducts;
      } else {
        final err = result.requireError();
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar(
            err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'Failed to load products'),
          );
        }
        return _filteredProducts;
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load products: $e');
      }
      rethrow;
    }
  }


  void filterProducts(String keyword) {
    keyword = keyword.trim();

    if (keyword.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      final lowerKeyword = keyword.toLowerCase();

      _filteredProducts = _allProducts.where((product) {
        final productNameContainsKeyword =
        (product.name ?? '').toLowerCase().contains(lowerKeyword);

        final categoryNameContainsKeyword =
        (product.resolvedCategoryName ?? '').toLowerCase().contains(lowerKeyword);

        final subCategoryNameContainsKeyword =
        (product.resolvedSubCategoryName ?? '').toLowerCase().contains(lowerKeyword);

        return productNameContainsKeyword ||
            categoryNameContainsKeyword ||
            subCategoryNameContainsKeyword;
      }).toList();
    }

    notifyListeners();
  }

  Future<List<Poster>> getAllPosters({bool showSnack = false}) async {
    try {
      // ✅ گرفتن شماره تلفن از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredPosters;
      }

      final result = await _posterService.getPostersByPhoneNumberCode(phone);

      if (result.isSuccess) {
        final posters = result.requireData();

        _allPosters = posters;
        _filteredPosters = List<Poster>.from(_allPosters);

        if (kDebugMode) {
          print('✅ Posters loaded from Appwrite: ${_allPosters.length} items');
          if (_allPosters.isNotEmpty) {
            print('🔍 First poster details:');
            print('   - Name: ${_allPosters.first.posterName}');
            print('   - ImageUrl: ${_allPosters.first.imageUrl}');
            print('   - ID: ${_allPosters.first.sId}');
          }
        }

        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar('پوسترها با موفقیت لود شدند');
        }

        return _filteredPosters;
      } else {
        final error = result.requireError();
        if (kDebugMode) {
          print('❌ Appwrite error in getAllPosters: $error');
        }
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar(
            error.userMessage.isNotEmpty
                ? error.userMessage
                : (error.devMessage ?? 'خطا در لود پوسترها'),
          );
        }
        return _filteredPosters;
      }
    } catch (e) {
      print('❌ Exception in getAllPosters: $e');
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('خطا در لود پوسترها: $e');
      }
      rethrow;
    }
  }

  void filterPosters(String keyword) {
    keyword = keyword.trim();

    if (keyword.isEmpty) {
      _filteredPosters = List.from(_allPosters);
    } else {
      final lowerKeyword = keyword.trim().toLowerCase();
      _filteredPosters = _allPosters.where((poster) {
        return (poster.posterName ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }

    notifyListeners();
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

  void filterProductsByQuantity(String productQntType,
      {bool showSnack = false}) {
    _filteredProductsType =
        productQntType.isEmpty ? ALL_PRODUCTS : productQntType;

    if (productQntType == ALL_PRODUCTS) {
      _filteredProducts = List.from(_allProducts);
    } else if (productQntType == STOCK_OUT_PRODUCTS) {
      _filteredProducts = _allProducts.where((product) {
        return product.quantity != null && product.quantity == 0;
      }).toList();
    } else if (productQntType == LIMITED_STOCK_PRODUCTS) {
      _filteredProducts = _allProducts.where((product) {
        return product.quantity != null && product.quantity == 1;
      }).toList();
    } else if (productQntType == OTHER_PRODUCTS) {
      _filteredProducts = _allProducts.where((product) {
        return product.quantity != null &&
            product.quantity != 0 &&
            product.quantity != 1;
      }).toList();
    } else {
      _filteredProducts = List.from(_allProducts);
    }

    if (showSnack) {
      SnackBarHelper.showSuccessSnackBar(
          '${_filteredProductsType} retrieved successfully!');
    }

    notifyListeners();
  }

  int calculateProductWithQuantity({int? quantity}) {
    int totalProducts = 0;

    if (quantity == null) {
      totalProducts = _allProducts.length;
    } else {
      for (Product product in _allProducts) {
        if (product.quantity != null && product.quantity == quantity) {
          totalProducts++;
        }
      }
    }

    return totalProducts;
  }

  Future<List<Coupon>> getAllCoupons({bool showSnack = false}) async {
    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';
      if (phone == null || phone.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredCoupons;
      }

      final result = await _couponService.getByPhoneNumberCode(phone);

      if (result.isSuccess) {
        _allCoupons = result.requireData();
        _filteredCoupons = List.from(_allCoupons);
        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar('Coupons loaded successfully');
        }
        return _filteredCoupons;
      } else {
        final err = result.requireError();
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar(
            err.userMessage.isNotEmpty ? err.userMessage : (err.devMessage ?? 'Failed to load coupons'),
          );
        }
        return _filteredCoupons;
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load coupons: $e');
      }
      rethrow;
    }
  }


  void filterCoupons(String keyword) {
    keyword = keyword.trim();

    if (keyword.isEmpty) {
      _filteredCoupons = List.from(_allCoupons);
    } else {
      final lowerKeyword = keyword.trim().toLowerCase();
      _filteredCoupons = _allCoupons.where((coupon) {
        return (coupon.couponCode ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }

    notifyListeners();
  }
}
