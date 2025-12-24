
class Poster {
  String? sId;
  String? posterName;
  String? imageUrl;
  String? imageId;   // در صورت نیاز: نگه‌داشتن fileId
  String? createdAt;
  String? updatedAt;

  Poster({
    this.sId,
    this.posterName,
    this.imageUrl,
    this.imageId,
    this.createdAt,
    this.updatedAt,
  });

  Poster.fromJson(Map<String, dynamic> json) {
    // id: هم Appwrite ($id) هم بک‌اند قدیمی (id)
    final rawId = json[r'$id'] ?? json['id'];
    sId = rawId?.toString();

    // name: بک‌اند قدیمی → poster_name ، Appwrite → name
    posterName = (json['poster_name'] ?? json['name'])?.toString();

    // imageUrl: ممکن است imageUrl یا image یا poster_image باشد
    imageUrl =
        (json['imageUrl'] ?? json['image'] ?? json['poster_image'])?.toString();

    // اگر از جایی imageId داشته باشیم
    imageId = json['imageId']?.toString();

    final rawCreated =
        json[r'$createdAt'] ?? json['createdAt'] ?? json['created'];
    createdAt = rawCreated?.toString();

    final rawUpdated =
        json[r'$updatedAt'] ?? json['updatedAt'] ?? json['updated'];
    updatedAt = rawUpdated?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = sId;
    data['poster_name'] = posterName;
    data['imageUrl'] = imageUrl;
    data['imageId'] = imageId;
    data['created'] = createdAt;
    data['updated'] = updatedAt;
    return data;
  }
}
