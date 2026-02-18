
class Category {
  String? sId;
  String? name;
  String? image;
  String? phoneNumberCode; // ← اضافه کن
  String? createdAt;
  String? updatedAt;

  Category({
    this.sId,
    this.name,
    this.image,
    this.phoneNumberCode,
    this.createdAt,
    this.updatedAt,
  });

  Category.fromJson(Map<String, dynamic> json) {
    final rawId = json[r'$id'] ?? json['id'];
    sId = rawId?.toString();

    name = json['name']?.toString();
    image = json['imageUrl']?.toString();
    phoneNumberCode = (json['phone_number_code'] ?? json['phoneNumberCode'])?.toString(); // ← اضافه کن

    final rawCreated = json[r'$createdAt'] ?? json['createdAt'] ?? json['created'];
    createdAt = rawCreated?.toString();

    final rawUpdated = json[r'$updatedAt'] ?? json['updatedAt'] ?? json['updated'];
    updatedAt = rawUpdated?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = sId;
    data['name'] = name;
    data['imageUrl'] = image;
    data['phone_number_code'] = phoneNumberCode; // ← اضافه کن
    data['created'] = createdAt;
    data['updated'] = updatedAt;
    return data;
  }
}
