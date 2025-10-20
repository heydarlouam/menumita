

class Category {
  String? sId;
  String? name;
  String? image;
  String? createdAt;
  String? updatedAt;

  Category({this.sId, this.name, this.image, this.createdAt, this.updatedAt});

  Category.fromJson(Map<String, dynamic> json) {
    sId = json['id'];
    name = json['name'];
    image = json['imageUrl'];
    createdAt = json['created']; // 🔄 تغییر به 'created'
    updatedAt = json['updated']; // 🔄 تغییر به 'updated'
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.sId;
    data['name'] = this.name;
    data['imageUrl'] = this.image;
    data['created'] = this.createdAt; // 🔄 تغییر به 'created'
    data['updated'] = this.updatedAt; // 🔄 تغییر به 'updated'
    return data;
  }
}