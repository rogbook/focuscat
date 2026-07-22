// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '집중냥이';

  @override
  String get todayWaiting => '오늘 첫 집중을 기다리는 중';

  @override
  String todayCount(int count) {
    return '오늘 $count번 집중했어요';
  }

  @override
  String get startFocus => '집중 시작';

  @override
  String minutes(int count) {
    return '$count분';
  }

  @override
  String get customChip => '직접';

  @override
  String get customTitle => '집중 시간 직접 설정';

  @override
  String get customConfirm => '이 시간으로';

  @override
  String get giveUp => '포기하기';

  @override
  String get musicOn => '음악 켜기';

  @override
  String get musicOff => '음악 끄기';

  @override
  String get resultSuccess => '집중 완료! 고양이가 뿌듯해해요';

  @override
  String get resultAbandoned => '괜찮아요. 다음에 또 해봐요';

  @override
  String get resultLeftApp => '집중이 끊겼어요. 다시 해볼까요?';

  @override
  String totalFocus(int count) {
    return '누적 집중 $count분';
  }

  @override
  String get back => '돌아가기';

  @override
  String get info => '앱 정보';

  @override
  String get privacy => '개인정보처리방침';

  @override
  String get privacyBody =>
      '계정도 로그인도 없습니다. 집중 기록은 이 기기에만 저장되며 어디로도 전송되지 않습니다.\n\n광고는 집중이 끝난 뒤에만 나오고, 집중하는 동안에는 절대 나오지 않습니다. 광고를 위해 Google AdMob이 광고 식별자와 기기 정보를 이용할 수 있습니다.\n\n앱을 삭제하면 모든 기록이 함께 지워집니다.';

  @override
  String get privacyFull => '전문 보기';

  @override
  String get licenses => '오픈소스 라이선스';

  @override
  String get version => '버전';
}
