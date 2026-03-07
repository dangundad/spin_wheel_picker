import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:spin_wheel_picker/app/services/app_rating_service.dart';
import 'package:spin_wheel_picker/app/services/activity_log_service.dart';
import 'package:spin_wheel_picker/app/utils/app_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef CanLaunchUrlFn = Future<bool> Function(Uri uri);
typedef LaunchUrlFn = Future<bool> Function(Uri uri, LaunchMode mode);
typedef RateAppFn = Future<void> Function();

class SettingController extends GetxController {
  SettingController({
    bool loadOnInit = true,
    CanLaunchUrlFn? canLaunchUrlFn,
    LaunchUrlFn? launchUrlFn,
    RateAppFn? rateAppFn,
  }) : _loadOnInit = loadOnInit,
       _canLaunchUrlFn = canLaunchUrlFn ?? canLaunchUrl,
       _launchUrlFn =
           launchUrlFn ?? ((uri, mode) => launchUrl(uri, mode: mode)),
       _rateAppFn = rateAppFn ?? (() => AppRatingService.to.openStoreListing());

  static SettingController get to => Get.find<SettingController>();
  static const String appId = 'spin_wheel_picker';

  static const String _kSettingBox = 'phase1_setting_core';
  static const String _kSoundKey = 'sound_enabled';
  static const String _kHapticKey = 'haptic_enabled';
  static const String _kAdsKey = 'ads_consent';
  static const String _kLanguageKey = 'language';

  final RxBool soundEnabled = true.obs;
  final RxBool hapticEnabled = true.obs;
  final RxBool adsConsent = true.obs;
  final RxString language = 'en'.obs;
  final bool _loadOnInit;
  final CanLaunchUrlFn _canLaunchUrlFn;
  final LaunchUrlFn _launchUrlFn;
  final RateAppFn _rateAppFn;

  @override
  void onInit() {
    super.onInit();
    if (_loadOnInit) {
      _load();
    }
  }

  Future<Box<dynamic>> _openSettingBox() async {
    if (Hive.isBoxOpen(_kSettingBox)) {
      return Hive.box(_kSettingBox);
    }
    return await Hive.openBox(_kSettingBox);
  }

  Future<void> _load() async {
    final box = await _openSettingBox();
    soundEnabled.value = _readBool(box, _kSoundKey, true);
    hapticEnabled.value = _readBool(box, _kHapticKey, true);
    adsConsent.value = _readBool(box, _kAdsKey, true);
    language.value = _readString(box, _kLanguageKey, 'en');
    Get.updateLocale(language.value == 'ko' ? const Locale('ko') : const Locale('en'));
  }

  Future<void> setSoundEnabled(bool value) async {
    final box = await _openSettingBox();
    await box.put(_kSoundKey, value);
    soundEnabled.value = value;
  }

  Future<void> setHapticEnabled(bool value) async {
    final box = await _openSettingBox();
    await box.put(_kHapticKey, value);
    hapticEnabled.value = value;
  }

  Future<void> setAdsConsent(bool value) async {
    final box = await _openSettingBox();
    await box.put(_kAdsKey, value);
    adsConsent.value = value;
  }

  Future<void> setLanguage(String value) async {
    final box = await _openSettingBox();
    await box.put(_kLanguageKey, value);
    language.value = value;
    Get.updateLocale(value == 'ko' ? const Locale('ko') : const Locale('en'));
  }

  Future<void> clearAppSettings() async {
    final box = await _openSettingBox();
    await box.clear();
    soundEnabled.value = true;
    hapticEnabled.value = true;
    adsConsent.value = true;
    language.value = 'en';
    Get.updateLocale(const Locale('en'));
  }

  Future<void> rateApp() async {
    logEvent('tap_rate_app', 'settings');
    try {
      await _rateAppFn();
    } catch (_) {
      _showLinkError();
    }
  }

  Future<void> sendFeedback() async {
    logEvent('tap_send_feedback', 'settings');
    final uri = Uri(
      scheme: 'mailto',
      path: DeveloperInfo.DEVELOPER_EMAIL,
      queryParameters: {'subject': 'feedback_email_subject'.tr},
    );
    await _openExternalLink(uri, mode: LaunchMode.platformDefault);
  }

  Future<void> openMoreApps() async {
    logEvent('tap_more_apps', 'settings');
    await _openExternalLink(Uri.parse(AppUrls.GOOGLE_PLAY_MOREAPPS));
  }

  Future<void> openPrivacyPolicy() async {
    logEvent('tap_privacy_policy', 'settings');
    await _openExternalLink(Uri.parse(AppUrls.PRIVACY_POLICY));
  }

  Future<void> _openExternalLink(
    Uri uri, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    try {
      final canLaunch = await _canLaunchUrlFn(uri);
      if (!canLaunch) {
        _showLinkError();
        return;
      }

      final launched = await _launchUrlFn(uri, mode);
      if (!launched) {
        _showLinkError();
      }
    } catch (_) {
      _showLinkError();
    }
  }

  void _showLinkError() {
    Get.snackbar(
      'error'.tr,
      'link_open_error'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16.r),
    );
  }

  void logEvent(
    String eventName,
    String screen, {
    Map<String, dynamic> metadata = const {},
  }) {
    if (!Get.isRegistered<ActivityLogService>()) {
      return;
    }
    unawaited(
      ActivityLogService.to.logEvent(
        appId: appId,
        eventName: eventName,
        screen: screen,
        route: Get.currentRoute,
        metadata: metadata,
      ),
    );
  }

  bool _readBool(Box box, String key, bool fallback) {
    final value = box.get(key, defaultValue: fallback);
    return value is bool ? value : fallback;
  }

  String _readString(Box box, String key, String fallback) {
    final value = box.get(key, defaultValue: fallback);
    return value is String ? value : fallback;
  }
}
