
import 'package:flutter/foundation.dart';

/// یک Ref سبک برای نمایش نام دسته/زیر‌دسته در UI
@immutable
class ProductRef {
  final String? sId;
  final String? name;

  const ProductRef({this.sId, this.name});

  factory ProductRef.fromJson(dynamic json) {
    if (json == null) return const ProductRef();
    if (json is Map) {
      final m = json.cast<String, dynamic>();
      return ProductRef(
        sId: (m['\$id'] ?? m['id'] ?? m['sId'])?.toString(),
        name: m['name']?.toString(),
      );
    }
    // اگر فقط id ارسال شده باشد
    return ProductRef(sId: json.toString());
  }

  Map<String, dynamic> toJson() => {
    'id': sId,
    'name': name,
  };
}

class Product {
  // ---------- Appwrite meta
  String? sId;
  String? createdAt;
  String? updatedAt;

  // ---------- fields
  String? name;
  String? description;

  /// شما در UI به صورت String کار می‌کنی
  String? quantity;
  String? price;
  String? offerPrice;

  String? phoneNumberCode;

  /// مطابق جدول: imageUrls[]
  List<String> imageUrls;

  // ---------- ids (طبق جدول: categories_id, subcategories_id, variantType_id, brands_id)
  String? categoryId;
  String? subCategoryId;
  String? variantTypeId;
  String? brandId;

  /// مطابق جدول: variants_id[] (و همچنین relation variants)
  List<String> variantIds;

  // ---------- hydrated (برای UI)
  /// این‌ها را DataProvider می‌تواند پر کند (اختیاری)
  String? resolvedCategoryName;
  String? resolvedSubCategoryName;

  /// اگر از بک‌اند/مهاجرت قبلی چیزی مثل category_obj داشتی
  ProductRef? categoryObj;
  ProductRef? subCategoryObj;

  Product({
    this.sId,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.description,
    this.quantity,
    this.price,
    this.offerPrice,
    this.phoneNumberCode,
    List<String>? imageUrls,
    this.categoryId,
    this.subCategoryId,
    this.variantTypeId,
    this.brandId,
    List<String>? variantIds,
    this.resolvedCategoryName,
    this.resolvedSubCategoryName,
    this.categoryObj,
    this.subCategoryObj,
  })  : imageUrls = imageUrls ?? <String>[],
        variantIds = variantIds ?? <String>[];

  // ---------------------------------------------------------------------------
  // ✅ سازگاری با کدهای قدیمی که product.variants صدا می‌زنند
  List<String> get variants => variantIds;
  set variants(List<String> value) => variantIds = List<String>.from(value);

  // ✅ سازگاری با کدهای قدیمی که product.proCategoryId?.name و proSubCategoryId?.name دارند
  ProductRef? get proCategoryId => categoryObj;
  ProductRef? get proSubCategoryId => subCategoryObj;
  // ---------------------------------------------------------------------------

  // ---------- JSON helpers
  static List<String> _asStringList(dynamic v) {
    if (v == null) return <String>[];
    if (v is List) {
      return v.map((e) => e.toString()).toList();
    }
    // اگر یک مقدار تکی باشد
    return <String>[v.toString()];
  }

