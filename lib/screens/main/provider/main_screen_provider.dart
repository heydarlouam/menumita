
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../brands/brand_screen.dart';
import '../../category/category_screen.dart';
import '../../coupon_code/coupon_code_screen.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../order/order_screen.dart';
import '../../posters/poster_screen.dart';
import '../../sub_category/sub_category_screen.dart';
import '../../variants/variants_screen.dart';
import '../../variants_type/variants_type_screen.dart';

class MainScreenProvider extends ChangeNotifier {
  Widget selectedScreen = DashboardScreen();

  navigateToScreen(String screenName) {

    switch (screenName) {
      case 'داشبورد':
        selectedScreen = DashboardScreen();
        break;
      case 'دسته‌بندی':
        selectedScreen = CategoryScreen();
        break;
      case 'زیر‌دسته':
        selectedScreen = SubCategoryScreen();
        break;
      case 'برندها':
        selectedScreen = BrandScreen();
        break;
      case 'نوع ویژگی':
        selectedScreen = VariantsTypeScreen();
        break;
      case 'ویژگی‌ها':
        selectedScreen = VariantsScreen();
        break;
      case 'کد تخفیف':
        selectedScreen = CouponCodeScreen();
        break;
      case 'پوسترها':
        selectedScreen = PosterScreen();
        break;
      case 'سفارشات':
        selectedScreen = OrderScreen();
        break;
      default:
        selectedScreen = DashboardScreen();
    }
    notifyListeners();
  }
}
