
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';

import '../../../models/category.dart';
import '../../models/brand.dart';
import '../../models/coupon.dart';

import '../../models/order.dart';
import '../../models/poster.dart';
import '../../models/product.dart';
import '../../models/sub_category.dart';
import '../../models/variant.dart';
import '../../models/variant_type.dart';
import '../../services/http_services.dart';
import '../../utility/constants.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DataProvider extends ChangeNotifier {
  HttpService service = HttpService();

/////////////////////////////////////////////////////////
// اگر menu_type == menu_one باشد، بخش سفارش‌ها غیرفعال است
  Future<bool> _isOrdersEnabled() async {
    try {
      final info = await UserSaveHelper.getUserInfo(showError: false);
      final menuType = (info?['menu_type'] ?? '').toString().trim().toLowerCase();
      return menuType != 'menu_one';
    } catch (_) {
      // اگر نتوانستیم بخوانیم، محافظه‌کارانه فعال در نظر می‌گیریم
      return true;
    }
  }
  Future<void> _bootOrders() async {
    if (!await _isOrdersEnabled()) {
      // اطمینان از قطع بودن ریل‌تایم
      await disposeOrdersRealtime();
      // اگر خواستی پیام بگذاری:
      // SnackBarHelper.showInfoSnackBar('ماژول سفارش‌ها برای این نوع منو غیرفعال است');
      return;
    }
    await getAllsOrders();
    await initOrdersRealtime();
    await     getAllCoupons();
  }


/////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////
  // Realtime (ساده و عمومی)
  IO.Socket? _ordersSocket;
  Timer? _notifyDebounce;

  void _safeNotify() {
    _notifyDebounce?.cancel();
    _notifyDebounce = Timer(const Duration(milliseconds: 120), () {
      notifyListeners();
    });
  }

  Future<void> initOrdersRealtime() async {
    await disposeOrdersRealtime(); // اگر قبلاً وصل بوده

    try {
      final phone = await UserSaveHelper.getPhoneNumber(); // برای فیلتر سمت کلاینت
      final url = MAIN_URL; // مثلا: http://10.0.2.2:5001 یا http://localhost:5001

      _ordersSocket = IO.io(
        url,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(600)
            .setReconnectionDelayMax(4000)
            .build(),
      );

      _ordersSocket!
        ..onConnect((_) {
          // وصل شد
        })
        ..on('orders_change', (payload) {
          _applyOrderChange(payload, phoneNumberCode: phone);
        })
        ..onError((e) {
          // debugPrint('socket error: $e');
        })
        ..onDisconnect((_) {
          // debugPrint('socket disconnected');
        })
        ..connect();
    } catch (_) {}
  }

  Future<void> disposeOrdersRealtime() async {
    try {
      _ordersSocket?.dispose();
      _ordersSocket?.destroy();
      _ordersSocket = null;
    } catch (_) {}
  }
  void _applyOrderChange(dynamic payload, {String? phoneNumberCode}) {
    try {
      if (payload is! Map) return;
      final action = (payload['action'] ?? '').toString();
      final rec = payload['record'];
      if (rec is! Map) return;

      // یکدست‌سازی id با مدل تو (Order.fromJson معمولاً sId می‌خواد)
      final json = Map<String, dynamic>.from(rec);
      json['sId'] ??= json['id'];

      // فیلتر tenant
      if (phoneNumberCode != null && phoneNumberCode.isNotEmpty) {
        final p = (json['phone_number_code'] ?? '').toString();
        if (p.isNotEmpty && p != phoneNumberCode) return;
      }

      final order = Order.fromJson(json);

      if (action == 'create' || action == 'update') {
        _upsertOrderInList(_allsOrders, order);
        _upsertOrderInList(_allOrders, order);
      } else if (action == 'delete') {
        final id = order.sId ?? json['id']?.toString();
        if (id != null) {
          _removeOrderFromList(_allsOrders, id);
          _removeOrderFromList(_allOrders, id);
        }
      } else {
        return;
      }

      // بازاعمال فیلترها (ساده: نمایش کامل؛ اگر حالت فیلتر فعال داری، همان منطق را اینجا صدا بزن)
      _filteredOrdersall = List.unmodifiable(_allsOrders);
      _filteredOrders    = List.unmodifiable(_allOrders);

      _safeNotify();
    } catch (_) {}
  }

  void _upsertOrderInList(List<Order> list, Order incoming) {
    final idx = list.indexWhere((o) => (o.sId ?? '') == (incoming.sId ?? ''));
    if (idx == -1) {
      list.insert(0, incoming); // جدید بالا
    } else {
      list[idx] = incoming;     // بروزرسانی
    }
  }

  void _removeOrderFromList(List<Order> list, String id) {
    list.removeWhere((o) => (o.sId ?? '') == id);
  }

  @override
  void dispose() {
    _notifyDebounce?.cancel();
    disposeOrdersRealtime();
    super.dispose();
  }

