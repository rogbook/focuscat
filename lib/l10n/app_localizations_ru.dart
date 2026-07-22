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

  @override
  String get info => 'О приложении';

  @override
  String get privacy => 'Политика конфиденциальности';

  @override
  String get privacyBody =>
      'Без аккаунта и входа. Записи о фокусе хранятся только на этом устройстве и никуда не отправляются.\n\nРеклама показывается только после сессии и никогда во время фокуса. Google AdMob может использовать рекламный идентификатор и данные устройства.\n\nУдаление приложения стирает все записи.';

  @override
  String get privacyFull => 'Читать полностью';

  @override
  String get licenses => 'Лицензии open source';

  @override
  String get version => 'Версия';
}