  static String? _asString(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Appwrite meta
    final id = _asString(json[r'$id'] ?? json['id'] ?? json['sId']);
    final created = _asString(json[r'$createdAt'] ?? json['createdAt'] ?? json['created']);
    final updated = _asString(json[r'$updatedAt'] ?? json['updatedAt'] ?? json['updated']);

    // images: ممکن است imageUrls یا imageUrl داشته باشی
    final imgs = _asStringList(json['imageUrls'] ?? json['imageUrl']);

    // relations / ids:
    // categories: relation (list) / categories_id: string
    final categoriesRel = _asStringList(json['categories']);
    final subcategoriesRel = _asStringList(json['subcategories']);
    final variantTypeRel = _asStringList(json['variantType']);
    final variantsRel = _asStringList(json['variants']);

    final categoryId = _asString(json['categories_id']) ?? (categoriesRel.isNotEmpty ? categoriesRel.first : null);
    final subCategoryId =
        _asString(json['subcategories_id']) ?? (subcategoriesRel.isNotEmpty ? subcategoriesRel.first : null);
    final variantTypeId =
        _asString(json['variantType_id']) ?? (variantTypeRel.isNotEmpty ? variantTypeRel.first : null);

    // brand (فقط brands_id طبق خواسته تو)
    final brandId = _asString(json['brands_id']) ?? _asString(json['brandId']) ?? _asString(json['brand']);

    // variants_id[] یا relation variants
    final variantIds = _asStringList(json['variants_id'] ?? json['variants_id[]']);
    final finalVariantIds = variantIds.isNotEmpty ? variantIds : variantsRel;

    // اگر آبجکت‌های آماده داشته باشی
    final ProductRef? catObj = json['category_obj'] != null ? ProductRef.fromJson(json['category_obj']) : null;
    final ProductRef? subObj = json['subcategory_obj'] != null ? ProductRef.fromJson(json['subcategory_obj']) : null;

    return Product(
      sId: id,
      createdAt: created,
      updatedAt: updated,
      name: _asString(json['name']),
      description: _asString(json['description']),
      quantity: _asString(json['quantity']),
      price: _asString(json['price']),
      offerPrice: _asString(json['offer_price'] ?? json['offerPrice']),
      phoneNumberCode: _asString(json['phone_number_code']),
      imageUrls: imgs,
      categoryId: categoryId,
      subCategoryId: subCategoryId,
      variantTypeId: variantTypeId,
      brandId: brandId,
      variantIds: finalVariantIds,
      categoryObj: catObj,
      subCategoryObj: subObj,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': sId,
    'name': name,
    'description': description,
    'quantity': quantity,
    'price': price,
    'offer_price': offerPrice,
    'phone_number_code': phoneNumberCode,
    'imageUrls': imageUrls,
    'categories_id': categoryId,
    'subcategories_id': subCategoryId,
    'variantType_id': variantTypeId,
    'brands_id': brandId,
    'variants_id': variantIds,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'resolvedCategoryName': resolvedCategoryName,
    'resolvedSubCategoryName': resolvedSubCategoryName,
    if (categoryObj != null) 'category_obj': categoryObj!.toJson(),
    if (subCategoryObj != null) 'subcategory_obj': subCategoryObj!.toJson(),
  };

  /// این همون چیزیه که باید به Appwrite create/update بدی
  /// (هم relation ها رو می‌فرستیم هم *_id ها رو برای سازگاری)
  Map<String, dynamic> toAppwriteData({required bool forUpdate}) {
    final variantIdsClean = (variantIds)
        .where((e) => e.trim().isNotEmpty)
        .toList();

    final catId = (categoryId ?? '').trim();
    final subId = (subCategoryId ?? '').trim();
    final vtId = (variantTypeId ?? '').trim();
    final brId = (brandId ?? '').trim();

    final data = <String, dynamic>{
      'name': name?.trim() ?? '',
      'description': description?.trim() ?? '',
      'quantity': quantity?.trim() ?? '',
      'price': price?.trim() ?? '',
      'offer_price': (offerPrice ?? '').trim(),
      'phone_number_code': phoneNumberCode ?? '12345',
      'imageUrls': imageUrls, // ✅ همین الان درست شده

      // ✅ فیلدهای *_id که داری
      'variants_id': variantIdsClean,
      'variantType_id': vtId,
      'categories_id': catId,
      'subcategories_id': subId,
      'brands_id': brId,

      // ✅ IMPORTANT: فیلدهای Relation (Many-to-many) برای اینکه داخل Appwrite Items بخورد
      'variants': variantIdsClean,                       // many-to-many
      'variantType': vtId.isEmpty ? [] : [vtId],         // چون many-to-many است باید لیست باشد
      'categories': catId.isEmpty ? [] : [catId],        // چون many-to-many است باید لیست باشد
      'subcategories': subId.isEmpty ? [] : [subId],     // چون many-to-many است باید لیست باشد
    };

    return data;
  }

  Product copyWith({
    String? sId,
    String? createdAt,
    String? updatedAt,
    String? name,
    String? description,
    String? quantity,
    String? price,
    String? offerPrice,
    String? phoneNumberCode,
    List<String>? imageUrls,
    String? categoryId,
    String? subCategoryId,
    String? variantTypeId,
    String? brandId,
    List<String>? variantIds,
    String? resolvedCategoryName,
    String? resolvedSubCategoryName,
    ProductRef? categoryObj,
    ProductRef? subCategoryObj,
  }) {
    return Product(
      sId: sId ?? this.sId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      offerPrice: offerPrice ?? this.offerPrice,
      phoneNumberCode: phoneNumberCode ?? this.phoneNumberCode,
      imageUrls: imageUrls ?? List<String>.from(this.imageUrls),
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      variantTypeId: variantTypeId ?? this.variantTypeId,
      brandId: brandId ?? this.brandId,
      variantIds: variantIds ?? List<String>.from(this.variantIds),
      resolvedCategoryName: resolvedCategoryName ?? this.resolvedCategoryName,
      resolvedSubCategoryName: resolvedSubCategoryName ?? this.resolvedSubCategoryName,
      categoryObj: categoryObj ?? this.categoryObj,
      subCategoryObj: subCategoryObj ?? this.subCategoryObj,
    );
  }
}
