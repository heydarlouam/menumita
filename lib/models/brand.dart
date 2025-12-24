
class Brand {
  String? sId;
  String? name;

  /// Appwrite: phone_number_code (required)
  String? phoneNumberCode;

  /// تک‌ساب‌کتگوری (ID) - چیزی که UI و Provider با آن کار می‌کنند
  /// اولویت خواندن: subcategories_id -> سپس subcategories[0]
  String? subcategory;

  /// مقدار خام ستون subcategories_id
  String? subcategoriesId;

  /// برای سازگاری/دیباگ: رابطه many-to-many (ولی در عمل یک آیتم)
  List<String> subcategoryIds;

  /// برای نمایش نام ساب‌کتگوری در لیست (از DataProvider مپ می‌شود)
  SubcategoryId? subCategoryId;

  String? createdAt;
  String? updatedAt;

  Brand({
    this.sId,
    this.name,
    this.phoneNumberCode,
    this.subcategory,
    this.subcategoriesId,
    List<String>? subcategoryIds,
    this.subCategoryId,
    this.createdAt,
    this.updatedAt,
  }) : subcategoryIds = subcategoryIds ?? <String>[];

  Brand.fromJson(Map<String, dynamic> json) : subcategoryIds = <String>[] {
    // ---------- id ----------
    final rawId = json[r'$id']  ?? json['id'];
    sId = rawId?.toString();

    // ---------- fields ----------
    name = json['name']?.toString();
    phoneNumberCode =
        (json['phone_number_code'] ?? json['phoneNumberCode'])?.toString();

    // ---------- timestamps ----------
    createdAt = (json[r'$createdAt'] ?? json['$createdAt'] ?? json['createdAt'] ?? json['created'])
        ?.toString();
    updatedAt = (json[r'$updatedAt'] ?? json['$updatedAt'] ?? json['updatedAt'] ?? json['updated'])
        ?.toString();

    // ---------- primary: subcategories_id ----------
    final rawSubId = json['subcategories_id'];
    if (rawSubId != null && rawSubId.toString().trim().isNotEmpty) {
      subcategoriesId = rawSubId.toString();
      subcategory = subcategoriesId;
    }

    // ---------- fallback: relation subcategories ----------
    final rel = json['subcategories'];
    if (rel is List && rel.isNotEmpty) {
      // همه IDها را استخراج کنیم
      subcategoryIds = _extractIds(rel);

      // اگر هنوز subcategory نداریم، از اولین آیتم بردار
      if (subcategory == null && subcategoryIds.isNotEmpty) {
        subcategory = subcategoryIds.first;
      }

      // اگر expand به شکل map آمده بود (گاهی)، نام را هم بردار
      final first = rel.first;
      if (first is Map<String, dynamic>) {
        subCategoryId = SubcategoryId.fromJson(first);
        subcategory ??= subCategoryId?.sId;
      }
    }

    // ---------- legacy: subcategory ----------
    if (subcategory == null) {
      final legacy = json['subcategory'];
      if (legacy is String && legacy.trim().isNotEmpty) {
        subcategory = legacy;
        subcategoryIds = <String>[legacy];
      } else if (legacy is Map<String, dynamic>) {
        subCategoryId = SubcategoryId.fromJson(legacy);
        subcategory = subCategoryId?.sId;
        if (subcategory != null) subcategoryIds = <String>[subcategory!];
      }
    }

    // یکدست‌سازی
    subcategoriesId ??= subcategory;
    if (subcategory != null && subcategoryIds.isEmpty) {
      subcategoryIds = <String>[subcategory!];
    }

    // اگر فقط ID داریم، یک ref بساز (برای منطق‌های UI)
    subCategoryId ??= (subcategory == null ? null : SubcategoryId(sId: subcategory));
  }

  /// فقط فیلدهای موجود در Appwrite را ارسال کن
  /// (ارسال فیلدهای اضافی ممکن است خطا بدهد)
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (phoneNumberCode != null) data['phone_number_code'] = phoneNumberCode;

    if (subcategory != null && subcategory!.trim().isNotEmpty) {
      // ✅ سینک همزمان هر دو ستون
      data['subcategories_id'] = subcategory;
      data['subcategories'] = <String>[subcategory!];
    }

    return data;
  }

  static List<String> _extractIds(List rawList) {
    final out = <String>[];
    for (final e in rawList) {
      if (e is String && e.trim().isNotEmpty) {
        out.add(e);
      } else if (e is Map<String, dynamic>) {
        final id = (e[r'$id'] ?? e['id'])?.toString();
        if (id != null && id.trim().isNotEmpty) out.add(id);
      } else {
        // اگر Document از SDK باشد
        try {
          final dynamic d = e;
          final dynamic did = d.$id;
          if (did != null) out.add(did.toString());
        } catch (_) {}
      }
    }
    return out;
  }
}

class SubcategoryId {
  String? sId;
  String? name;

  // اختیاری (اگر جایی نیاز شد)
  String? category;
  String? createdAt;
  String? updatedAt;

  SubcategoryId({
    this.sId,
    this.name,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  SubcategoryId.fromJson(Map<String, dynamic> json) {
    sId = (json[r'$id'] ?? json['id'])?.toString();
    name = json['name']?.toString();
    category = json['category']?.toString();

    createdAt = (json[r'$createdAt'] ?? json['createdAt'] ?? json['created'])?.toString();
    updatedAt = (json[r'$updatedAt'] ?? json['updatedAt'] ?? json['updated'])?.toString();
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': sId,
    'name': name,
    'category': category,
    'created': createdAt,
    'updated': updatedAt,
  };
}
