// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

import 'package:spin_wheel_picker/app/bindings/app_binding.dart';
import 'package:spin_wheel_picker/app/controllers/spin_controller.dart';
import 'package:spin_wheel_picker/app/pages/home/home_page.dart';
import 'package:spin_wheel_picker/app/pages/wheel/wheel_page.dart';

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
  ];
}
