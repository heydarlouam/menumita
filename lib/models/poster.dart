
class Poster {
  String? sId;
  String? posterName;
  String? imageUrl;  // 🔴 مشکل اینجاست!
  String? imageId;   // 🔴 این هم اضافه شود
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
    sId = json['id'];
    posterName = json['poster_name'];

    // 🔴 اصلاح این بخش - سرور imageUrl می‌فرستد نه image
    imageUrl = json['imageUrl'] ?? json['image']; // اول imageUrl را چک کن
    imageId = json['imageId'] ?? json['image'];   // imageId هم اضافه شد

    createdAt = json['created'];
    updatedAt = json['updated'];

    print('🔄 Parsing Poster - imageUrl: $imageUrl, imageId: $imageId');
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