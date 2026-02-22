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
      backgroundColor: cs.surface,
      appBar: AppBar(title: Text('app_name'.tr)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.wheels.isEmpty) {
                  return _EmptyState(onAdd: () => _showAddDialog());
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  itemCount: controller.wheels.length,
                  itemBuilder: (ctx, i) {
                    return _WheelCard(
                      wheel: controller.wheels[i],
                      onTap:
                          () => Get.toNamed(
                            Routes.WHEEL,
                            arguments: controller.wheels[i].id,
                          ),
                      onDelete:
                          () => _confirmDelete(controller.wheels[i]),
                      onRename:
                          () => _showRenameDialog(controller.wheels[i]),
                    );
                  },
                );
              }),
            ),
            BannerAdWidget(
              adUnitId: AdHelper.bannerAdUnitId,
              type: AdHelper.banner,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add_rounded),
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
          decoration: InputDecoration(hintText: 'wheel_name_hint'.tr),
          onSubmitted: (_) => _saveWheel(textCtrl.text, textCtrl),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          TextButton(
            onPressed: () => _saveWheel(textCtrl.text, textCtrl),
            child: Text('create'.tr),
          ),
        ],
      ),
    );
  }

  void _saveWheel(String text, TextEditingController tc) {
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
          onSubmitted: (_) => _saveRename(wheel, textCtrl.text, textCtrl),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          TextButton(
            onPressed: () => _saveRename(wheel, textCtrl.text, textCtrl),
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  void _saveRename(SpinWheel wheel, String text, TextEditingController tc) {
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
          TextButton(
            onPressed: () {
              controller.deleteWheel(wheel);
              Get.back();
            },
            child: Text('delete'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_esports_rounded,
            size: 72.r,
            color: cs.primary.withValues(alpha: 0.4),
          ),
          SizedBox(height: 16.h),
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
          SizedBox(height: 24.h),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: Text('new_wheel'.tr),
          ),
        ],
      ),
    );
  }
}

// ─── Wheel Card ───────────────────────────────────────────

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

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              // Color preview circles
              SizedBox(
                width: 48.r,
                height: 48.r,
                child: Stack(
                  children: List.generate(
                    colors.length.clamp(0, 4),
                    (i) => Positioned(
                      left: (i * 10.0).toDouble(),
                      top: 0,
                      child: Container(
                        width: 28.r,
                        height: 28.r,
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
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wheel.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
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
                itemBuilder:
                    (_) => [
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
