import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:spin_wheel_picker/app/admob/ads_banner.dart';
import 'package:spin_wheel_picker/app/admob/ads_helper.dart';
import 'package:spin_wheel_picker/app/controllers/wheel_controller.dart';
import 'package:spin_wheel_picker/app/data/models/spin_wheel.dart';
import 'package:spin_wheel_picker/app/routes/app_pages.dart';

class HomePage extends GetView<WheelController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary.withValues(alpha: 0.14),
              cs.surface,
              cs.secondaryContainer.withValues(alpha: 0.18),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.r),
                child: _Header(cs: cs, onAdd: _showAddDialog),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.wheels.isEmpty) {
                    return _EmptyState(onAdd: _showAddDialog);
                  }
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.r),
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
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.auto_awesome_motion_rounded),
        label: Text('new_wheel'.tr),
      ),
    );
  }

  void _showAddDialog() {
    final textCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('new_wheel'.tr),
        content: TextField(
          controller: textCtrl,
          autofocus: true,
          maxLength: 30,
          decoration: InputDecoration(
            hintText: 'wheel_name_hint'.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          onSubmitted: (_) => _saveWheel(textCtrl.text),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          FilledButton(
            onPressed: () => _saveWheel(textCtrl.text),
            child: Text('create'.tr),
          ),
        ],
      ),
    );
  }

  void _saveWheel(String text) {
    final name = text.trim();
    if (name.isEmpty) return;
    controller.addWheel(name);
    Get.back();
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

class _Header extends StatelessWidget {
  final ColorScheme cs;
  final VoidCallback onAdd;

  const _Header({required this.cs, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.9, end: 1),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutBack,
                builder: (context, value, child) => Transform.scale(
                  scale: value,
                  child: child,
                ),
                child: const Text('🎡', style: TextStyle(fontSize: 34)),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'app_name'.tr,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: Text('new_wheel'.tr),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

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
              Icons.sports_esports_rounded,
              size: 74.r,
              color: cs.primary.withValues(alpha: 0.4),
            ),
            SizedBox(height: 14.h),
            Text(
              'no_wheels'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'no_wheels_desc'.tr,
              style: TextStyle(fontSize: 13.sp, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            Container(
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
                  onTap: onAdd,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 28.w,
                      vertical: 14.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 22.r,
                          color: cs.onPrimary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'new_wheel'.tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    final colors = wheel.items.map((i) => Color(i.colorValue)).toList();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              SizedBox(
                width: 50.r,
                height: 50.r,
                child: Stack(
                  children: List.generate(
                    colors.length.clamp(0, 4),
                    (i) => Positioned(
                      left: (i * 10.0).toDouble(),
                      top: 0,
                      child: Container(
                        width: 30.r,
                        height: 30.r,
                        decoration: BoxDecoration(
                          color: colors[i],
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.surface, width: 2),
                        ),
                      ),
                    ),
                  ),
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
                    SizedBox(height: 2.h),
                    Text(
                      '${wheel.items.length} ${'items'.tr}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (wheel.resultHistory.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          '${'last_result'.tr}: ${wheel.resultHistory.first}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: cs.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
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
                        const Icon(Icons.edit_rounded, size: 18),
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
                          Icons.delete_rounded,
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