/////////////////////////////////////////////////////////


  final int _ordersPageSize = 50;
  int _ordersPage = 1;
  bool _ordersHasMore = true;
  bool _ordersLoading = false;

  bool get isOrdersLoading => _ordersLoading;
  bool get hasMoreOrders => _ordersHasMore;

  final List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  List<Order> get orders => _filteredOrders;

  Future<List<Order>> loadInitialOrders({bool showSnack = false}) async {
    if (_ordersLoading) return _filteredOrders;
    _ordersPage = 1;
    _ordersHasMore = true;
    _allOrders.clear();
    _filteredOrders = const [];
    notifyListeners();

    return _fetchOrdersPage(_ordersPage, showSnack: showSnack);
  }

  Future<List<Order>> loadMoreOrders({bool showSnack = false}) async {
    if (_ordersLoading || !_ordersHasMore) return _filteredOrders;
    _ordersPage += 1;
    return _fetchOrdersPage(_ordersPage, showSnack: showSnack);
  }





  Future<List<Order>> _fetchOrdersPage(int page, {bool showSnack = false}) async {
    if (_ordersLoading) return _filteredOrders; // گارد مضاعف
    _ordersLoading = true;
    notifyListeners();

    try {
      // ✅ مقدار شماره تلفن از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredOrders;
      }

      final String endpoint =
          'api/orders?phone_number_code=${Uri.encodeQueryComponent(phone)}&page=$page&perPage=$_ordersPageSize';

      final response = await service.getItems(endpointUrl: endpoint);

      if (!response.isOk) {
        throw Exception('HTTP ${response.statusCode}: ${response.statusText}');
      }

      final responseBody = response.body;
      if (responseBody['success'] != true) {
        throw Exception(responseBody['message'] ?? 'Failed to load orders');
      }

      final List<dynamic> ordersData = responseBody['data'] ?? [];
      final List<Order> pageOrders =
      ordersData.map((item) => Order.fromJson(item)).toList();

      // append
      _allOrders.addAll(pageOrders);
      _filteredOrders = List.unmodifiable(_allOrders); // امن‌تر برای UI

      // hasMore از meta یا سایز صفحه
      final meta = responseBody['meta'];
      if (meta is Map && meta.containsKey('hasMore')) {
        _ordersHasMore = meta['hasMore'] == true;
      } else {
        _ordersHasMore = pageOrders.length >= _ordersPageSize;
      }

      if (showSnack) {
        SnackBarHelper.showSuccessSnackBar(
            responseBody['message'] ?? 'Orders loaded successfully');
      }

      return _filteredOrders;
    } catch (e) {
      // اگر خطا داد، شماره صفحه را برگردان
      if (_ordersPage > 1) _ordersPage -= 1;
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    } finally {
      _ordersLoading = false;
      notifyListeners();
    }
  }


  void searchOrders(String query) {
    if (query.isEmpty) {
      _filteredOrders = List.unmodifiable(_allOrders);
    } else {
      final q = query.toLowerCase();
      _filteredOrders = List.unmodifiable(
        _allOrders.where((o) =>
        (o.userName ?? '').toLowerCase().contains(q) ||
            (o.orderStatus ?? '').toLowerCase().contains(q) ||
            (o.paymentMethod ?? '').toLowerCase().contains(q) ||
            (o.sId ?? '').toLowerCase().contains(q)),
      );
    }
    notifyListeners();
  }

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
    getAllProducts();
    getAllCategories();
    getAllSubCategories();
    getAllBrands();
    getAllVariantTypes();
    getAllVariants();
    getAllPosters();
    // getAllCoupons();
    // getAllsOrders();
    // getAllsOrders().then((_) {
    //   // بعد از بار اول لیست، realtime را وصل کن
    //   initOrdersRealtime();
    // });
    _bootOrders();
  }


// -------------------------------
// 🔹 لیست‌ها
// -------------------------------
  final List<Order> _allsOrders = [];
  List<Order> _filteredOrdersall = [];

  List<Order> get allsOrders => _filteredOrdersall;

