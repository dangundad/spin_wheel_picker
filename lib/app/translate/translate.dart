import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Languages extends Translations {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ko'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      // Common
      'settings': 'Settings',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'share': 'Share',
      'reset': 'Reset',
      'done': 'Done',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',
      'no_data': 'No data',
      'add': 'Add',
      'create': 'Create',

      // Settings
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'about': 'About',
      'version': 'Version',
      'rate_app': 'Rate App',
      'privacy_policy': 'Privacy Policy',
      'remove_ads': 'Remove Ads',
      'send_feedback': 'Send Feedback',
      'more_apps': 'More Apps',

      // App-specific
      'app_name': 'Spin Wheel',
      'spin': 'SPIN',
      'spinning': 'Spinning',
      'result': 'Result',
      'tap_to_close': 'Tap to dismiss',
      'history': 'RECENT',
      'no_history': 'Spin the wheel to get started!',
      'items': 'items',
      'last_result': 'Last',
      'new_wheel': 'New Wheel',
      'wheel_name_hint': 'Wheel name...',
      'rename_wheel': 'Rename Wheel',
      'delete_wheel_confirm': 'Delete this wheel?',
      'no_wheels': 'No wheels yet',
      'no_wheels_desc': 'Create your first spin wheel\nto get started!',
      'edit_items': 'Edit Items',
      'add_item': 'Add Item',
      'edit_item': 'Edit Item',
      'item_hint': 'Item label...',
    },
    'ko': {
      // 공통
      'settings': '설정',
      'save': '저장',
      'cancel': '취소',
      'delete': '삭제',
      'edit': '편집',
      'share': '공유',
      'reset': '초기화',
      'done': '완료',
      'ok': '확인',
      'yes': '예',
      'no': '아니오',
      'error': '오류',
      'success': '성공',
      'loading': '로딩 중...',
      'no_data': '데이터 없음',
      'add': '추가',
      'create': '만들기',

      // 설정
      'dark_mode': '다크 모드',
      'language': '언어',
      'about': '앱 정보',
      'version': '버전',
      'rate_app': '앱 평가',
      'privacy_policy': '개인정보처리방침',
      'remove_ads': '광고 제거',
      'send_feedback': '피드백 보내기',
      'more_apps': '더 많은 앱',

      // 앱별
      'app_name': '스핀 휠',
      'spin': '돌리기',
      'spinning': '돌아가는 중',
      'result': '결과',
      'tap_to_close': '탭하여 닫기',
      'history': '최근 결과',
      'no_history': '휠을 돌려 시작하세요!',
      'items': '개 항목',
      'last_result': '마지막',
      'new_wheel': '새 휠',
      'wheel_name_hint': '휠 이름...',
      'rename_wheel': '휠 이름 변경',
      'delete_wheel_confirm': '이 휠을 삭제하시겠어요?',
      'no_wheels': '휠이 없습니다',
      'no_wheels_desc': '첫 번째 스핀 휠을 만들어\n시작해보세요!',
      'edit_items': '항목 편집',
      'add_item': '항목 추가',
      'edit_item': '항목 편집',
      'item_hint': '항목 이름...',
    },
  };
}
