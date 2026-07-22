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

  @override
  String get info => 'Información';

  @override
  String get privacy => 'Política de privacidad';

  @override
  String get privacyBody =>
      'Sin cuenta ni inicio de sesión. Tus registros se quedan en este dispositivo y nunca se suben.\n\nLos anuncios aparecen solo al terminar una sesión, nunca mientras te concentras. Google AdMob puede usar tu identificador publicitario e información del dispositivo.\n\nDesinstalar la app borra todos los registros.';

  @override
  String get privacyFull => 'Leer la política completa';

  @override
  String get licenses => 'Licencias de código abierto';

  @override
  String get version => 'Versión';
}
