// lib/config/environment.dart
class Environment {
  Environment._();

  // TODO: این‌ها رو با مقادیر واقعی Appwrite پر کن
  static const String appwriteEndpoint = 'https://YOUR_APPWRITE_ENDPOINT/v1';
  static const String appwriteProjectId = 'YOUR_PROJECT_ID';

  // Database
  static const String databaseIdMenuMita = 'db_menu_mita';

  // Collections
  static const String collectionIdBrands = 'brands';
  static const String collectionIdCategories = 'categories';
  static const String collectionIdCouponCode = 'couponCode'; // یا couponcode بر اساس Appwrite
  static const String collectionIdOrders = 'orders';
  static const String collectionIdPosters = 'posters';
  static const String collectionIdProducts = 'products';
  static const String collectionIdSubcategories = 'subcategories';
  static const String collectionIdUserBizi = 'user_bizi';
  static const String collectionIdUserShop = 'usershop';
  static const String collectionIdVariants = 'variants';
  static const String collectionIdVariantTypes = 'variant_types';
}
