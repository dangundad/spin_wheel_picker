# Spin Wheel Picker Support Actions Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** `spin_wheel_picker` 설정 화면에 실제 지원 액션 4종을 추가하고 테스트까지 정리한다.

**Architecture:** `SettingController`가 support action을 위임하고, `SettingsPage`는 support group과 tile key를 제공한다. `AppRatingService`와 `url_launcher`는 기존 서비스/유틸을 그대로 재사용한다.

**Tech Stack:** Flutter, GetX, Hive_CE, `in_app_review`, `url_launcher`, Flutter unit/widget tests

---

### Task 1: 문서 체크포인트

**Files:**
- Create: `docs/plans/2026-03-06-spin-support-design.md`
- Create: `docs/plans/2026-03-06-spin-support.md`

**Step 1: 문서 작성**

- 설계와 구현 계획 문서를 저장한다.

**Step 2: 체크포인트 커밋**

Run:

```bash
git add docs/plans/2026-03-06-spin-support-design.md docs/plans/2026-03-06-spin-support.md
git commit -m "docs: add spin support action plan"
```

### Task 2: Support Action 테스트 먼저 작성

**Files:**
- Create: `test/app/controllers/setting_controller_test.dart`
- Create: `test/app/pages/settings/settings_page_test.dart`

**Step 1: Write the failing test**

- `SettingController`에 대한 4개 support action 테스트를 작성한다.
- `SettingsPage` support tile 탭 위임 테스트를 작성한다.

**Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/app/controllers/setting_controller_test.dart
flutter test test/app/pages/settings/settings_page_test.dart
```

Expected:

- `SettingController` 생성자 인자, support action 메서드, `PRIVACY_POLICY` 상수, support tile key 부재로 실패

**Step 3: Write minimal implementation**

- `setting_controller.dart`에 테스트 가능한 생성자와 support action 메서드를 추가한다.
- `settings_page.dart`에 support group과 타일 4개를 추가한다.
- `app_constants.dart`, `translate.dart`에 필요한 상수/문자열을 보강한다.

**Step 4: Run test to verify it passes**

Run:

```bash
flutter test test/app/controllers/setting_controller_test.dart
flutter test test/app/pages/settings/settings_page_test.dart
```

Expected:

- 두 테스트 모두 PASS

**Step 5: Commit**

```bash
git add lib/app/controllers/setting_controller.dart lib/app/pages/settings/settings_page.dart lib/app/utils/app_constants.dart lib/app/translate/translate.dart test/app/controllers/setting_controller_test.dart test/app/pages/settings/settings_page_test.dart
git commit -m "feat: add spin support actions"
```

### Task 3: 최종 검증과 메타 문서 반영

**Files:**
- Modify: `C:/Flutter_WorkSpace/Flutter_Plan/docs/trending_packages_2026.md`

**Step 1: Run full verification**

Run:

```bash
flutter analyze
flutter test
```

Expected:

- analyze 0 issues
- test all pass

**Step 2: Update meta docs**

- `docs/trending_packages_2026.md`에 `spin_wheel_picker` 완료와 `url_launcher` 집계를 반영한다.

**Step 3: Commit and push**

```bash
git add .
git commit -m "feat: activate spin support actions"
git push
```

```bash
git -C C:/Flutter_WorkSpace/Flutter_Plan add docs/trending_packages_2026.md
git -C C:/Flutter_WorkSpace/Flutter_Plan commit -m "docs: record spin wheel picker rollout"
git -C C:/Flutter_WorkSpace/Flutter_Plan push
```
