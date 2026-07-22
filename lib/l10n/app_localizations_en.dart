// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FocusCat';

  @override
  String get todayWaiting => 'Waiting for today\'s first focus';

  @override
  String todayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Focused $count times today',
      one: 'Focused once today',
    );
    return '$_temp0';
  }

  @override
  String get startFocus => 'Start focusing';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get customChip => 'Custom';

  @override
  String get customTitle => 'Set your own focus time';

  @override
  String get customConfirm => 'Use this time';

  @override
  String get giveUp => 'Give up';

  @override
  String get musicOn => 'Turn music on';

  @override
  String get musicOff => 'Turn music off';

  @override
  String get resultSuccess => 'Done! Your cat is proud of you';

  @override
  String get resultAbandoned => 'It\'s okay. Try again next time';

  @override
  String get resultLeftApp => 'Your focus was broken. Try again?';

  @override
  String totalFocus(int count) {
    return '$count min focused in total';
  }

  @override
  String get back => 'Back';
}
