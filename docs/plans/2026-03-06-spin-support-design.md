# Spin Wheel Picker Support Actions Design

**Date:** 2026-03-06

## Goal

`spin_wheel_picker` 설정 화면에 실제 동작하는 지원 액션을 추가해 `Rate App`, `Send Feedback`, `More Apps`, `Privacy Policy`를 일관된 패턴으로 연결한다.

## Context

- 현재 설정 화면에는 지원 액션 타일이 없다.
- `AppRatingService`와 `url_launcher`는 이미 프로젝트에 준비되어 있다.
- `translate.dart`에는 지원 액션용 문자열이 이미 일부 존재한다.
- 이번 배치는 support action 완결형만 다루고, `Get.snackbar`의 toastification 전환은 후속 배치로 미룬다.

## Options

### Option 1: `Rate App`만 연결

- 가장 작은 변경이지만 문서 우선순위인 `url_launcher` 실제 연결을 충분히 반영하지 못한다.

### Option 2: 지원 액션 4종 완결

- `Rate App`, `Send Feedback`, `More Apps`, `Privacy Policy`를 설정 화면에 모두 추가한다.
- 컨트롤러에서 `AppRatingService`와 `url_launcher`를 테스트 가능하게 주입한다.
- 가장 균형이 좋고 다른 앱과 패턴도 일치한다.

### Option 3: 지원 액션 + toastification까지 동시 도입

- 가능하지만 현재 앱 문서 우선순위는 `url_launcher` 쪽이 더 높다.
- 첫 배치에서 범위를 넓히면 테스트와 회귀 면적이 커진다.

## Chosen Approach

Option 2를 채택한다.

## Architecture

- `SettingController`가 support action 메서드를 소유한다.
- 링크 실행은 `url_launcher`로 처리하고, 스토어 평가는 `AppRatingService.openStoreListing()`에 위임한다.
- 설정 화면은 support group을 추가하고 각 타일에 테스트용 `ValueKey`를 둔다.

## Files In Scope

- `lib/app/controllers/setting_controller.dart`
- `lib/app/pages/settings/settings_page.dart`
- `lib/app/utils/app_constants.dart`
- `lib/app/translate/translate.dart`
- `test/app/controllers/setting_controller_test.dart` 신규
- `test/app/pages/settings/settings_page_test.dart` 신규

## Error Handling

- 링크 열기 실패 시 간단한 `Get.snackbar` 오류 메시지를 노출한다.
- 기존 `clear_data` 흐름과 다른 UI 피드백은 유지한다.

## Testing

- `SettingController` 단위 테스트
  - `rateApp delegates to the app rating action`
  - `sendFeedback launches a mailto uri`
  - `openPrivacyPolicy launches the privacy policy externally`
  - `openMoreApps launches the developer page externally`
- `SettingsPage` 위젯 테스트
  - support tile 4개가 컨트롤러 메서드에 위임되는지 확인

## Constraints

- iOS 전용 구현은 추가하지 않는다.
- `toastification`과 wheel/game 로직은 이번 범위에서 수정하지 않는다.
- Hive 모델 변경은 없으므로 `build_runner`는 실행하지 않는다.
