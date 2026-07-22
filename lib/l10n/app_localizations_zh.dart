// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '专注猫';

  @override
  String get todayWaiting => '今天还没有开始专注';

  @override
  String todayCount(int count) {
    return '今天已专注$count次';
  }

  @override
  String get startFocus => '开始专注';

  @override
  String minutes(int count) {
    return '$count分钟';
  }

  @override
  String get customChip => '自定义';

  @override
  String get customTitle => '自定义专注时长';

  @override
  String get customConfirm => '就用这个时长';

  @override
  String get giveUp => '放弃';

  @override
  String get musicOn => '打开音乐';

  @override
  String get musicOff => '关闭音乐';

  @override
  String get resultSuccess => '完成！猫咪为你骄傲';

  @override
  String get resultAbandoned => '没关系，下次再来';

  @override
  String get resultLeftApp => '专注被打断了，再试一次？';

  @override
  String totalFocus(int count) {
    return '累计专注$count分钟';
  }

  @override
  String get back => '返回';

  @override
  String get info => '应用信息';

  @override
  String get privacy => '隐私政策';

  @override
  String get privacyBody =>
      '没有账号，也无需登录。专注记录仅保存在本机，绝不上传。\n\n广告只在专注结束后出现，专注期间绝不打扰。Google AdMob 可能使用广告标识符和设备信息投放广告。\n\n卸载应用即删除全部记录。';

  @override
  String get privacyFull => '阅读全文';

  @override
  String get licenses => '开源许可';

  @override
  String get version => '版本';
}
