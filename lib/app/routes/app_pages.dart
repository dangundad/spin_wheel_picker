// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:spin_wheel_picker/app/bindings/app_binding.dart';
import 'package:spin_wheel_picker/app/controllers/spin_controller.dart';
import 'package:spin_wheel_picker/app/pages/history/history_page.dart';
import 'package:spin_wheel_picker/app/pages/home/home_page.dart';
import 'package:spin_wheel_picker/app/pages/settings/settings_page.dart';
import 'package:spin_wheel_picker/app/pages/stats/stats_page.dart';
import 'package:spin_wheel_picker/app/pages/wheel/wheel_page.dart';
import 'package:spin_wheel_picker/app/pages/premium/premium_page.dart';
import 'package:spin_wheel_picker/app/pages/premium/premium_binding.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomePage(),
      binding: AppBinding(),
    ),
    GetPage(
      name: _Paths.WHEEL,
      page: () => const WheelPage(),
      binding: BindingsBuilder(() {
        final wheelId = Get.arguments as String;
        Get.lazyPut(() => SpinController(wheelId: wheelId));
      }),
    ),
    GetPage(name: _Paths.SETTINGS, page: () => const SettingsPage()),
    GetPage(name: _Paths.HISTORY, page: () => const HistoryPage()),
    GetPage(name: _Paths.STATS, page: () => const StatsPage()),
    GetPage(
      name: _Paths.PREMIUM,
      page: () => const PremiumPage(),
      binding: PremiumBinding(),
    ),
];
}

