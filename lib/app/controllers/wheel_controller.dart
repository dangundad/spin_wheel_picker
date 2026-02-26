import 'package:get/get.dart';

import 'package:spin_wheel_picker/app/admob/ads_rewarded.dart';
import 'package:spin_wheel_picker/app/data/models/spin_wheel.dart';
import 'package:spin_wheel_picker/app/data/models/wheel_item.dart';
import 'package:spin_wheel_picker/app/services/hive_service.dart';

class WheelController extends GetxController {
  static WheelController get to => Get.find();

  static const int maxWheels = 3;

  final wheels = <SpinWheel>[].obs;

  // 10가지 프리셋 색상 (사용자 선택용)
  static const List<int> presetColors = [
    0xFFF44336, // red
    0xFF2196F3, // blue
    0xFF4CAF50, // green
    0xFFFF9800, // orange
    0xFF9C27B0, // purple
    0xFF00BCD4, // cyan
    0xFFFFEB3B, // yellow
    0xFFE91E63, // pink
    0xFF009688, // teal
    0xFF795548, // brown
  ];

  @override
  void onInit() {
    super.onInit();
    wheels.assignAll(HiveService.to.wheelsBox.values.toList());
  }

  int _nextColor(int count) => presetColors[count % presetColors.length];

  List<WheelItem> _defaultItems() => [
    WheelItem(label: 'Option 1', colorValue: presetColors[0]),
    WheelItem(label: 'Option 2', colorValue: presetColors[1]),
    WheelItem(label: 'Option 3', colorValue: presetColors[2]),
    WheelItem(label: 'Option 4', colorValue: presetColors[3]),
  ];

  Future<void> addWheel(String name) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final wheel = SpinWheel(id: id, name: name, items: _defaultItems());
    await HiveService.to.wheelsBox.put(wheel.id, wheel);
    wheels.add(wheel);
  }

  /// 보상형 광고 시청 후 새 휠 슬롯 추가
  void requestAddWheelWithAd(String name) {
    if (wheels.length >= maxWheels) {
      Get.snackbar('max_wheels'.tr, '');
      return;
    }
    final adManager = Get.isRegistered<RewardedAdManager>()
        ? RewardedAdManager.to
        : null;
    if (adManager == null || !adManager.isAdReady.value) {
      Get.snackbar('add_wheel_ad'.tr, '');
      return;
    }
    adManager.showAdIfAvailable(
      onUserEarnedReward: (_) => addWheel(name),
    );
  }

  Future<void> deleteWheel(SpinWheel wheel) async {
    await wheel.delete();
    wheels.remove(wheel);
  }

  Future<void> renameWheel(SpinWheel wheel, String newName) async {
    wheel.name = newName;
    await wheel.save();
    wheels.refresh();
  }

  Future<void> addItem(SpinWheel wheel, String label) async {
    if (wheel.items.length >= 20) return;
    wheel.items.add(
      WheelItem(label: label, colorValue: _nextColor(wheel.items.length)),
    );
    await wheel.save();
    wheels.refresh();
  }

  Future<void> removeItem(SpinWheel wheel, int index) async {
    if (wheel.items.length <= 2) return;
    wheel.items.removeAt(index);
    await wheel.save();
    wheels.refresh();
  }

  Future<void> updateItem(SpinWheel wheel, int index, String label) async {
    wheel.items[index].label = label;
    await wheel.save();
    wheels.refresh();
  }

  /// 항목 색상 사용자 지정
  Future<void> updateItemColor(
    SpinWheel wheel,
    int index,
    int? colorValue,
  ) async {
    wheel.items[index].customColorValue = colorValue;
    await wheel.save();
    wheels.refresh();
  }
}
