// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'GatoFoco';

  @override
  String get todayWaiting => 'Esperando o primeiro foco de hoje';

  @override
  String todayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Você focou $count vezes hoje',
      one: 'Você focou uma vez hoje',
    );
    return '$_temp0';
  }

  @override
  String get startFocus => 'Começar a focar';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get customChip => 'Personalizado';

  @override
  String get customTitle => 'Defina seu próprio tempo';

  @override
  String get customConfirm => 'Usar este tempo';

  @override
  String get giveUp => 'Desistir';

  @override
  String get musicOn => 'Ligar música';

  @override
  String get musicOff => 'Desligar música';

  @override
  String get resultSuccess => 'Concluído! Seu gato está orgulhoso';

  @override
  String get resultAbandoned => 'Tudo bem. Tente de novo';

  @override
  String get resultLeftApp => 'Seu foco foi interrompido. Tentar de novo?';

  @override
  String totalFocus(int count) {
    return '$count min focado no total';
  }

  @override
  String get back => 'Voltar';

  @override
  String get info => 'Informações';

  @override
  String get privacy => 'Política de privacidade';

  @override
  String get privacyBody =>
      'Sem conta e sem login. Seus registros ficam neste dispositivo e nunca são enviados.\n\nAnúncios aparecem só depois que a sessão termina, nunca enquanto você foca. O Google AdMob pode usar seu identificador de anúncios e informações do aparelho.\n\nDesinstalar o app apaga todos os registros.';

  @override
  String get privacyFull => 'Ler a política completa';

  @override
  String get licenses => 'Licenças de código aberto';

  @override
  String get version => 'Versão';
}
