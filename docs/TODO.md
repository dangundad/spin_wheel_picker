# Spin Wheel Picker - TODO

## 구현 완료 기능

- [x] 커스텀 휠 생성/삭제/이름 변경 (최대 3개)
- [x] 항목 추가/삭제/수정 (최소 2개, 최대 20개)
- [x] 항목 색상 커스터마이징 (10가지 프리셋 + 사용자 지정)
- [x] 스핀 애니메이션 (물리 기반 회전)
- [x] 결과 이력 관리 (SpinWheel.resultHistory)
- [x] Hive 영구 저장 (SpinWheel, WheelItem @HiveType 모델)
- [x] CustomPainter 룰렛 휠 렌더링 (WheelPainter)
- [x] 보상형 광고로 휠 슬롯 추가
- [x] Confetti 효과 (결과 선택 시)
- [x] 햅틱 피드백
- [x] GetX 상태 관리 + 라우팅
- [x] AdMob 광고 (배너 + 전면 + 보상형) + 미디에이션
- [x] 인앱 구매 (프리미엄 광고 제거)
- [x] 다국어 지원 (ko)
- [x] FlexColorScheme 테마 (orangeM3)
- [x] 설정 페이지
- [x] 통계 페이지
- [x] 활동 로그 서비스

## 출시 전 남은 작업

- [ ] AdMob 실제 광고 ID 교체 (현재 테스트 ID)
- [ ] 인앱 구매 상품 ID 등록 (Google Play Console)
- [ ] 앱 아이콘 제작 및 적용 (`dart run flutter_launcher_icons`)
- [ ] 스플래시 화면 제작 및 적용 (`dart run flutter_native_splash:create`)
- [ ] Google Play 스토어 등록 (스크린샷, 설명, 카테고리)
- [ ] Apple App Store 등록
- [ ] 다국어 확장 (en, ja 등)
- [ ] Privacy Policy 페이지 작성
- [ ] ProGuard 규칙 확인 (릴리스 빌드)
- [ ] Firebase Crashlytics 설정 확인
- [ ] 앱 종료 후 재진입 시 휠 상태 복원 검증
- [ ] 스핀 중 앱 백그라운드 진입 시 안정성 확인
- [ ] 동시 터치/드래그 입력 경합 처리 검증
