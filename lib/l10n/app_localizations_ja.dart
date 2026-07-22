// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '集中ねこ';

  @override
  String get todayWaiting => '今日はまだ集中していません';

  @override
  String todayCount(int count) {
    return '今日は$count回集中しました';
  }

  @override
  String get startFocus => '集中を始める';

  @override
  String minutes(int count) {
    return '$count分';
  }

  @override
  String get customChip => 'カスタム';

  @override
  String get customTitle => '集中時間を自分で設定';

  @override
  String get customConfirm => 'この時間にする';

  @override
  String get giveUp => 'あきらめる';

  @override
  String get musicOn => '音楽をオンにする';

  @override
  String get musicOff => '音楽をオフにする';

  @override
  String get resultSuccess => '集中完了！ねこが誇らしげです';

  @override
  String get resultAbandoned => '大丈夫。また挑戦しましょう';

  @override
  String get resultLeftApp => '集中が途切れました。もう一度？';

  @override
  String totalFocus(int count) {
    return '合計$count分集中';
  }

  @override
  String get back => '戻る';
}
