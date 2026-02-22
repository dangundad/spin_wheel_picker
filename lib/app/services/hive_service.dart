// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:spin_wheel_picker/app/data/models/spin_wheel.dart';
import 'package:spin_wheel_picker/hive_registrar.g.dart';

class HiveService extends GetxService {
  static HiveService get to => Get.find();

  static const String SETTINGS_BOX = 'settings';
  static const String APP_DATA_BOX = 'app_data';
  static const String WHEELS_BOX = 'wheels';

  Box get settingsBox => Hive.box(SETTINGS_BOX);
  Box get appDataBox => Hive.box(APP_DATA_BOX);
  Box<SpinWheel> get wheelsBox => Hive.box<SpinWheel>(WHEELS_BOX);

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();

    await Future.wait([
      Hive.openBox(SETTINGS_BOX),
      Hive.openBox(APP_DATA_BOX),
      Hive.openBox<SpinWheel>(WHEELS_BOX),
    ]);

    Get.log('Hive 초기화 완료');
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> setSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  T? getAppData<T>(String key, {T? defaultValue}) {
    return appDataBox.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> setAppData(String key, dynamic value) async {
    await appDataBox.put(key, value);
  }

  Future<void> clearAllData() async {
    await Future.wait([
      settingsBox.clear(),
      appDataBox.clear(),
      wheelsBox.clear(),
    ]);
    Get.log('모든 데이터 삭제 완료');
  }
}
