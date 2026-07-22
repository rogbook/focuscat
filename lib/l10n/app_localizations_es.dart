// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'GatoFoco';

  @override
  String get todayWaiting => 'Esperando tu primer enfoque de hoy';

  @override
  String todayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Te concentraste $count veces hoy',
      one: 'Te concentraste una vez hoy',
    );
    return '$_temp0';
  }

  @override
  String get startFocus => 'Empezar a concentrarse';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get customChip => 'Personalizado';

  @override
  String get customTitle => 'Elige tu propio tiempo';

  @override
  String get customConfirm => 'Usar este tiempo';

  @override
  String get giveUp => 'Rendirse';

  @override
  String get musicOn => 'Activar música';

  @override
  String get musicOff => 'Silenciar música';

  @override
  String get resultSuccess => '¡Listo! Tu gato está orgulloso';

  @override
  String get resultAbandoned => 'Está bien. Inténtalo de nuevo';

  @override
  String get resultLeftApp => 'Se interrumpió tu enfoque. ¿Otra vez?';

  @override
  String totalFocus(int count) {
    return '$count min concentrado en total';
  }

  @override
  String get back => 'Volver';
}
