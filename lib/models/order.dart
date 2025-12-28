import 'dart:convert';

class Order {
  // Appwrite meta
  String? sId; // $id
  DateTime? createdAt; // $createdAt
  DateTime? updatedAt; // $updatedAt

  // Order fields
  String? orderStatus;
  String? orderMode; // online | in_person
  String? tableNumber;

  double? totalPrice; // معمولاً قبل تخفیف (یا گاهی بعد تخفیف بسته به سرور)
  DateTime? orderDate; // fallback: createdAt

  /// ساختار نهایی که داخل اپ استفاده می‌کنی
  OrderTotal? orderTotal;

  String? phoneNumberCode; // phone_number_code
  String? userID; // userID (string id)

  String? couponCodeId; // couponCode_id
  String? couponCode; // optional

  ShippingAddress? shippingAddress;

  // Always non-null list
  List<Items> items = [];

  // optional legacy
  String? paymentMethod;
  String? trackingUrl;

  // optional expands
  Map<String, dynamic>? user;
  Map<String, dynamic>? coupon;

  Order();

  // -----------------------
  // Helpers (Parsing)
  // -----------------------
  static String? _toStr(dynamic v) => v == null ? null : v.toString();

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      final s = v.trim().replaceAll(',', '');
      return double.tryParse(s);
    }
    return null;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  /// ✅ public (بدون underscore) تا اگر فایل‌ها جدا شد هم به مشکل نخوری
  static dynamic tryJsonDecode(dynamic v) {
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return v;

      final looksJson = (s.startsWith('{') && s.endsWith('}')) ||
          (s.startsWith('[') && s.endsWith(']')) ||
          (s.startsWith('"') && s.endsWith('"'));
      if (!looksJson) return v;

      try {
        return jsonDecode(s);
      } catch (_) {
        return v;
      }
    }
    return v;
  }

  static Map<String, dynamic>? _asMap(dynamic v) {
    v = tryJsonDecode(v);
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  /// ✅ items ممکنه List<Map> یا String(JSON) یا List<String>(JSON per item) یا حتی [[{...}]] باشه
  static List<Items> _parseItems(dynamic raw) {
    if (raw == null) return <Items>[];

    final out = <Items>[];

    void walk(dynamic node) {
      if (node == null) return;

      node = tryJsonDecode(node);

      if (node is List) {
        for (final e in node) {
          walk(e);
        }
        return;
      }

      if (node is Map) {
        out.add(Items.fromJson(Map<String, dynamic>.from(node)));
        return;
      }
    }

    walk(raw);
    return out;
  }

  // -----------------------
  // Totals Normalization (Only from Order)
  // -----------------------
  double _toNum(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    final s = v.toString().trim().replaceAll(',', '');
    return double.tryParse(s) ?? 0.0;
  }

  double _calcItemsSum() {
    double sum = 0.0;
    for (final it in items) {
      final q = (it.quantity ?? 0);
      final p = (it.price ?? 0.0);
      if (q > 0 && p > 0) sum += q * p;
    }
    return sum;
  }

  /// ✅ فقط از خود سفارش (totalPrice/orderTotal/items) محاسبه می‌کنه
  /// - totalPrice: معمولاً subTotal
  /// - orderTotal: ممکنه عدد (total) باشد یا Map {subTotal, discount, total}
  /// - اگر Map بود ولی total نداشت، total = subTotal - discount
  void normalizeTotalsFromOrder(dynamic rawOrderTotal) {
    final itemsSum = _calcItemsSum();

    // 1) subTotal (قبل تخفیف) => اولویت با totalPrice
    double sub = (totalPrice ?? 0.0);

    // اگر totalPrice نبود از itemsSum استفاده کن
    if (sub <= 0 && itemsSum > 0) sub = itemsSum;

    // اگر itemsSum خیلی پرت بود (داده خراب)، به totalPrice بچسب
    // (فقط وقتی totalPrice داریم)
    if ((totalPrice ?? 0) > 0 && itemsSum > 0) {
      final ratio = itemsSum / (totalPrice ?? 1);
      final looksReasonable = ratio > 0.5 && ratio < 2.0;
      if (looksReasonable && (itemsSum - (totalPrice ?? 0)).abs() > 1) {
        // اگر منطقی بود می‌تونی sub رو دقیق‌تر از itemsSum بگیری
        // (اختیاری) این خط رو اگر نمی‌خوای، حذف کن:
        // sub = itemsSum;
      }
    }

    // 2) total (بعد تخفیف)
    double total = 0.0;

    final decoded = tryJsonDecode(rawOrderTotal);

    if (decoded is Map) {
      final mapSub = _toNum(decoded['subTotal']);
      final mapDisc = _toNum(decoded['discount']);
      double mapTotal = _toNum(decoded['total']);

      // ✅ اگر total داخل map نبود ولی discount داشت => total = subTotal - discount
      final effectiveSub = (mapSub > 0)
          ? mapSub
          : (sub > 0 ? sub : (itemsSum > 0 ? itemsSum : 0.0));

      if (mapTotal <= 0 && mapDisc > 0 && effectiveSub > 0) {
        mapTotal = (effectiveSub - mapDisc);
      }

      // اگر mapTotal معتبر شد، همونو مبنا بگیر
      if (mapTotal > 0) {
        final finalSub = effectiveSub > 0 ? effectiveSub : mapTotal;

        final fixedTotal = (mapTotal > finalSub) ? finalSub : mapTotal;

        // ✅ discount: اگر mapDisc معتبر بود، همونو بگیر و clamp کن؛ وگرنه اختلاف
        final fixedDiscount = (mapDisc > 0)
            ? mapDisc.clamp(0.0, finalSub).toDouble()
            : (finalSub - fixedTotal).clamp(0.0, finalSub).toDouble();

        orderTotal = OrderTotal(
          subTotal: finalSub,
          discount: fixedDiscount,
          total: fixedTotal,
        );
        return;
      }
    } else {
      // عدد یا string عددی (مثل لاگ شما: 10000000)
      total = _toNum(decoded);
    }

    // اگر sub هنوز 0 است، از itemsSum کمک بگیر
    if (sub <= 0 && itemsSum > 0) sub = itemsSum;

    // اگر total مشخص نشده، total = sub (بدون تخفیف)
    if (total <= 0) total = sub;

    // اگر total از sub بزرگتر شد => داده‌ها برعکس/غلط => تخفیف صفر
    if (total > sub) total = sub;

    final discount = (sub - total).clamp(0.0, sub).toDouble();

    orderTotal = OrderTotal(
      subTotal: sub,
      discount: discount,
      total: total,
    );
  }

  // -----------------------
  // FromJson / ToJson
  // -----------------------
  factory Order.fromJson(Map<String, dynamic> json) {
    final o = Order();

    // meta
    o.sId = _toStr(json[r'$id'] ?? json['id'] ?? json['_id']);
    o.createdAt = _toDate(json[r'$createdAt'] ?? json['createdAt'] ?? json['created']);
    o.updatedAt = _toDate(json[r'$updatedAt'] ?? json['updatedAt'] ?? json['updated']);

    // fields
    o.orderStatus = _toStr(json['orderStatus']);
    o.orderMode = _toStr(json['orderMode'])?.trim().toLowerCase();
    o.tableNumber = _toStr(json['tableNumber']);

    o.totalPrice = _toDouble(json['totalPrice']);
    o.phoneNumberCode = _toStr(json['phone_number_code'] ?? json['phoneNumberCode']);

    o.orderDate = _toDate(json['orderDate']) ?? o.createdAt;

    // shippingAddress
    final sa = _asMap(json['shippingAddress']);
    if (sa != null) o.shippingAddress = ShippingAddress.fromJson(sa);

    // items
    o.items = _parseItems(json['item']);

    // coupon fields (اسم‌های مختلف)
    o.couponCodeId = _toStr(
      json['couponCode_id'] ??
          json['couponCodeId'] ??
          json['couponCode'] ??
          json['couponCodeID'],
    );

    o.couponCode = _toStr(json['couponCode']) ?? o.couponCodeId;

    // userID ممکنه string یا map باشه
    final u = tryJsonDecode(json['userID']);
    if (u is Map) {
      o.userID = _toStr(u['id'] ?? u['_id'] ?? u[r'$id']);
    } else {
      o.userID = _toStr(u);
    }

    // legacy
    o.paymentMethod = _toStr(json['paymentMethod']);
    o.trackingUrl = _toStr(json['trackingUrl']);

    // expand maps if exist
    if (json['user'] is Map) o.user = Map<String, dynamic>.from(json['user']);
    if (json['coupon'] is Map) o.coupon = Map<String, dynamic>.from(json['coupon']);

    // ✅ محاسبه‌ی نهایی totals فقط از روی خود سفارش
    o.normalizeTotalsFromOrder(json['orderTotal']);

    return o;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': sId,
      'orderStatus': orderStatus,
      'orderMode': orderMode,
      'tableNumber': tableNumber,
      'totalPrice': totalPrice,
      'orderDate': orderDate?.toIso8601String(),
      'orderTotal': orderTotal?.toJson(),
      'phone_number_code': phoneNumberCode,
      'userID': userID,
      'couponCode_id': couponCodeId,
      'couponCode': couponCode,
      'shippingAddress': shippingAddress?.toJson(),
      'item': items.map((e) => e.toJson()).toList(),
      'paymentMethod': paymentMethod,
      'trackingUrl': trackingUrl,
    };
  }

  // Convenience
  bool get isInPersonOrder => (orderMode ?? '') == 'in_person';
  bool get isOnlineOrder => (orderMode ?? '') == 'online';

  double get totalValue => orderTotal?.total ?? totalPrice ?? 0.0;
  double get subTotalValue => orderTotal?.subTotal ?? totalPrice ?? 0.0;
  double get discountValue => orderTotal?.discount ?? 0.0;
  bool get hasDiscount => discountValue > 0;
}

