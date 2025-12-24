
/// مدل SubCategory مطابق با اسکیمای Appwrite
///
/// نکته‌ی مهم در این پروژه:
/// - هر SubCategory دقیقاً یک Category دارد (تک‌انتخابی)
/// - در Appwrite هم‌زمان دو ستون پر می‌شود:
///   1) categories_id (String)
///   2) categories (Many-to-many) ولی با یک آیتم
class SubCategory {
  String? sId;
  String? name;

  /// مقدار ستون الزامی phone_number_code در Appwrite
  String? phoneNumberCode;

  /// شناسه‌ی کتگوری انتخاب‌شده (مرجع اصلی در کل اپ)
  ///
  /// این فیلد در خواندن داده، از `categories_id` اولویت می‌گیرد و اگر خالی باشد
  /// از اولین آیتم `categories` (Relation) استخراج می‌شود.
  String? category;

  /// مقدار خام ستون `categories_id` (برای دیباگ/سینک دقیق‌تر)
  String? categoriesId;

  /// اطلاعات کتگوری (وقتی از سرویس جداگانه دریافت و مپ می‌شود)
  CategoryId? categoryId;

  String? createdAt;
  String? updatedAt;

  SubCategory({
    this.sId,
    this.name,
    this.phoneNumberCode,
    this.category,
    this.categoriesId,
    this.categoryId,
    this.createdAt,
    this.updatedAt,
  });

  SubCategory.fromJson(Map<String, dynamic> json) {
    // ---------- IDs ----------
    final rawId = json[r'$id'] ?? json[r'$ID']  ?? json['id'];
    sId = rawId?.toString();

    name = json['name']?.toString();

    // ---------- Phone ----------
    phoneNumberCode =
        (json['phone_number_code'] ?? json['phoneNumberCode'])?.toString();

    // ---------- Timestamps ----------
    createdAt = (json[r'$createdAt'] ??
        json['createdAt'] ??
        json['created'] ??
        json['created_at'])
        ?.toString();

    updatedAt = (json[r'$updatedAt'] ??
        json['updatedAt'] ??
        json['updated'] ??
        json['updated_at'])
        ?.toString();

    // ---------- Category (priority: categories_id) ----------
    final rawCategoriesId = json['categories_id'];
    if (rawCategoriesId != null && rawCategoriesId.toString().trim().isNotEmpty) {
      categoriesId = rawCategoriesId.toString();
      category = categoriesId;
    }

    // ---------- Backward compatibility (اگر جایی "category" بود) ----------
    // برخی سورس‌های قدیمی از کلید category استفاده می‌کردند.
    if (category == null) {
      final legacy = json['category'];
      if (legacy is String && legacy.trim().isNotEmpty) {
        category = legacy;
      } else if (legacy is Map<String, dynamic>) {
        categoryId = CategoryId.fromJson(legacy);
        category = categoryId?.sId;
      }
    }

    // ---------- Relation: categories (Many-to-many but single selection in UI) ----------
    if (category == null) {
      final rel = json['categories'];

      if (rel is List && rel.isNotEmpty) {
        final first = rel.first;

        // حالت رایج Appwrite بدون expand: لیست IDها
        if (first is String && first.trim().isNotEmpty) {
          category = first;
        }

        // حالت ممکن در برخی queryها: لیست map / document
        else if (first is Map<String, dynamic>) {
          // اگر expand شده باشد، می‌توانیم نام را هم بخوانیم
          categoryId = CategoryId.fromJson(first);

          category = (first[r'$id'] ??

              first['id'] ??
              first['documentId'])
              ?.toString();
          category ??= categoryId?.sId;
        } else {
          // حالت‌های غیرمعمول (مثلاً Document از SDK)
          try {
            final dynamic d = first;
            final dynamic id = d.$id; // appwrite Document.$id
            if (id != null) {
              category = id.toString();
            }
          } catch (_) {
            // نادیده
          }
        }
      }
    }

    // اگر categoriesId خالی بود ولی category داریم، آن را هم پر کنیم
    categoriesId ??= category;
  }

  /// خروجی برای دیباگ/لاگ و در صورت نیاز به ارسال مستقیم
  ///
  /// در مسیرهای create/update داخل سرویس Appwrite از این استفاده نمی‌کنیم
  /// ولی برای نمایش در لاگ‌ها (DataProvider) مفید است.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': sId,
      'name': name,
      'phone_number_code': phoneNumberCode,
      'categories_id': category,
      'categories': category == null ? <String>[] : <String>[category!],
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      // اطلاعات expand شده
      'category_obj': categoryId?.toJson(),
    };
  }
}

class CategoryId {
  String? sId;
  String? name;

  CategoryId({this.sId, this.name});

  CategoryId.fromJson(Map<String, dynamic> json) {
    // Appwrite: $id / (گاهی در بعضی جاها) id
    sId = (json[r'$id']  ?? json['id'])?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': sId,
      'name': name,
    };
  }
}
