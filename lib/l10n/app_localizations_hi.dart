// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'फोकसकैट';

  @override
  String get todayWaiting => 'आज के पहले फोकस का इंतज़ार';

  @override
  String todayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आज $count बार फोकस किया',
      one: 'आज एक बार फोकस किया',
    );
    return '$_temp0';
  }

  @override
  String get startFocus => 'फोकस शुरू करें';

  @override
  String minutes(int count) {
    return '$count मिनट';
  }

  @override
  String get customChip => 'अपना समय';

  @override
  String get customTitle => 'अपना फोकस समय चुनें';

  @override
  String get customConfirm => 'यही समय लें';

  @override
  String get giveUp => 'छोड़ दें';

  @override
  String get musicOn => 'संगीत चालू करें';

  @override
  String get musicOff => 'संगीत बंद करें';

  @override
  String get resultSuccess => 'पूरा हुआ! आपकी बिल्ली को गर्व है';

  @override
  String get resultAbandoned => 'कोई बात नहीं। फिर कोशिश करें';

  @override
  String get resultLeftApp => 'आपका फोकस टूट गया। फिर करें?';

  @override
  String totalFocus(int count) {
    return 'कुल $count मिनट फोकस';
  }

  @override
  String get back => 'वापस';

  @override
  String get info => 'ऐप जानकारी';

  @override
  String get privacy => 'गोपनीयता नीति';

  @override
  String get privacyBody =>
      'कोई खाता नहीं, कोई साइन-इन नहीं। आपके फोकस रिकॉर्ड इसी डिवाइस पर रहते हैं और कभी अपलोड नहीं होते।\n\nविज्ञापन सिर्फ सेशन खत्म होने के बाद दिखते हैं, फोकस के दौरान कभी नहीं। Google AdMob विज्ञापन पहचानकर्ता और डिवाइस जानकारी का उपयोग कर सकता है।\n\nऐप हटाने पर सभी रिकॉर्ड मिट जाते हैं।';

  @override
  String get privacyFull => 'पूरी नीति पढ़ें';

  @override
  String get licenses => 'ओपन सोर्स लाइसेंस';

  @override
  String get version => 'संस्करण';
}
