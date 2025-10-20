

class SubCategory {
  String? sId;
  String? name;
  String? category; // تغییر از CategoryId به String برای ID
  CategoryId? categoryId; // برای زمانی که expand می‌شود
  String? createdAt;
  String? updatedAt;

  SubCategory({
    this.sId,
    this.name,
    this.category,
    this.categoryId,
    this.createdAt,
    this.updatedAt,
  });

  SubCategory.fromJson(Map<String, dynamic> json) {
    sId = json['id'];
    name = json['name'];

    // اگر category به صورت expand شده باشد
    if (json['category'] is Map<String, dynamic>) {
      categoryId = CategoryId.fromJson(json['category']);
      category = categoryId?.sId;
    } else if (json['category'] is String) {
      category = json['category'];
    }

    // اگر از expand استفاده شده باشد
    if (json['expand'] != null && json['expand']['category'] != null) {
      categoryId = CategoryId.fromJson(json['expand']['category']);
      category = categoryId?.sId;
    }

    createdAt = json['created'];
    updatedAt = json['updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.sId;
    data['name'] = this.name;
    data['category'] = this.category; // فقط ID را بفرست
    data['created'] = this.createdAt;
    data['updated'] = this.updatedAt;
    return data;
  }
}

class CategoryId {
  String? sId;
  String? name;

  CategoryId({this.sId, this.name});

  CategoryId.fromJson(Map<String, dynamic> json) {
    sId = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.sId;
    data['name'] = this.name;
    return data;
  }
}