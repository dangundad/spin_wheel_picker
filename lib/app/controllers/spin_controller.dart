import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'package:spin_wheel_picker/app/controllers/wheel_controller.dart';
import 'package:spin_wheel_picker/app/data/models/spin_wheel.dart';
import 'package:spin_wheel_picker/app/data/models/wheel_item.dart';
import 'package:spin_wheel_picker/app/services/hive_service.dart';

class SpinController extends GetxController with GetTickerProviderStateMixin {
  final String wheelId;
  SpinController({required this.wheelId});

  late SpinWheel wheel;
  late AnimationController _animCtrl;

  double _fromAngle = 0;
  double _toAngle = 0;
  int _lastSectionIndex = -1;

  // Snapshot of items taken when spin() starts, used by _determineWinner
  // to guarantee the result always matches what was visually spinning.
  List<WheelItem> _spinItems = [];

  /// Returns the items being displayed: snapshot during spin, live list when idle.
  List<WheelItem> get displayItems =>
      isSpinning.value && _spinItems.isNotEmpty ? _spinItems : wheel.items;

  final isSpinning = false.obs;
  final angle = 0.0.obs;
  final winner = Rx<WheelItem?>(null);
  final showResult = false.obs;
  final showConfetti = false.obs;

  @override
  void onInit() {
    super.onInit();
    final loaded = HiveService.to.wheelsBox.get(wheelId);
    if (loaded == null) {
      // Wheel was deleted externally; pop back to home gracefully
      wheel = SpinWheel(id: wheelId, name: '', items: []);
      WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
    } else {
      wheel = loaded;
    }
    _animCtrl = AnimationController(vsync: this, duration: Duration.zero);
  }

  @override
  void onClose() {
    _animCtrl.removeListener(_onTick);
    _animCtrl.dispose();
    super.onClose();
  }

  void _onTick() {
    final newAngle =
        _fromAngle +
        (_toAngle - _fromAngle) * Curves.easeOut.transform(_animCtrl.value);
    angle.value = newAngle;

    final n = _spinItems.length;
    if (n > 0) {
      final segAngle = (2 * math.pi) / n;
      final normalized = newAngle % (2 * math.pi);
      final sectionIdx =
          (((2 * math.pi - normalized) % (2 * math.pi)) / segAngle).floor() %
          n;
      if (_lastSectionIndex != -1 && sectionIdx != _lastSectionIndex) {
        HapticFeedback.selectionClick();
      }
      _lastSectionIndex = sectionIdx;
    }
  }

  void spin() {
    if (isSpinning.value || wheel.items.length < 2) return;

    winner.value = null;
    showResult.value = false;
    showConfetti.value = false;
    isSpinning.value = true;
    _lastSectionIndex = -1;
    // Snapshot items at spin-start so winner calculation is consistent
    // with what was painted, regardless of any later edits.
    _spinItems = List<WheelItem>.from(wheel.items);

    HapticFeedback.mediumImpact();

    final rng = math.Random();
    _fromAngle = angle.value;
    _toAngle =
        _fromAngle +
        (5 + rng.nextInt(6)) * 2 * math.pi +
        rng.nextDouble() * 2 * math.pi;

    _animCtrl.duration = const Duration(milliseconds: 4500);
    _animCtrl.reset();
    _animCtrl.removeListener(_onTick); // defensive: remove before re-adding
    _animCtrl.addListener(_onTick);
    _animCtrl.forward().then((_) {
      _animCtrl.removeListener(_onTick);
      final normalized = _toAngle % (2 * math.pi);
      angle.value = normalized;
      isSpinning.value = false;
      HapticFeedback.mediumImpact();
      _determineWinner(normalized);
    });
  }

  void _determineWinner(double normalizedAngle) {
    final n = _spinItems.length;
    if (n == 0) return;
    final segAngle = (2 * math.pi) / n;
    final idx =
        (((2 * math.pi - normalizedAngle) % (2 * math.pi)) / segAngle)
            .floor() %
        n;
    final winnerItem = _spinItems[idx];
    winner.value = winnerItem;
    showResult.value = true;
    showConfetti.value = true;

    wheel.resultHistory.insert(0, winnerItem.label);
    if (wheel.resultHistory.length > 20) wheel.resultHistory.removeLast();
    wheel.save();
    WheelController.to.wheels.refresh();
  }

  void dismissResult() {
    showResult.value = false;
    showConfetti.value = false;
  }

  Future<void> shareResult() async {
    final w = winner.value;
    if (w == null) return;
    HapticFeedback.lightImpact();
    await SharePlus.instance.share(
      ShareParams(
        text: '🎡 Spin Result: ${w.label}\n\nSpun on: ${wheel.name}',
      ),
    );
  }

  Future<void> shareHistoryItem(String label) async {
    HapticFeedback.lightImpact();
    await SharePlus.instance.share(
      ShareParams(
        text: '🎡 Spin Result: $label\n\nSpun on: ${wheel.name}',
      ),
    );
  }
}