// -------------------------------
// 🔹 گرفتن همه سفارش‌ها (از روت /api/ordersalls)
// -------------------------------
  Future<List<Order>> getAllsOrders({bool showSnack = false}) async {
    try {
      // ✅ گرفتن phone_number_code از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _allsOrders;
      }

      final String endpoint =
          'api/ordersalls?phone_number_code=${Uri.encodeQueryComponent(phone)}';

      final Response response = await service.getItems(endpointUrl: endpoint);

      if (response.isOk) {
        final body = response.body;
        if (body is Map && body['success'] == true && body['data'] is List) {
          final List<dynamic> data = body['data'];

          _allsOrders
            ..clear()
            ..addAll(data.map((e) => Order.fromJson(e as Map<String, dynamic>)));

          // فیلتر اولیه: همه سفارش‌ها
          _filteredOrdersall = List.unmodifiable(_allsOrders);

          print('✅ Orders loaded: ${_allsOrders.length}');
          if (_allsOrders.isNotEmpty) {
            final o = _allsOrders.first;
            print(
                '🔍 First order => id: ${o.sId}, status: ${o.orderStatus}, total: ${o.totalPrice}');
          }

          notifyListeners();
          if (showSnack) {
            SnackBarHelper.showSuccessSnackBar('Orders loaded successfully');
          }
          return _allsOrders;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusText}');
      }
    } catch (e) {
      print('❌ Error in getAllsOrders: $e');
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load orders: $e');
      }
      rethrow;
    }
  }

// -------------------------------
// 🔹 فیلتر بر اساس وضعیت سفارش (status)
// -------------------------------
  void filterAllOrders(String status) {
    if (status == ORDER_STATUS_ALL || status.isEmpty) {
      _filteredOrdersall = List.unmodifiable(_allsOrders);
    } else {
      final s = status.toLowerCase();
      _filteredOrdersall = List.unmodifiable(
        _allsOrders.where(
              (o) => (o.orderStatus ?? '').toLowerCase() == s,
        ),
      );
    }
    notifyListeners();
  }

