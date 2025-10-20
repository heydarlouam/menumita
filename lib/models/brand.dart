
class Brand {
  String? sId;
  String? name;
  String? subcategory; // ID ساب‌کتگوری
  SubcategoryId? subCategoryId; // اطلاعات کامل ساب‌کتگوری
  String? createdAt;
  String? updatedAt;

  Brand({
    this.sId,
    this.name,
    this.subcategory,
    this.subCategoryId,
    this.createdAt,
    this.updatedAt,
  });

  Brand.fromJson(Map<String, dynamic> json) {
    sId = json['id'];
    name = json['name'];

    // پردازش فیلد subcategory
    if (json['subcategory'] is String) {
      subcategory = json['subcategory'];
    } else if (json['subcategory'] is Map<String, dynamic>) {
      subCategoryId = SubcategoryId.fromJson(json['subcategory']);
      subcategory = subCategoryId?.sId;
    }

    // پردازش expand برای دریافت اطلاعات کامل
    if (json['expand'] != null && json['expand']['subcategory'] != null) {
      subCategoryId = SubcategoryId.fromJson(json['expand']['subcategory']);
      subcategory ??= subCategoryId?.sId;
    }

    // اگر فقط subCategoryId داریم اما subcategory خالی است
    if (subcategory == null && subCategoryId != null) {
      subcategory = subCategoryId?.sId;
    }

    createdAt = json['created'];
    updatedAt = json['updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.sId;
    data['name'] = this.name;
    data['subcategory'] = this.subcategory; // فقط ID را بفرست
    data['created'] = this.createdAt;
    data['updated'] = this.updatedAt;
    return data;
  }
}

class SubcategoryId {
  String? sId;
  String? name;
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
    sId = json['id'];
    name = json['name'];
    category = json['category'];
    createdAt = json['created'];
    updatedAt = json['updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.sId;
    data['name'] = this.name;
    data['category'] = this.category;
    data['created'] = this.createdAt;
    data['updated'] = this.updatedAt;
    return data;
  }
}