
class VariantType {
  String? sId;
  String? name;
  String? type;
  String? createdAt;
  String? updatedAt;

  VariantType({
    this.sId,
    this.name,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  VariantType.fromJson(Map<String, dynamic> json) {
    sId = json['id'];
    name = json['name'];
    type = json['type'];
    createdAt = json['created'];
    updatedAt = json['updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['type'] = this.type;
    data['id'] = this.sId;
    data['created'] = this.createdAt;
    data['updated'] = this.updatedAt;
    return data;
  }
}