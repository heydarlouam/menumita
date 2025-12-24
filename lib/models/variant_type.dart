

class VariantType {
  String? sId;
  String? name;
  String? type;

  /// required در Appwrite
  String? phoneNumberCode;

  /// relations
  List<String> variantIds;
  List<String> productIds;

  String? createdAt;
  String? updatedAt;

  VariantType({
    this.sId,
    this.name,
    this.type,
    this.phoneNumberCode,
    List<String>? variantIds,
    List<String>? productIds,
    this.createdAt,
    this.updatedAt,
  })  : variantIds = variantIds ?? <String>[],
        productIds = productIds ?? <String>[];

  VariantType.fromJson(Map<String, dynamic> json)
      : variantIds = <String>[],
        productIds = <String>[] {
    sId = (json[r'$id']  ?? json['id'])?.toString();
    name = json['name']?.toString();
    type = json['type']?.toString();

    phoneNumberCode =
        (json['phone_number_code'] ?? json['phoneNumberCode'])?.toString();

    createdAt = (json[r'$createdAt'] ?? json['$createdAt'] ?? json['createdAt'])
        ?.toString();
    updatedAt = (json[r'$updatedAt'] ?? json['$updatedAt'] ?? json['updatedAt'])
        ?.toString();

    variantIds = _extractIds(json['variants']);
    productIds = _extractIds(json['products']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (type != null) data['type'] = type;
    if (phoneNumberCode != null) data['phone_number_code'] = phoneNumberCode;

    if (variantIds.isNotEmpty) data['variants'] = variantIds;
    if (productIds.isNotEmpty) data['products'] = productIds;

    return data;
  }

  static List<String> _extractIds(dynamic raw) {
    if (raw == null) return <String>[];
    if (raw is List) {
      final out = <String>[];
      for (final e in raw) {
        if (e is String && e.trim().isNotEmpty) out.add(e);
        if (e is Map<String, dynamic>) {
          final id = (e[r'$id']  ?? e['id'])?.toString();
          if (id != null && id.trim().isNotEmpty) out.add(id);
        }
      }
      return out;
    }
    if (raw is String && raw.trim().isNotEmpty) return <String>[raw];
    return <String>[];
  }
}
