


class Coupon {
  // ستون‌های واقعی Appwrite
  final String? id; // $id

  final String? discountType;
  final String? discountAmount;
  final String? minimumPurchaseAmount;
  final String? endDate;
  final String? status;
  final String? phoneNumberCode;

  // فقط همین ۳ تا
  final String? categoriesId;
  final String? subcategoriesId;
  final String? productsId;

  final String? createdAt;
  final String? updatedAt;

  const Coupon({
    this.id,
    this.discountType,
    this.discountAmount,
    this.minimumPurchaseAmount,
    this.endDate,
    this.status,
    this.phoneNumberCode,
    this.categoriesId,
    this.subcategoriesId,
    this.productsId,
    this.createdAt,
    this.updatedAt,
  });

  // ---- سازگاری با کدهای فعلی (بدون اطلاعات اضافی) ----
  String? get sId => id;
  String? get couponCode => id; // چون couponCode ستون ندارد و id کد است
  String? get applicableCategory => categoriesId;
  String? get applicableSubCategory => subcategoriesId;
  String? get applicableProduct => productsId;
  // -----------------------------------------------------

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: (json[r'$id'] ?? json['id'])?.toString(),
      discountType: json['discountType']?.toString(),
      discountAmount: json['discountAmount']?.toString(),
      minimumPurchaseAmount: json['minimumPurchaseAmount']?.toString(),
      endDate: json['endDate']?.toString(),
      status: json['status']?.toString(),
      phoneNumberCode:
      (json['phone_number_code'] ?? json['phoneNumberCode'])?.toString(),
      categoriesId: json['categories_id']?.toString(),
      subcategoriesId: json['subcategories_id']?.toString(),
      productsId: json['products_id']?.toString(),
      createdAt:
      (json[r'$createdAt']  ?? json['createdAt'])
          ?.toString(),
      updatedAt:
      (json[r'$updatedAt']  ?? json['updatedAt'])
          ?.toString(),
    );
  }

  // فقط ستون‌های واقعی جدول (برای create/update)
  Map<String, dynamic> toAppwriteData() {
    String? _nullIfEmpty(String? v) {
      final s = v?.trim() ?? '';
      return s.isEmpty ? null : s;
    }

    return <String, dynamic>{
      'discountType': (discountType ?? '').trim(),
      'discountAmount': (discountAmount ?? '').trim(),
      'minimumPurchaseAmount': (minimumPurchaseAmount ?? '').trim(),
      'endDate': (endDate ?? '').trim(),
      'status': (status ?? '').trim(),
      'phone_number_code': (phoneNumberCode ?? '').trim(),
      'categories_id': _nullIfEmpty(categoriesId),
      'subcategories_id': _nullIfEmpty(subcategoriesId),
      'products_id': _nullIfEmpty(productsId),
    };
  }
}
