import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../screens/dashboard/mainscreen/main_screen.dart';

// class AppPages {
//   static const HOME = '/';
//
//   static final routes = [
//     GetPage(name: HOME, fullscreenDialog: true, page: () => MainScreen()),
//   ];
// }

import 'package:get/get.dart';
import '../../screens/login.dart';
import '../../screens/dashboard/mainscreen/main_screen.dart';

class AppPages {
  static const login = '/login';
  static const main = '/main';

  static final routes = [
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: main, page: () => MainScreen()),
  ];
}
