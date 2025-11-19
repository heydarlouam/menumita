


class Order {
  ShippingAddress? shippingAddress;
  OrderTotal? orderTotal;
  String? sId;
  dynamic userID;
  String? orderStatus;
  List<Items>? items;
  double? totalPrice;
  String? paymentMethod;
  dynamic couponCode;
  String? trackingUrl;
  String? orderDate;
  Map<String, dynamic>? user;
  Map<String, dynamic>? coupon;
  String? orderMode;
  String? tableNumber;
  Order({
    this.shippingAddress,
    this.orderTotal,
    this.sId,
    this.userID,
    this.orderStatus,
    this.items,
    this.totalPrice,
    this.orderMode,
    this.tableNumber,
    this.paymentMethod,
    this.couponCode,
    this.trackingUrl,
    this.orderDate,
    this.user,
    this.coupon,
  });
  bool get isInPersonOrder => orderMode == 'in_person';
  bool get isOnlineOrder => orderMode == 'online';



  double get orderTotalValue {
    if (orderTotal is num) {
      return double.parse(orderTotal.toString());
    } else if (orderTotal is OrderTotal) {
      return (orderTotal as OrderTotal).total ?? 0.0;
    }
    return 0.0;
  }

  Order.fromJson(Map<String, dynamic> json) {
    shippingAddress = json['shippingAddress'] != null
        ? ShippingAddress.fromJson(json['shippingAddress'])
        : null;

    orderMode = (json['orderMode']?.toString().trim().toLowerCase());
    tableNumber = (json['tableNumber']?.toString().trim().toLowerCase());



    // 🔽 بهبود پردازش orderTotal
    if (json['orderTotal'] != null) {
      if (json['orderTotal'] is Map) {
        orderTotal = OrderTotal.fromJson(json['orderTotal']);
      } else if (json['orderTotal'] is num) {
        orderTotal = OrderTotal(
          total: json['orderTotal']?.toDouble(),
          subTotal: json['totalPrice']?.toDouble() ?? json['orderTotal']?.toDouble(),
          discount: 0.0,
        );
      }
    } else {
      // 🔽 منطق fallback بهتر
      orderTotal = OrderTotal(
        total: json['totalPrice']?.toDouble() ?? 0.0,
        subTotal: json['totalPrice']?.toDouble() ?? 0.0,
        discount: 0.0,
      );
    }


    // پردازش orderTotal
    // if (json['orderTotal'] != null) {
    //   if (json['orderTotal'] is Map) {
    //     orderTotal = OrderTotal.fromJson(json['orderTotal']);
    //   } else if (json['orderTotal'] is num) {
    //     orderTotal = OrderTotal(
    //       total: json['orderTotal']?.toDouble(),
    //       subTotal: json['totalPrice']?.toDouble() ?? json['orderTotal']?.toDouble(),
    //       discount: 0.0,
    //     );
    //   }
    // } else {
    //   orderTotal = OrderTotal(
    //     total: json['totalPrice']?.toDouble(),
    //     subTotal: json['totalPrice']?.toDouble(),
    //     discount: 0.0,
    //   );
    // }
    // orderMode = (json['orderMode']?.toString().trim().toLowerCase());
    // tableNumber = (json['tableNumber']?.toString().trim().toLowerCase());

    sId = json['id'];

    // پردازش userID
    if (json['userID'] is String) {
      userID = json['userID'];
    } else if (json['userID'] is Map) {
      userID = UserID.fromJson(json['userID']);
    } else {
      userID = null;
    }

    orderStatus = json['orderStatus'];

    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }

    totalPrice = json['totalPrice']?.toDouble();
    paymentMethod = json['paymentMethod'];

    // پردازش couponCode
    if (json['couponCode'] is String) {
      couponCode = json['couponCode'];
    } else if (json['couponCode'] is Map) {
      couponCode = CouponCode.fromJson(json['couponCode']);
    } else {
      couponCode = null;
    }

    trackingUrl = json['trackingUrl'];
    orderDate = json['orderDate'] ?? json['created'];

    // ذخیره داده‌های expand شده
    user = json['user'];
    coupon = json['coupon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (shippingAddress != null) {
      data['shippingAddress'] = shippingAddress!.toJson();
    }
    if (orderTotal != null) {
      data['orderTotal'] = orderTotal!.toJson();
    }
    data['id'] = sId;

    if (userID is UserID) {
      data['userID'] = (userID as UserID).toJson();
    } else {
      data['userID'] = userID;
    }