// -------------------------------
// 🔹 جستجو بین سفارش‌ها
// -------------------------------
  void searchAllOrders(String query) {
    if (query.isEmpty) {
      _filteredOrdersall = List.unmodifiable(_allsOrders);
    } else {
      final q = query.toLowerCase();
      _filteredOrdersall = List.unmodifiable(
        _allsOrders.where(
              (o) =>
          (o.userName ?? '').toLowerCase().contains(q) ||
              (o.orderStatus ?? '').toLowerCase().contains(q) ||
              (o.paymentMethod ?? '').toLowerCase().contains(q) ||
              (o.sId ?? '').toLowerCase().contains(q),
        ),
      );
    }
    notifyListeners();
  }




  Future<List<Category>> getAllCategories({bool showSnack = false}) async {
    try {
      // ✅ گرفتن phone_number از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredCategories;
      }

      final String endpoint =
          'api/categories?phone_number_code=${Uri.encodeQueryComponent(phone)}';

      Response response = await service.getItems(endpointUrl: endpoint);

      if (response.isOk) {
        if (response.body['success'] == true) {
          List<dynamic> data = response.body['data'];

          // استفاده مستقیم از fromJson
          _allCategories = data.map((item) => Category.fromJson(item)).toList();
          _filteredCategories = List.from(_allCategories);

          print('✅ Categories loaded: ${_allCategories.length} items');

          // دیباگ - بررسی اولین آیتم
          if (_allCategories.isNotEmpty) {
            print('🔍 First category: ${_allCategories.first.name}');
            print('🔍 Image URL: ${_allCategories.first.image}');
          }

          notifyListeners();

          if (showSnack) {
            SnackBarHelper.showSuccessSnackBar('Categories loaded successfully');
          }

          return _filteredCategories;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusText}');
      }
    } catch (e) {
      print('❌ Error in getAllCategories: $e');
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load categories: $e');
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
      // ✅ گرفتن شماره تلفن از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredSubCategories;
      }

      final String endpoint =
          'api/subcategories?phone_number_code=${Uri.encodeQueryComponent(phone)}';

      // اضافه کردن api/ به endpoint
      Response response = await service.getItems(endpointUrl: endpoint);

      if (response.isOk) {
        if (response.body['success'] == true) {
          List<dynamic> data = response.body['data'];

          _allSubCategories =
              data.map((item) => SubCategory.fromJson(item)).toList();
          _filteredSubCategories = List.from(_allSubCategories);

          print('✅ SubCategories loaded: ${_allSubCategories.length} items');

          if (_allSubCategories.isNotEmpty) {
            print('🔍 First subcategory: ${_allSubCategories.first.name}');
            print('🔍 Category: ${_allSubCategories.first.categoryId?.name}');
          }

          notifyListeners();

          if (showSnack) {
            SnackBarHelper.showSuccessSnackBar('Subcategories loaded successfully');
          }

          return _filteredSubCategories;
        } else {
          throw Exception(response.body['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusText}');
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
      // ✅ گرفتن شماره تلفن از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredBrands;
      }

      final String endpoint =
          'api/brands?phone_number_code=${Uri.encodeQueryComponent(phone)}&expand=subcategory';

      // اضافه کردن api/ و expand
      Response response = await service.getItems(endpointUrl: endpoint);

      if (response.isOk) {
        if (response.body['success'] == true) {
          List<dynamic> data = response.body['data'];

          // استفاده مستقیم از fromJson
          _allBrands = data.map((item) => Brand.fromJson(item)).toList();
          _filteredBrands = List.from(_allBrands);

          print('✅ Brands loaded: ${_allBrands.length} items');

          // دیباگ - بررسی اولین آیتم
          if (_allBrands.isNotEmpty) {
            print('🔍 First brand: ${_allBrands.first.name}');
            print('🔍 SubCategory: ${_allBrands.first.subCategoryId?.name}');
          }

          notifyListeners();

          if (showSnack) {
            SnackBarHelper.showSuccessSnackBar('Brands loaded successfully');
          }

          return _filteredBrands;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusText}');
      }
    } catch (e) {
      print('❌ Error in getAllBrands: $e');
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
      // ✅ گرفتن شماره تلفن از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredVariantTypes;
      }

      final String endpoint =
          'api/variant-types?phone_number_code=${Uri.encodeQueryComponent(phone)}';

      Response response = await service.getItems(endpointUrl: endpoint);

      if (response.isOk) {
        if (response.body['success'] == true) {
          List<dynamic> data = response.body['data'];

          // استفاده مستقیم از fromJson با مدل اصلاح شده
          _allVariantTypes =
              data.map((item) => VariantType.fromJson(item)).toList();
          _filteredVariantTypes = List.from(_allVariantTypes);

          print('✅ VariantTypes loaded: ${_allVariantTypes.length} items');

          // دیباگ - بررسی اولین آیتم
          if (_allVariantTypes.isNotEmpty) {
            print('🔍 First variant type: ${_allVariantTypes.first.name}');
            print('🔍 Type: ${_allVariantTypes.first.type}');
          }

          notifyListeners();

          if (showSnack) {
            SnackBarHelper.showSuccessSnackBar('Variant types loaded successfully');
          }

          return _filteredVariantTypes;
        } else {
          throw Exception(response.body['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusText}');
      }
    } catch (e) {
      print('❌ Error in getAllVariantTypes: $e');
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
      // ✅ گرفتن شماره تلفن از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredVariants;
      }

      final String endpoint =
          'api/variants?phone_number_code=${Uri.encodeQueryComponent(phone)}';

      Response response = await service.getItems(endpointUrl: endpoint);

      if (response.isOk) {
        if (response.body['success'] == true) {
          List<dynamic> data = response.body['data'];

          // استفاده مستقیم از fromJson با مدل اصلاح شده
          _allVariants = data.map((item) => Variant.fromJson(item)).toList();
          _filteredVariants = List.from(_allVariants);

          print('✅ Variants loaded: ${_allVariants.length} items');

          // دیباگ - بررسی اولین آیتم
          if (_allVariants.isNotEmpty) {
            print('🔍 First variant: ${_allVariants.first.name}');
            print('🔍 Variant Type: ${_allVariants.first.variantTypeId?.name}');
          }

          notifyListeners();

          if (showSnack) {
            SnackBarHelper.showSuccessSnackBar('Variants loaded successfully');
          }

          return _filteredVariants;
        } else {
          throw Exception(response.body['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusText}');
      }
    } catch (e) {
      print('❌ Error in getAllVariants: $e');
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
      // ✅ گرفتن شماره تلفن از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredProducts;
      }

      final String endpoint =
          'api/products?phone_number_code=${Uri.encodeQueryComponent(phone)}';

      Response response = await service.getItems(endpointUrl: endpoint);

      if (response.isOk) {
        // پردازش response بر اساس ساختار سرور شما
        Map<String, dynamic> responseBody = response.body;

        if (responseBody['success'] == true) {
          List<dynamic> productsJson = responseBody['data'];
          print(responseBody['data']);
          List<Product> products =
          productsJson.map((item) => Product.fromJson(item)).toList();

          print('✅ ${products.length} products loaded successfully');

          _allProducts = products;
          _filteredProducts = List.from(_allProducts);

          notifyListeners();

          if (showSnack) {
            SnackBarHelper.showSuccessSnackBar(
                '${products.length} محصول با موفقیت بارگذاری شد');
          }

          return _filteredProducts;
        } else {
          throw Exception(responseBody['error'] ?? 'Failed to load products');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusText}');
      }
    } catch (e) {
      print('❌ Error loading products: $e');
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar(
            'خطا در بارگذاری محصولات: ${e.toString()}');
      }
      rethrow;
    }
  }

  void filterProducts(String keyword) {
    keyword = keyword.trim();

    if (keyword.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      final lowerKeyword = keyword.trim().toLowerCase();

      _filteredProducts = _allProducts.where((product) {
        final productNameContainsKeyword =
            (product.name ?? '').toLowerCase().contains(lowerKeyword);
        final categoryNameContainsKeyword =
            product.proCategoryId?.name?.toLowerCase().contains(lowerKeyword) ??
                false;
        final subCategoryNameContainsKeyword = product.proSubCategoryId?.name
                ?.toLowerCase()
                .contains(lowerKeyword) ??
            false;

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
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredPosters;
      }

      final String endpoint =
          'api/posters?phone_number_code=${Uri.encodeQueryComponent(phone)}';

      Response response = await service.getItems(endpointUrl: endpoint);
      if (response.isOk) {
        if (response.body['success'] == true) {
          List<dynamic> data = response.body['data'];

          // دیباگ دقیق‌تر
          print('🔍 Raw poster data: ${data[0]}');

          _allPosters = data.map((item) => Poster.fromJson(item)).toList();
          _filteredPosters = List.from(_allPosters);

          print('✅ Posters loaded: ${_allPosters.length} items');

          if (_allPosters.isNotEmpty) {
            print('🔍 First poster details:');
            print('   - Name: ${_allPosters.first.posterName}');
            print('   - ImageUrl: ${_allPosters.first.imageUrl}');
            print('   - ImageId: ${_allPosters.first.imageId}');
            print('   - ID: ${_allPosters.first.sId}');
          }

          notifyListeners();

          if (showSnack) {
            SnackBarHelper.showSuccessSnackBar('Posters loaded successfully');
          }
          return _filteredPosters;
        } else {
          throw Exception(response.body['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusText}');
      }
    } catch (e) {
      print('❌ Error in getAllPosters: $e');
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load posters: $e');
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
      // ✅ گرفتن شماره تلفن از SharedPreferences
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return _filteredCoupons;
      }

      final String endpoint =
          'api/coupons?phone_number_code=${Uri.encodeQueryComponent(phone)}';

      Response response = await service.getItems(endpointUrl: endpoint);

      if (response.isOk) {
        if (response.body['success'] == true) {
          List<dynamic> data = response.body['data'];

          // دیباگ دقیق‌تر
          print('🔍 Raw coupon data length: ${data.length}');
          if (data.isNotEmpty) {
            print('🔍 First coupon raw data: ${data[0]}');
          }

          _allCoupons = data.map((item) => Coupon.fromJson(item)).toList();
          _filteredCoupons = List.from(_allCoupons);

          print('✅ Coupons loaded: ${_allCoupons.length} items');

          if (_allCoupons.isNotEmpty) {
            print('🔍 First coupon details:');
            print('   - Code: ${_allCoupons.first.couponCode}');
            print('   - Discount: ${_allCoupons.first.discountAmount}');
            print('   - Type: ${_allCoupons.first.discountType}');
            print('   - Status: ${_allCoupons.first.status}');
            print('   - End Date: ${_allCoupons.first.endDate}');
            print('   - Category ID: ${_allCoupons.first.applicableCategory}');
            print('   - SubCategory ID: ${_allCoupons.first.applicableSubCategory}');
            print('   - Product ID: ${_allCoupons.first.applicableProduct}');

            // بررسی expand data
            if (_allCoupons.first.expand != null) {
              print('   - Expand Data:');
              if (_allCoupons.first.expand!.applicableCategory != null) {
                print('     - Category: ${_allCoupons.first.expand!.applicableCategory!.name}');
              }
              if (_allCoupons.first.expand!.applicableSubCategory != null) {
                print('     - SubCategory: ${_allCoupons.first.expand!.applicableSubCategory!.name}');
              }
              if (_allCoupons.first.expand!.applicableProduct != null) {
                print('     - Product: ${_allCoupons.first.expand!.applicableProduct!.name}');
              }
            }
          }

          notifyListeners();

          if (showSnack) {
            SnackBarHelper.showSuccessSnackBar('Coupons loaded successfully');
          }

          return _filteredCoupons;
        } else {
          throw Exception(response.body['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusText}');
      }
    } catch (e) {
      print('❌ Error in getAllCoupons: $e');
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
