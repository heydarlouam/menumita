// lib/config/environment.dart
class Environment {
  Environment._();

  // TODO: این‌ها رو با مقادیر واقعی Appwrite پر کن
  static const String appwriteEndpoint = 'https://pb.frozencoffee.ir/v1';
  static const String appwriteProjectId = '692c0b6a00389c2456f6';

  // Database
  // static const String databaseIdMenuMita = 'db_menu_mita';
  static const String databaseIdMenuMita = '692d6d2c002b8242adc1'; // ✅

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


  // ✅ باکت تصاویر کتگوری
  static const String BucketImages = '692fbd53003412d67c52';


  // Functions
  static const String functionIdLogin = '6942e48c00274480bd93'; // login-function-appwrite



}
