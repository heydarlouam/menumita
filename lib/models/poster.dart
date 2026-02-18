

class Poster {
  String? sId;
  String? posterName;
  String? imageUrl;
  String? imageId;
  String? phoneNumberCode; // ← اضافه کن
  String? createdAt;
  String? updatedAt;

  Poster({
    this.sId,
    this.posterName,
    this.imageUrl,
    this.imageId,
    this.phoneNumberCode,
    this.createdAt,
    this.updatedAt,
  });

  Poster.fromJson(Map<String, dynamic> json) {
    final rawId = json[r'$id'] ?? json['id'];
    sId = rawId?.toString();

    posterName = (json['poster_name'] ?? json['name'])?.toString();
    imageUrl = (json['imageUrl'] ?? json['image'] ?? json['poster_image'])?.toString();
    imageId = json['imageId']?.toString();
    phoneNumberCode = (json['phone_number_code'] ?? json['phoneNumberCode'])?.toString(); // ← اضافه کن

    final rawCreated = json[r'$createdAt'] ?? json['createdAt'] ?? json['created'];
    createdAt = rawCreated?.toString();

    final rawUpdated = json[r'$updatedAt'] ?? json['updatedAt'] ?? json['updated'];
    updatedAt = rawUpdated?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = sId;
    data['poster_name'] = posterName;
    data['imageUrl'] = imageUrl;
    data['imageId'] = imageId;
    data['phone_number_code'] = phoneNumberCode; // ← اضافه کن
    data['created'] = createdAt;
    data['updated'] = updatedAt;
    return data;
  }
}