class Items {
  String? productID;
  String? productName;
  int? quantity;
  double? price;
  String? variant;
  String? sId;
  String? note;

  Items({
    this.productID,
    this.productName,
    this.quantity,
    this.price,
    this.variant,
    this.sId,
    this.note,
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim().replaceAll(',', ''));
    return null;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final s = v.trim().replaceAll(',', '');
      return int.tryParse(s) ?? double.tryParse(s)?.toInt();
    }
    return null;
  }

  factory Items.fromJson(Map<String, dynamic> json) => Items(
    productID: json['productID']?.toString(),
    productName: json['productName']?.toString(),
    quantity: _toInt(json['quantity']),
    price: _toDouble(json['price']),
    variant: json['variant']?.toString(),
    sId: (json['id'] ?? json['_id'])?.toString(),
    note: json['note']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'productID': productID,
    'productName': productName,
    'quantity': quantity,
    'price': price,
    'variant': variant,
    'id': sId,
    'note': note,
  };
}

class ShippingAddress {
  String? phone;
  String? street; // نام مشتری
  String? state; // آدرس
  String? tableNumber;

  ShippingAddress({this.phone, this.street, this.state, this.tableNumber});

  factory ShippingAddress.fromJson(Map<String, dynamic> json) => ShippingAddress(
    phone: json['phone']?.toString(),
    street: json['street']?.toString(),
    state: json['state']?.toString(),
    tableNumber: json['tableNumber']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'street': street,
    'state': state,
    'tableNumber': tableNumber,
  };
}

class OrderTotal {
  double? subTotal;
  double? discount;
  double? total;

  OrderTotal({this.subTotal, this.discount, this.total});

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim().replaceAll(',', ''));
    return null;
  }

  factory OrderTotal.fromJson(Map<String, dynamic> json) => OrderTotal(
    subTotal: _toDouble(json['subTotal']),
    discount: _toDouble(json['discount']),
    total: _toDouble(json['total']),
  );

  Map<String, dynamic> toJson() => {
    'subTotal': subTotal,
    'discount': discount,
    'total': total,
  };
}