    data['orderStatus'] = orderStatus;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['totalPrice'] = totalPrice;
    data['paymentMethod'] = paymentMethod;

    if (couponCode is CouponCode) {
      data['couponCode'] = (couponCode as CouponCode).toJson();
    } else {
      data['couponCode'] = couponCode;
    }

    data['trackingUrl'] = trackingUrl;
    data['orderDate'] = orderDate;

    return data;
  }

  // متدهای کمکی برای دسترسی به داده‌ها
  String? get userName {
    if (user != null && user!['name'] != null && user!['name'].toString().isNotEmpty) {
      return user!['name'];
    }
    if (userID is UserID) {
      return (userID as UserID).name;
    }
    return 'Unknown User';
  }

  String? get userPhone {
    if (user != null) {
      return user!['phone_number'];
    }
    return null;
  }

  String? get userAddress {
    if (user != null) {
      return user!['address'];
    }
    return null;
  }

  String? get couponName {
    if (coupon != null) {
      return coupon!['couponCode'];
    }
    if (couponCode is CouponCode) {
      return (couponCode as CouponCode).couponCode;
    }
    return null;
  }

  String? get couponDiscount {
    if (coupon != null) {
      return '${coupon!['discountAmount']}%';
    }
    if (couponCode is CouponCode) {
      return '${(couponCode as CouponCode).discountAmount}%';
    }
    return null;
  }
}









class UserID {
  String? sId;
  String? name;

  UserID({this.sId, this.name});

  UserID.fromJson(Map<String, dynamic> json) {
    sId = json['id'] ?? json['_id']; // پشتیبانی از هر دو
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = sId;
    data['name'] = name;
    return data;
  }
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

  Items.fromJson(Map<String, dynamic> json) {
    productID = json['productID'];
    productName = json['productName'];
    quantity = json['quantity'];
    price = json['price']?.toDouble();
    variant = json['variant'];
    sId = json['id'] ?? json['_id']; // پشتیبانی از هر دو
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productID'] = productID;
    data['productName'] = productName;
    data['quantity'] = quantity;
    data['price'] = price;
    data['variant'] = variant;
    data['id'] = sId;
    data['note'] = note;
    return data;
  }
}

class CouponCode {
  String? sId;
  String? couponCode;
  String? discountType;
  int? discountAmount;

  CouponCode({
    this.sId,
    this.couponCode,
    this.discountType,
    this.discountAmount,
  });

  CouponCode.fromJson(Map<String, dynamic> json) {
    sId = json['id'] ?? json['_id']; // پشتیبانی از هر دو
    couponCode = json['couponCode'];
    discountType = json['discountType'];
    discountAmount = json['discountAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = sId;
    data['couponCode'] = couponCode;
    data['discountType'] = discountType;
    data['discountAmount'] = discountAmount;
    return data;
  }
}




class ShippingAddress {
  String? phone;
  String? street;

   String? state;

  String? tableNumber;

  ShippingAddress(
      {this.phone,
        this.street,
        this.tableNumber,

         this.state,

      });

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    street = json['street'];
    tableNumber = json['tableNumber'];

    state = json['state'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone'] = this.phone;
    data['street'] = this.street;

    data['state'] = this.state;
    data['tableNumber'] = this.tableNumber;

    return data;
  }
}


class OrderTotal {
  double? subTotal;
  double? discount;
  double? total;

  OrderTotal({this.subTotal, this.discount, this.total});

  OrderTotal.fromJson(Map<String, dynamic> json) {
    subTotal = json['subTotal']?.toDouble();
    discount = json['discount']?.toDouble();
    total = json['total']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subTotal'] = this.subTotal;
    data['discount'] = this.discount;
    data['total'] = this.total;
    return data;
  }
}



extension OrderTotalsExt on Order {
  bool get hasBreakdown => orderTotal is OrderTotal;

  double? get subTotalValueOrNull {
    if (orderTotal is OrderTotal) return (orderTotal as OrderTotal).subTotal;
    return null;
  }

  double? get discountValueOrNull {
    if (orderTotal is OrderTotal) return (orderTotal as OrderTotal).discount;
    return null;
  }

  double? get totalValueOrNull {
    if (orderTotal is OrderTotal) return (orderTotal as OrderTotal).total;
    if (orderTotal is num) return (orderTotal as num).toDouble();
    return totalPrice; // fallback
  }
}