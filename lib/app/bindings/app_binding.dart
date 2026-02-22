import 'package:get/get.dart';

import 'package:spin_wheel_picker/app/controllers/wheel_controller.dart';
import 'package:spin_wheel_picker/app/services/hive_service.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HiveService>()) {
      Get.put(HiveService(), permanent: true);
    }

    if (!Get.isRegistered<WheelController>()) {
      Get.put(WheelController(), permanent: true);
    }
  }
}
