
class Variant {
  String? sId;
  String? name;
  VariantTypeId? variantTypeId;
  String? createdAt;
  String? updatedAt;

  Variant({
    this.sId,
    this.name,
    this.variantTypeId,
    this.createdAt,
    this.updatedAt,
  });

  Variant.fromJson(Map<String, dynamic> json) {
    sId = json['id'];
    name = json['name'];
    variantTypeId = json['variant_type'] != null
        ? new VariantTypeId.fromJson(json['variant_type'])
        : null;
    createdAt = json['created'];
    updatedAt = json['updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.sId;
    data['name'] = this.name;
    if (this.variantTypeId != null) {
      data['variant_type'] = this.variantTypeId!.toJson();
    }
    data['created'] = this.createdAt;
    data['updated'] = this.updatedAt;
    return data;
  }
}

class VariantTypeId {
  String? sId;
  String? name;
  String? type;
  String? createdAt;
  String? updatedAt;

  VariantTypeId({
    this.sId,
    this.name,
    this.type,
    this.createdAt,
    this.updatedAt
  });

  VariantTypeId.fromJson(Map<String, dynamic> json) {
    sId = json['id'];
    name = json['name'];
    type = json['type'];
    createdAt = json['created'];
    updatedAt = json['updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.sId;
    data['name'] = this.name;
    data['type'] = this.type;
    data['created'] = this.createdAt;
    data['updated'] = this.updatedAt;
    return data;
  }
}