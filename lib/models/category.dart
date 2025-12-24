
class Category {
  String? sId;
  String? name;
  String? image;
  String? createdAt;
  String? updatedAt;

  Category({
    this.sId,
    this.name,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  Category.fromJson(Map<String, dynamic> json) {
    // id
    final rawId = json[r'$id'] ?? json['id'];
    sId = rawId?.toString();

    // name
    name = json['name']?.toString();

    // imageUrl
    image = json['imageUrl']?.toString();

    // createdAt
    final rawCreated =
        json[r'$createdAt'] ?? json['createdAt'] ?? json['created'];
    createdAt = rawCreated?.toString();

    // updatedAt
    final rawUpdated =
        json[r'$updatedAt'] ?? json['updatedAt'] ?? json['updated'];
    updatedAt = rawUpdated?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = sId;
    data['name'] = name;
    data['imageUrl'] = image;
    data['created'] = createdAt;
    data['updated'] = updatedAt;
    return data;
  }
}
