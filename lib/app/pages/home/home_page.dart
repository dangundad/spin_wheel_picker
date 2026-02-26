import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:spin_wheel_picker/app/admob/ads_banner.dart';
import 'package:spin_wheel_picker/app/admob/ads_helper.dart';
import 'package:spin_wheel_picker/app/admob/ads_rewarded.dart';
import 'package:spin_wheel_picker/app/controllers/wheel_controller.dart';
import 'package:spin_wheel_picker/app/data/models/spin_wheel.dart';
import 'package:spin_wheel_picker/app/routes/app_pages.dart';

class HomePage extends GetView<WheelController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🎡', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8.w),
            Text(
              'app_name'.tr,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.tertiary],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.wheels.isEmpty) {
                return _EmptyState(onAdd: _showAddDialog);
              }
              return ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                itemCount: controller.wheels.length,
                itemBuilder: (ctx, i) => _WheelCard(
                  wheel: controller.wheels[i],
                  onTap: () => Get.toNamed(
                    Routes.WHEEL,
                    arguments: controller.wheels[i].id,
                  ),
                  onDelete: () => _confirmDelete(controller.wheels[i]),
                  onRename: () => _showRenameDialog(controller.wheels[i]),
                ),
              );
            }),
          ),
          Container(
            color: cs.surface.withValues(alpha: 0.92),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                  top: 8.h,
                  bottom: 10.h,
                ),
                child: BannerAdWidget(
                  adUnitId: AdHelper.bannerAdUnitId,
                  type: AdHelper.banner,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        final count = controller.wheels.length;
        final atMax = count >= WheelController.maxWheels;
        return FloatingActionButton.extended(
          onPressed: atMax ? null : _showAddDialog,
          backgroundColor: atMax
              ? Get.theme.colorScheme.surfaceContainerHighest
              : null,
          icon: const Icon(LucideIcons.plusCircle),
          label: Text(
            atMax ? 'max_wheels'.tr : 'new_wheel'.tr,
          ),
        );
      }),
    );
  }

  void _showAddDialog() {
    final textCtrl = TextEditingController();
    final needsAd = controller.wheels.isNotEmpty;
    Get.dialog(
      AlertDialog(
        title: Text('new_wheel'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textCtrl,
              autofocus: true,
              maxLength: 30,
              decoration: InputDecoration(
                hintText: 'wheel_name_hint'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onSubmitted: (_) => _saveWheel(textCtrl.text, needsAd),
            ),
            if (needsAd) ...[
              SizedBox(height: 8.h),
              Obx(() {
                final ready = Get.isRegistered<RewardedAdManager>() &&
                    RewardedAdManager.to.isAdReady.value;
                return Row(
                  children: [
                    Icon(
                      Icons.ondemand_video_rounded,
                      size: 16.r,
                      color: ready
                          ? Get.theme.colorScheme.tertiary
                          : Get.theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'add_wheel_ad'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Get.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          FilledButton(
            onPressed: () => _saveWheel(textCtrl.text, needsAd),
            child: Text(needsAd ? 'add_wheel_ad'.tr : 'create'.tr),
          ),
        ],
      ),
    );
  }

  void _saveWheel(String text, bool needsAd) {
    final name = text.trim();
    if (name.isEmpty) return;
    Get.back();
    if (needsAd) {
      controller.requestAddWheelWithAd(name);
    } else {
      controller.addWheel(name);
    }
  }

  void _showRenameDialog(SpinWheel wheel) {
    final textCtrl = TextEditingController(text: wheel.name);
    Get.dialog(
      AlertDialog(
        title: Text('rename_wheel'.tr),
        content: TextField(
          controller: textCtrl,
          autofocus: true,
          maxLength: 30,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          onSubmitted: (_) => _saveRename(wheel, textCtrl.text),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          FilledButton(
            onPressed: () => _saveRename(wheel, textCtrl.text),
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  void _saveRename(SpinWheel wheel, String text) {
    final name = text.trim();
    if (name.isEmpty) return;
    controller.renameWheel(wheel, name);
    Get.back();
  }

  void _confirmDelete(SpinWheel wheel) {
    Get.dialog(
      AlertDialog(
        title: Text('delete'.tr),
        content: Text('delete_wheel_confirm'.tr),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          FilledButton(
            onPressed: () {
              controller.deleteWheel(wheel);
              Get.back();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text('delete'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Gradient CTA Button ────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Get.theme.colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.tertiary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22.r, color: cs.onPrimary),
                SizedBox(width: 10.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimary,
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

// ── Empty State ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.ferrisWheel,
              size: 74.r,
              color: cs.primary.withValues(alpha: 0.4),
            ),
            SizedBox(height: 14.h),
            Text(
              'no_wheels'.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'no_wheels_desc'.tr,
              style: TextStyle(fontSize: 13.sp, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            _GradientButton(
              label: 'new_wheel'.tr,
              icon: LucideIcons.plusCircle,
              onTap: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wheel Card ─────────────────────────────────────────────────────────────
class _WheelCard extends StatelessWidget {
  final SpinWheel wheel;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const _WheelCard({
    required this.wheel,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = wheel.items.map((i) => Color(i.effectiveColorValue)).toList();

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              // 색상 미리보기 — 원형 색상 스택
              SizedBox(
                width: 54.r,
                height: 54.r,
                child: Stack(
                  children: [
                    // 배경 원 (전체 크기)
                    Container(
                      width: 54.r,
                      height: 54.r,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: colors.isEmpty
                          ? Icon(
                              LucideIcons.ferrisWheel,
                              size: 26.r,
                              color: cs.primary.withValues(alpha: 0.6),
                            )
                          : null,
                    ),
                    ...List.generate(
                      colors.length.clamp(0, 4),
                      (i) => Positioned(
                        left: (i * 10.0).toDouble(),
                        top: 12.r,
                        child: Container(
                          width: 30.r,
                          height: 30.r,
                          decoration: BoxDecoration(
                            color: colors[i],
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.surface, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: colors[i].withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wheel.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.layoutGrid,
                          size: 12.r,
                          color: cs.onSurfaceVariant,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${wheel.items.length} ${'items'.tr}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (wheel.resultHistory.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.trophy,
                              size: 11.r,
                              color: cs.primary,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                '${'last_result'.tr}: ${wheel.resultHistory.first}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // 스핀 아이콘 힌트
              Container(
                margin: EdgeInsets.only(right: 4.w),
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  LucideIcons.rotateCw,
                  size: 18.r,
                  color: cs.primary,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'rename') onRename();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(LucideIcons.pencil, size: 18),
                        SizedBox(width: 8.w),
                        Text('rename_wheel'.tr),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.trash2,
                          size: 18,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'delete'.tr,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
