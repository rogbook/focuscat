// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'FokusKatze';

  @override
  String get todayWaiting => 'Warte auf deine erste Fokuszeit heute';

  @override
  String todayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Heute $count-mal fokussiert',
      one: 'Heute einmal fokussiert',
    );
    return '$_temp0';
  }

  @override
  String get startFocus => 'Fokus starten';

  @override
  String minutes(int count) {
    return '$count Min.';
  }

  @override
  String get customChip => 'Eigene Zeit';

  @override
  String get customTitle => 'Eigene Fokuszeit festlegen';

  @override
  String get customConfirm => 'Diese Zeit verwenden';

  @override
  String get giveUp => 'Aufgeben';

  @override
  String get musicOn => 'Musik einschalten';

  @override
  String get musicOff => 'Musik ausschalten';

  @override
  String get resultSuccess => 'Geschafft! Deine Katze ist stolz auf dich';

  @override
  String get resultAbandoned => 'Kein Problem. Versuch es noch mal';

  @override
  String get resultLeftApp => 'Dein Fokus wurde unterbrochen. Noch mal?';

  @override
  String totalFocus(int count) {
    return 'Insgesamt $count Min. fokussiert';
  }

  @override
  String get back => 'Zurück';

  @override
  String get info => 'Über die App';

  @override
  String get privacy => 'Datenschutzerklärung';

  @override
  String get privacyBody =>
      'Kein Konto, keine Anmeldung. Deine Fokuszeiten bleiben auf diesem Gerät und werden nie hochgeladen.\n\nWerbung erscheint nur nach einer Sitzung, nie während du fokussierst. Google AdMob kann dafür deine Werbe-ID und Geräteinformationen nutzen.\n\nBeim Deinstallieren werden alle Daten gelöscht.';

  @override
  String get privacyFull => 'Vollständige Erklärung lesen';

  @override
  String get licenses => 'Open-Source-Lizenzen';

  @override
  String get version => 'Version';
}
