// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'ChatFocus';

  @override
  String get todayWaiting => 'En attente de votre première session';

  @override
  String todayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vous vous êtes concentré $count fois aujourd\'hui',
      one: 'Vous vous êtes concentré une fois aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String get startFocus => 'Commencer à se concentrer';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get customChip => 'Personnalisé';

  @override
  String get customTitle => 'Définir votre propre durée';

  @override
  String get customConfirm => 'Utiliser cette durée';

  @override
  String get giveUp => 'Abandonner';

  @override
  String get musicOn => 'Activer la musique';

  @override
  String get musicOff => 'Couper la musique';

  @override
  String get resultSuccess => 'Terminé ! Votre chat est fier de vous';

  @override
  String get resultAbandoned => 'Ce n\'est rien. Réessayez plus tard';

  @override
  String get resultLeftApp =>
      'Votre concentration a été interrompue. On réessaie ?';

  @override
  String totalFocus(int count) {
    return '$count min de concentration au total';
  }

  @override
  String get back => 'Retour';

  @override
  String get info => 'À propos';

  @override
  String get privacy => 'Politique de confidentialité';

  @override
  String get privacyBody =>
      'Aucun compte, aucune connexion. Vos sessions restent sur cet appareil et ne sont jamais envoyées.\n\nLes publicités n\'apparaissent qu\'après une session, jamais pendant votre concentration. Google AdMob peut utiliser votre identifiant publicitaire et des informations sur l\'appareil.\n\nDésinstaller l\'application efface toutes les données.';

  @override
  String get privacyFull => 'Lire la politique complète';

  @override
  String get licenses => 'Licences open source';

  @override
  String get version => 'Version';
}
