
class Variant {
  String? sId;
  String? name;

  /// required در Appwrite
  String? phoneNumberCode;

  /// هر Variant فقط یک VariantType دارد (تک‌انتخابی در UI)
  /// اولویت خواندن: variantType_id -> سپس variantType[0]
  String? variantType; // id

  /// مقدار خام ستون variantType_id
  String? variantTypeIdRaw;

  /// برای نمایش نام تایپ در لیست + preselect در فرم
  VariantTypeId? variantTypeId;

  /// relation products (فعلاً اختیاری)
  List<String> productIds;

  String? createdAt;
  String? updatedAt;

  Variant({
    this.sId,
    this.name,
    this.phoneNumberCode,
    this.variantType,
    this.variantTypeIdRaw,
    this.variantTypeId,
    List<String>? productIds,
    this.createdAt,
    this.updatedAt,
  }) : productIds = productIds ?? <String>[];

  Variant.fromJson(Map<String, dynamic> json) : productIds = <String>[] {
    sId = (json[r'$id']   ?? json['id'])?.toString();
    name = json['name']?.toString();

    phoneNumberCode =
        (json['phone_number_code'] ?? json['phoneNumberCode'])?.toString();

    // variantType_id (اولویت)
    final rawTypeId = json['variantType_id'];
    if (rawTypeId != null && rawTypeId.toString().trim().isNotEmpty) {
      variantTypeIdRaw = rawTypeId.toString();
      variantType = variantTypeIdRaw;
    }

    // relation variantType (fallback)
    if (variantType == null && json['variantType'] is List) {
      final list = (json['variantType'] as List);
      if (list.isNotEmpty) {
        final first = list.first;

        if (first is String && first.trim().isNotEmpty) {
          variantType = first;
        } else if (first is Map<String, dynamic>) {
          final id =
          (first[r'$id']  ?? first['id'])?.toString();
          variantType = id;
          variantTypeId = VariantTypeId.fromJson(first);
        }
      }
    }

    // اگر فقط ID داریم، حداقل یک ref بساز تا فرم بتواند preselect کند
    if (variantTypeId == null && variantType != null) {
      variantTypeId = VariantTypeId(sId: variantType);
    }

    productIds = _extractIds(json['products']);

    createdAt = (json[r'$createdAt'] ?? json['$createdAt'] ?? json['createdAt'])
        ?.toString();
    updatedAt = (json[r'$updatedAt'] ?? json['$updatedAt'] ?? json['updatedAt'])
        ?.toString();

    variantTypeIdRaw ??= variantType;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (phoneNumberCode != null) data['phone_number_code'] = phoneNumberCode;

    if (variantType != null && variantType!.trim().isNotEmpty) {
      // ✅ هر دو ستون باید پر شوند
      data['variantType_id'] = variantType;
      data['variantType'] = <String>[variantType!];
    }

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
          final id = (e[r'$id']    ?? e['id'])?.toString();
          if (id != null && id.trim().isNotEmpty) out.add(id);
        }
      }
      return out;
    }
    if (raw is String && raw.trim().isNotEmpty) return <String>[raw];
    return <String>[];
  }
}

class VariantTypeId {
  String? sId;
  String? name;
  String? type;

  VariantTypeId({this.sId, this.name, this.type});

  VariantTypeId.fromJson(Map<String, dynamic> json) {
    sId = (json[r'$id']   ?? json['id'])?.toString();
    name = json['name']?.toString();
    type = json['type']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': sId,
    'name': name,
    'type': type,
  };
}
