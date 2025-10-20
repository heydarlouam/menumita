
class Product {
  String? sId;
  String? name;
  String? description;
  int? quantity;
  double? price;
  double? offerPrice;
  ProRef? proCategoryId;
  ProRef? proSubCategoryId;
  ProRef? proBrandId;
  ProTypeRef? proVariantTypeId;
  List<String>? proVariantId;
  List<Images>? images;
  String? createdAt;
  String? updatedAt;

  Product({
    this.sId,
    this.name,
    this.description,
    this.quantity,
    this.price,
    this.offerPrice,
    this.proCategoryId,
    this.proSubCategoryId,
    this.proBrandId,
    this.proVariantTypeId,
    this.proVariantId,
    this.images,
    this.createdAt,
    this.updatedAt,
  });

  Product.fromJson(Map<String, dynamic> json) {
    sId = json['id'];
    name = json['name'];
    description = json['description'];
    quantity = json['quantity'];
    price = json['price']?.toDouble();
    offerPrice = json['offer_price']?.toDouble();

    // تبدیل category به proCategoryId
    proCategoryId = json['category'] != null
        ? ProRef.fromJson({
      '_id': json['category']['id'],
      'name': json['category']['name']
    })
        : null;

    // تبدیل subcategory به proSubCategoryId
    proSubCategoryId = json['subcategory'] != null
        ? ProRef.fromJson({
      '_id': json['subcategory']['id'],
      'name': json['subcategory']['name']
    })
        : null;

    // تبدیل brand به proBrandId
    proBrandId = json['brand'] != null
        ? ProRef.fromJson({
      '_id': json['brand']['id'],
      'name': json['brand']['name']
    })
        : null;

    // تبدیل variant_type به proVariantTypeId
    proVariantTypeId = json['variant_type'] != null
        ? ProTypeRef.fromJson({
      '_id': json['variant_type']['id'],
      'name': json['variant_type']['name'], // تغییر: 'name' به جای 'type'
      'type': json['variant_type']['type']
    })
        : null;

    // تبدیل variants به proVariantId - استفاده از variantsIds به جای variants
    if (json['variantsIds'] != null) {
      proVariantId = List<String>.from(json['variantsIds']);
    } else {
      proVariantId = [];
    }

    // تبدیل images - استفاده از imagesIds برای لیست IDها و images برای اطلاعات کامل
    if (json['images'] != null) {
      images = <Images>[];
      (json['images'] as List).forEach((v) {
        images!.add(Images.fromJson({
          '_id': v['id'],
          'name': v['name'], // اضافه کردن name
          'url': v['url']
        }));
      });
    } else {
      images = [];
    }

    createdAt = json['created'];
    updatedAt = json['updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.sId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['offer_price'] = this.offerPrice;

    if (this.proCategoryId != null) {
      data['category'] = {
        'id': this.proCategoryId!.sId,
        'name': this.proCategoryId!.name
      };
    }

    if (this.proSubCategoryId != null) {
      data['subcategory'] = {
        'id': this.proSubCategoryId!.sId,
        'name': this.proSubCategoryId!.name
      };
    }

    if (this.proBrandId != null) {
      data['brand'] = {
        'id': this.proBrandId!.sId,
        'name': this.proBrandId!.name
      };
    }

    if (this.proVariantTypeId != null) {
      data['variant_type'] = {
        'id': this.proVariantTypeId!.sId,
        'name': this.proVariantTypeId!.name, // اضافه کردن name
        'type': this.proVariantTypeId!.type
      };
    }

    data['variantsIds'] = this.proVariantId;

    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }

    data['created'] = this.createdAt;
    data['updated'] = this.updatedAt;

    return data;
  }
}

class ProRef {
  String? sId;
  String? name;

  ProRef({this.sId, this.name});

  ProRef.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    return data;
  }
}

class ProTypeRef {
  String? sId;
  String? name; // اضافه کردن فیلد name
  String? type;

  ProTypeRef({this.sId, this.name, this.type});

  ProTypeRef.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name']; // اضافه کردن name
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name; // اضافه کردن name
    data['type'] = this.type;
    return data;
  }
}

class Images {
  String? sId;
  String? name; // اضافه کردن فیلد name
  String? url;

  Images({this.sId, this.name, this.url});

  Images.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name']; // اضافه کردن name
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name; // اضافه کردن name
    data['url'] = this.url;
    return data;
  }
}