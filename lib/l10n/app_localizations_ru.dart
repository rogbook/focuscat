// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'КотФокус';

  @override
  String get todayWaiting => 'Ждём первую сессию за сегодня';

  @override
  String todayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сегодня вы сосредоточились $count раз',
      few: 'Сегодня вы сосредоточились $count раза',
      one: 'Сегодня вы сосредоточились $count раз',
    );
    return '$_temp0';
  }

  @override
  String get startFocus => 'Начать фокус';

  @override
  String minutes(int count) {
    return '$count мин';
  }

  @override
  String get customChip => 'Своё время';

  @override
  String get customTitle => 'Задать своё время фокуса';

  @override
  String get customConfirm => 'Взять это время';

  @override
  String get giveUp => 'Сдаться';

  @override
  String get musicOn => 'Включить музыку';

  @override
  String get musicOff => 'Выключить музыку';

  @override
  String get resultSuccess => 'Готово! Кот вами гордится';

  @override
  String get resultAbandoned => 'Ничего страшного. Попробуйте ещё раз';

  @override
  String get resultLeftApp => 'Фокус прервался. Попробуем снова?';

  @override
  String totalFocus(int count) {
    return 'Всего $count мин фокуса';
  }

  @override
  String get back => 'Назад';
}
