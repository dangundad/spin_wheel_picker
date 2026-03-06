# Spin Wheel Picker

커스텀 항목으로 룰렛 휠을 만들고 스핀하여 무작위 결과를 선택하는 Flutter 앱입니다.

## 주요 기능

- **커스텀 휠**: 최대 3개 휠 생성, 각 휠에 2~20개 항목
- **스핀 애니메이션**: 물리 기반 회전 애니메이션으로 결과 선택
- **항목 색상 커스터마이징**: 10가지 프리셋 색상 + 사용자 지정 색상
- **프리셋 저장**: 휠 구성을 Hive에 영구 저장
- **결과 이력**: 스핀 결과 기록 관리
- **Confetti 효과**: 결과 선택 시 축하 애니메이션
- **프리미엄**: 인앱 구매로 광고 제거

## 기술 스택

- **Flutter** (Dart)
- **GetX** - 상태 관리, 라우팅, 다국어
- **Hive_CE** - 로컬 데이터 저장 (`SpinWheel`, `WheelItem` 모델)
- **CustomPainter** - 룰렛 휠 렌더링 (`WheelPainter`)
- **flex_color_scheme** - 테마 (`FlexScheme.orangeM3`)
- **flutter_screenutil** - 반응형 UI
- **google_mobile_ads** - AdMob 광고 (배너 + 전면 + 보상형)

## 설치 및 실행

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

## 프로젝트 구조

```
lib/
├── main.dart
├── hive_registrar.g.dart
├── app/
│   ├── admob/              # AdMob 광고 관리
│   ├── bindings/           # GetX 바인딩
│   ├── controllers/        # WheelController, SpinController 등
│   ├── data/models/        # SpinWheel, WheelItem (@HiveType)
│   ├── pages/              # 화면별 UI (wheel/ 하위에 WheelPainter)
│   ├── routes/             # GetX 라우팅
│   ├── services/           # HiveService, PurchaseService 등
│   ├── theme/              # FlexColorScheme 테마
│   ├── translate/          # 다국어 (ko)
│   ├── utils/              # 상수 정의
│   └── widgets/            # ConfettiOverlay
```

## 라이선스

Copyright 2026 DangunDad. All rights reserved.
