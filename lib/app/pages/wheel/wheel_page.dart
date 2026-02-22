import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:spin_wheel_picker/app/admob/ads_banner.dart';
import 'package:spin_wheel_picker/app/admob/ads_helper.dart';
import 'package:spin_wheel_picker/app/controllers/spin_controller.dart';
import 'package:spin_wheel_picker/app/controllers/wheel_controller.dart';
import 'package:spin_wheel_picker/app/data/models/spin_wheel.dart';
import 'package:spin_wheel_picker/app/data/models/wheel_item.dart';
import 'package:spin_wheel_picker/app/pages/wheel/widgets/wheel_painter.dart';

class WheelPage extends GetView<SpinController> {
  const WheelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(controller.wheel.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _showEditSheet(controller.wheel),
            tooltip: 'edit'.tr,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  // Spin Wheel
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Obx(() {
                        return CustomPaint(
                          painter: WheelPainter(
                            items: controller.wheel.items,
                            angle: controller.angle.value,
                          ),
                          child: const SizedBox.expand(),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Spin Button with breathing glow when idle
                  _SpinButton(ctrl: controller),
                  SizedBox(height: 20.h),
                  // History
                  Expanded(
                    flex: 2,
                    child: _HistorySection(ctrl: controller),
                  ),
                ],
              ),
            ),
            BannerAdWidget(
              adUnitId: AdHelper.bannerAdUnitId,
              type: AdHelper.banner,
            ),
          ],
        ),
      ),
      // Result overlay
      floatingActionButton: Obx(() {
        if (!controller.showResult.value || controller.winner.value == null) {
          return const SizedBox.shrink();
        }
        return _ResultCard(
          winner: controller.winner.value!,
          onDismiss: controller.dismissResult,
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showEditSheet(SpinWheel wheel) {
    Get.bottomSheet(
      _ItemEditSheet(wheel: wheel),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ─── Spin Button with Breathing Glow ──────────────────────

class _SpinButton extends StatefulWidget {
  final SpinController ctrl;
  const _SpinButton({required this.ctrl});

  @override
  State<_SpinButton> createState() => _SpinButtonState();
}

class _SpinButtonState extends State<_SpinButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheCtrl;
  late Animation<double> _breatheAnim;

  @override
  void initState() {
    super.initState();
    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      final spinning = widget.ctrl.isSpinning.value;
      // Stop breathing animation while spinning
      if (spinning) {
        _breatheCtrl.stop();
      } else {
        if (!_breatheCtrl.isAnimating) {
          _breatheCtrl.repeat(reverse: true);
        }
      }

      return GestureDetector(
        onTap: widget.ctrl.spin,
        child: AnimatedBuilder(
          animation: _breatheAnim,
          builder: (context, child) {
            final scale = spinning ? 1.0 : _breatheAnim.value;
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100.r,
            height: 100.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: spinning
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cs.primary, cs.tertiary],
                    ),
              color: spinning ? cs.surfaceContainerHigh : null,
              boxShadow: spinning
                  ? []
                  : [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.45),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedRotation(
                  turns: spinning ? 1 : 0,
                  duration: const Duration(milliseconds: 4500),
                  child: Icon(
                    Icons.rotate_right_rounded,
                    color: spinning ? cs.onSurfaceVariant : cs.onPrimary,
                    size: 28.r,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  spinning ? 'spinning'.tr : 'spin'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: spinning ? cs.onSurfaceVariant : cs.onPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ─── Result Card ──────────────────────────────────────────

class _ResultCard extends StatefulWidget {
  final WheelItem winner;
  final VoidCallback onDismiss;

  const _ResultCard({required this.winner, required this.onDismiss});

  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _winnerTextScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    // Winner text scale: pop in from 0.5 to 1.0 with elastic bounce
    _winnerTextScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.winner.colorValue);

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: GestureDetector(
          onTap: widget.onDismiss,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 32.w),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🎉',
                  style: TextStyle(fontSize: 32.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  'result'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 6.h),
                // Winner name with scale entrance animation
                ScaleTransition(
                  scale: _winnerTextScale,
                  child: Text(
                    widget.winner.label,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'tap_to_close'.tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── History Section ──────────────────────────────────────

class _HistorySection extends StatelessWidget {
  final SpinController ctrl;
  const _HistorySection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      final history = ctrl.wheel.resultHistory;
      if (history.isEmpty) {
        return Center(
          child: Text(
            'no_history'.tr,
            style: TextStyle(fontSize: 13.sp, color: cs.onSurfaceVariant),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'history'.tr,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              scrollDirection: Axis.horizontal,
              itemCount: history.length,
              separatorBuilder: (ctx, i) => SizedBox(width: 8.w),
              itemBuilder: (context, i) {
                final label = history[i];
                final item = ctrl.wheel.items.firstWhere(
                  (it) => it.label == label,
                  orElse: () => WheelItem(label: label, colorValue: 0xFF9E9E9E),
                );
                // Slide-in from right with stagger per chip index
                return TweenAnimationBuilder<double>(
                  key: ValueKey('$label-$i'),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + i * 60),
                  curve: Curves.easeOutCubic,
                  builder: (ctx, v, child) {
                    return Transform.translate(
                      offset: Offset(40 * (1 - v), 0),
                      child: Opacity(
                        opacity: v.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Color(item.colorValue).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Color(item.colorValue).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (i == 0)
                          Padding(
                            padding: EdgeInsets.only(right: 4.w),
                            child: Icon(
                              Icons.star_rounded,
                              size: 12.r,
                              color: Color(item.colorValue),
                            ),
                          ),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight:
                                i == 0 ? FontWeight.w700 : FontWeight.w500,
                            color: i == 0
                                ? Color(item.colorValue)
                                : cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

// ─── Item Edit Bottom Sheet ───────────────────────────────

class _ItemEditSheet extends StatelessWidget {
  final SpinWheel wheel;
  const _ItemEditSheet({required this.wheel});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ctrl = WheelController.to;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        top: 12.h,
        left: 16.w,
        right: 16.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Text(
                'edit_items'.tr,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: wheel.items.length >= 20
                    ? null
                    : () => _showAddItemDialog(ctrl, wheel),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('add'.tr),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Obx(() {
            ctrl.wheels.length; // trigger rebuild
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 320.h),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: wheel.items.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final item = wheel.items[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(item.colorValue),
                      radius: 12.r,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          onPressed: () =>
                              _showEditItemDialog(ctrl, wheel, i, item.label),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_rounded,
                            size: 18,
                            color: wheel.items.length <= 2
                                ? cs.onSurfaceVariant.withValues(alpha: 0.3)
                                : cs.error,
                          ),
                          onPressed: wheel.items.length <= 2
                              ? null
                              : () => ctrl.removeItem(wheel, i),
                        ),
                      ],
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showAddItemDialog(WheelController ctrl, SpinWheel wheel) {
    final textCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('add_item'.tr),
        content: TextField(
          controller: textCtrl,
          autofocus: true,
          maxLength: 20,
          decoration: InputDecoration(hintText: 'item_hint'.tr),
          onSubmitted: (_) =>
              _saveNewItem(ctrl, wheel, textCtrl.text, textCtrl),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          TextButton(
            onPressed: () =>
                _saveNewItem(ctrl, wheel, textCtrl.text, textCtrl),
            child: Text('add'.tr),
          ),
        ],
      ),
    );
  }

  void _saveNewItem(
    WheelController ctrl,
    SpinWheel wheel,
    String text,
    TextEditingController textCtrl,
  ) {
    final label = text.trim();
    if (label.isEmpty) return;
    ctrl.addItem(wheel, label);
    Get.back();
  }

  void _showEditItemDialog(
    WheelController ctrl,
    SpinWheel wheel,
    int index,
    String current,
  ) {
    final textCtrl = TextEditingController(text: current);
    Get.dialog(
      AlertDialog(
        title: Text('edit_item'.tr),
        content: TextField(
          controller: textCtrl,
          autofocus: true,
          maxLength: 20,
          onSubmitted: (_) =>
              _saveEditItem(ctrl, wheel, index, textCtrl.text, textCtrl),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          TextButton(
            onPressed: () =>
                _saveEditItem(ctrl, wheel, index, textCtrl.text, textCtrl),
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  void _saveEditItem(
    WheelController ctrl,
    SpinWheel wheel,
    int index,
    String text,
    TextEditingController textCtrl,
  ) {
    final label = text.trim();
    if (label.isEmpty) return;
    ctrl.updateItem(wheel, index, label);
    Get.back();
  }
}
