# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

랜덤 선택 룰렛 휠 앱. 커스텀 항목으로 휠을 구성하고 스핀 애니메이션으로 무작위 결과를 선택합니다. 프리셋 저장, 결과 이력, 항목 색상 커스터마이징을 지원합니다.

- 패키지명: `com.dangundad.spinwheelpicker`
- 개발사: DangunDad (`dangundad@gmail.com`)
- 설계 크기: 375x812 (ScreenUtil 기준)
- 테마: `FlexScheme.orangeM3` (라이트/다크 모두)

## 기술 스택

| 영역 | 기술 |
|------|------|
| 상태 관리 | GetX (`GetxController`, `.obs`, `Obx()`) |
| 로컬 저장 | Hive_CE (`@HiveType` 모델: SpinWheel, WheelItem) |
| UI 반응형 | flutter_screenutil |
| 테마 | flex_color_scheme (`FlexScheme.orangeM3`) |
| 휠 렌더링 | CustomPainter (`WheelPainter`) |
| 광고 | google_mobile_ads + AdMob 미디에이션 |
| 인앱 구매 | in_app_purchase |
| 다국어 | GetX 번역 (ko) |

## 개발 명령어

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

## 아키텍처

### 프로젝트 구조

```
lib/
├── main.dart
├── hive_registrar.g.dart
├── app/
│   ├── admob/
│   │   ├── ads_banner.dart
│   │   ├── ads_helper.dart
│   │   ├── ads_interstitial.dart
│   │   └── ads_rewarded.dart
│   ├── bindings/
│   │   └── app_binding.dart
│   ├── controllers/
│   │   ├── history_controller.dart
│   │   ├── home_controller.dart
│   │   ├── premium_controller.dart
│   │   ├── setting_controller.dart
│   │   ├── spin_controller.dart     # 스핀 애니메이션/결과 관리
│   │   ├── stats_controller.dart
│   │   └── wheel_controller.dart    # 휠 CRUD, 항목 관리
│   ├── data/
│   │   └── models/
│   │       ├── spin_wheel.dart       # @HiveType(typeId: 0)
│   │       ├── spin_wheel.g.dart
│   │       ├── wheel_item.dart       # @HiveType(typeId: 1)
│   │       └── wheel_item.g.dart
│   ├── pages/
│   │   ├── history/history_page.dart
│   │   ├── home/home_page.dart
│   │   ├── premium/
│   │   │   ├── premium_binding.dart
│   │   │   └── premium_page.dart
│   │   ├── settings/settings_page.dart
│   │   ├── stats/stats_page.dart
│   │   └── wheel/
│   │       ├── wheel_page.dart
│   │       └── widgets/
│   │           └── wheel_painter.dart  # CustomPainter 룰렛 렌더링
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   ├── services/
│   │   ├── activity_log_service.dart
│   │   ├── app_rating_service.dart
│   │   ├── hive_service.dart
│   │   └── purchase_service.dart
│   ├── theme/
│   │   └── app_flex_theme.dart
│   ├── translate/
│   │   └── translate.dart
│   ├── utils/
│   │   └── app_constants.dart
│   └── widgets/
│       └── confetti_overlay.dart
```

### 서비스 초기화 흐름

`main()` -> AdMob 동의 폼 초기화 -> `AppBinding.initializeServices()` (Hive 초기화 + 서비스 등록) -> `runApp()`

### GetX 의존성 트리

**영구 서비스 (permanent: true)**
- `HiveService` -- Hive 박스 관리 (`settings`, `app_data`, `wheelsBox`)
- `ActivityLogService` -- 이벤트 로그
- `PurchaseService` -- IAP 관리
- `WheelController` -- 휠 CRUD (최대 3개), 항목 추가/삭제/수정/색상 변경
- `SpinController` -- 스핀 애니메이션, 결과 선택
- `SettingController` -- 앱 설정
- `InterstitialAdManager` / `RewardedAdManager` -- 광고 (비프리미엄 시)

**LazyPut (필요 시 생성)**
- `HistoryController`, `StatsController`, `PremiumController`

### 라우팅

| 경로 | 페이지 | 바인딩 |
|------|--------|--------|
| `/home` | `HomePage` | `AppBinding` |
| `/wheel` | `WheelPage` | -- |
| `/settings` | `SettingsPage` | -- |
| `/history` | `HistoryPage` | -- |
| `/stats` | `StatsPage` | -- |
| `/premium` | `PremiumPage` | `PremiumBinding` |

### 데이터 모델

**SpinWheel** (`@HiveType(typeId: 0)`)
- `id` (String) -- 타임스탬프 기반 ID
- `name` (String) -- 휠 이름
- `items` (List<WheelItem>) -- 항목 목록
- `resultHistory` (List<String>) -- 스핀 결과 이력

**WheelItem** (`@HiveType(typeId: 1)`)
- `label` (String) -- 항목 표시 텍스트
- `colorValue` (int) -- 자동 할당 색상
- `customColorValue` (int?) -- 사용자 지정 색상 (null이면 자동 색상 사용)
- `effectiveColorValue` getter -- 실제 표시 색상

### 휠 렌더링

`WheelPainter` (CustomPainter)로 룰렛 휠을 렌더링합니다.
- 각 항목별 색상 섹터 그리기
- 텍스트 라벨 회전 배치
- 10가지 프리셋 색상 자동 순환 할당

### 스토리지 구조

| Hive 박스 | 용도 | 담당 |
|-----------|------|------|
| `settings` | 범용 설정 | `HiveService` |
| `app_data` | 범용 앱 데이터 | `HiveService` |
| `wheelsBox` | SpinWheel 객체 저장 | `HiveService` -> `WheelController` |

### 다국어

현재 `ko` 키만 정의. 새 문자열은 `lib/app/translate/translate.dart`에 `ko` 섹션에만 추가.

## 개발 가이드라인

- 휠 최대 3개 제한 (`WheelController.maxWheels`), 추가 시 보상형 광고 필요
- 항목 최대 20개, 최소 2개 제한
- Hive 모델 변경 시 `build_runner` 재실행 필수
- `SpinWheel`은 `HiveObject` 상속 -> `wheel.save()`로 직접 저장 가능
