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
}
