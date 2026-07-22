// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'قط التركيز';

  @override
  String get todayWaiting => 'في انتظار أول جلسة تركيز اليوم';

  @override
  String todayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ركّزت $count مرات اليوم',
      one: 'ركّزت مرة واحدة اليوم',
    );
    return '$_temp0';
  }

  @override
  String get startFocus => 'ابدأ التركيز';

  @override
  String minutes(int count) {
    return '$count دقيقة';
  }

  @override
  String get customChip => 'مخصص';

  @override
  String get customTitle => 'حدّد مدة التركيز بنفسك';

  @override
  String get customConfirm => 'استخدم هذه المدة';

  @override
  String get giveUp => 'استسلام';

  @override
  String get musicOn => 'تشغيل الموسيقى';

  @override
  String get musicOff => 'إيقاف الموسيقى';

  @override
  String get resultSuccess => 'أحسنت! قطتك فخورة بك';

  @override
  String get resultAbandoned => 'لا بأس. حاول مرة أخرى';

  @override
  String get resultLeftApp => 'انقطع تركيزك. نحاول مجددًا؟';

  @override
  String totalFocus(int count) {
    return 'إجمالي التركيز $count دقيقة';
  }

  @override
  String get back => 'رجوع';

  @override
  String get info => 'عن التطبيق';

  @override
  String get privacy => 'سياسة الخصوصية';

  @override
  String get privacyBody =>
      'لا حساب ولا تسجيل دخول. تبقى سجلات التركيز على هذا الجهاز ولا تُرسل أبدًا.\n\nتظهر الإعلانات بعد انتهاء الجلسة فقط، ولا تظهر أثناء التركيز. قد يستخدم Google AdMob معرّف الإعلانات ومعلومات الجهاز.\n\nحذف التطبيق يمحو كل السجلات.';

  @override
  String get privacyFull => 'قراءة السياسة كاملة';

  @override
  String get licenses => 'تراخيص مفتوحة المصدر';

  @override
  String get version => 'الإصدار';
}
