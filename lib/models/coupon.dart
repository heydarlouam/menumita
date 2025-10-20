

class Coupon {
  String? sId;
  String? collectionId;
  String? collectionName;
  String? created;
  String? updated;
  String? couponCode;
  String? discountType;
  double? discountAmount;
  double? minimumPurchaseAmount;
  String? endDate;
  String? status;
  String? applicableCategory; // تغییر به String برای ID
  String? applicableSubCategory; // تغییر به String برای ID
  String? applicableProduct; // تغییر به String برای ID
  Expand? expand; // اضافه شدن expand

  Coupon({
    this.sId,
    this.collectionId,
    this.collectionName,
    this.created,
    this.updated,
    this.couponCode,
    this.discountType,
    this.discountAmount,
    this.minimumPurchaseAmount,
    this.endDate,
    this.status,
    this.applicableCategory,
    this.applicableSubCategory,
    this.applicableProduct,
    this.expand,
  });

  Coupon.fromJson(Map<String, dynamic> json) {
    sId = json['id'];
    collectionId = json['collectionId'];
    collectionName = json['collectionName'];
    created = json['created'];
    updated = json['updated'];
    couponCode = json['couponCode'];
    discountType = json['discountType'];
    discountAmount = json['discountAmount']?.toDouble();
    minimumPurchaseAmount = json['minimumPurchaseAmount']?.toDouble();
    endDate = json['endDate'];
    status = json['status'];

    // تبدیل فیلدهای خالی به null - مطابق با سرور
    applicableCategory = json['applicableCategory'] == "" ? null : json['applicableCategory'];
    applicableSubCategory = json['applicableSubCategory'] == "" ? null : json['applicableSubCategory'];
    applicableProduct = json['applicableProduct'] == "" ? null : json['applicableProduct'];

    expand = json['expand'] != null ? Expand.fromJson(json['expand']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.sId;
    data['collectionId'] = this.collectionId;
    data['collectionName'] = this.collectionName;
    data['created'] = this.created;
    data['updated'] = this.updated;
    data['couponCode'] = this.couponCode;
    data['discountType'] = this.discountType;
    data['discountAmount'] = this.discountAmount;
    data['minimumPurchaseAmount'] = this.minimumPurchaseAmount;
    data['endDate'] = this.endDate;
    data['status'] = this.status;

    // تبدیل null به "" برای ارسال به سرور
    data['applicableCategory'] = this.applicableCategory ?? "";
    data['applicableSubCategory'] = this.applicableSubCategory ?? "";
    data['applicableProduct'] = this.applicableProduct ?? "";

    if (this.expand != null) {
      data['expand'] = this.expand!.toJson();
    }

    return data;
  }
}

class Expand {
  CatRef? applicableCategory;
  CatRef? applicableSubCategory;
  CatRef? applicableProduct;

  Expand({
    this.applicableCategory,
    this.applicableSubCategory,
    this.applicableProduct,
  });

  Expand.fromJson(Map<String, dynamic> json) {
    applicableCategory = json['applicableCategory'] != null
        ? CatRef.fromJson(json['applicableCategory'])
        : null;
    applicableSubCategory = json['applicableSubCategory'] != null
        ? CatRef.fromJson(json['applicableSubCategory'])
        : null;
    applicableProduct = json['applicableProduct'] != null
        ? CatRef.fromJson(json['applicableProduct'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.applicableCategory != null) {
      data['applicableCategory'] = this.applicableCategory!.toJson();
    }
    if (this.applicableSubCategory != null) {
      data['applicableSubCategory'] = this.applicableSubCategory!.toJson();
    }
    if (this.applicableProduct != null) {
      data['applicableProduct'] = this.applicableProduct!.toJson();
    }
    return data;
  }
}

class CatRef {
  String? sId;
  String? name;

  CatRef({this.sId, this.name});

  CatRef.fromJson(Map<String, dynamic> json) {
    sId = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.sId;
    data['name'] = this.name;
    return data;
  }
}