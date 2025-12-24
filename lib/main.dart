import 'package:admin/screens/orderpaid/provider/order_provider_paid.dart';
import 'package:admin/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/network/appwrite_client.dart';
import 'login.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'core/data/data_provider.dart';
import 'core/routes/app_pages.dart';
import 'screens/brands/provider/brand_provider.dart';
import 'screens/category/provider/category_provider.dart';
import 'screens/coupon_code/provider/coupon_code_provider.dart';
import 'screens/dashboard/provider/dash_board_provider.dart';
import 'screens/dashboard/mainscreen/main_screen.dart';
import 'screens/main/provider/main_screen_provider.dart';
import 'screens/order/provider/order_provider.dart';
import 'screens/posters/provider/poster_provider.dart';
import 'screens/sub_category/provider/sub_category_provider.dart';
import 'screens/variants/provider/variant_provider.dart';
import 'screens/variants_type/provider/variant_type_provider.dart';
import 'utility/constants.dart';
import 'utility/extensions.dart';


void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // ✅ این خط مهمه: AppwriteClient برای کل اپ initialize می‌شه
    AppwriteClient.instance.init();

    // ⬅️ اینجا وضعیت لاگین رو از SharedPreferences می‌خونیم
    final userMap = await PrefsService.readMap('user');
    final isLoggedIn = userMap.isNotEmpty;

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(lazy: false, create: (_) => DataProvider()),
          ChangeNotifierProvider(create: (_) => MainScreenProvider()),
          ChangeNotifierProvider(create: (context) => CategoryProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => SubCategoryProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => BrandProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => PosterProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => OrderPaidProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => OrderProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => VariantsTypeProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => VariantsProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => DashBoardProvider(context.dataProvider)),
          ChangeNotifierProvider(create: (context) => CouponCodeProvider(context.dataProvider)),
        ],
        child: MyApp(isLoggedIn: isLoggedIn), // ⬅️ پاس دادن وضعیت
      ),
    );
  }, (error, stack) {
    // TODO: گزارش خطا (Sentry/Logger)
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedIn});
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'menumita',
      locale: const Locale('fa'),
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: FONTS_STYLE_FAMILY,
        scaffoldBackgroundColor: bgColor,
        canvasColor: secondaryColor,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        // رنگ لودینگ‌ها
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.grey),
        colorScheme: const ColorScheme.dark().copyWith(secondary: Colors.grey),
      ),

      // ⬅️ اینجا دیگه RootDecider نداریم
    home: isLoggedIn ?  MainScreen() : LoginScreen(),

      // home: MainScreen(),
      unknownRoute: GetPage(name: '/notFound', page: () =>  MainScreen()),
      defaultTransition: Transition.cupertino,
      getPages: AppPages.routes,
    );
  }
}


