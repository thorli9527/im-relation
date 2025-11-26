// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'IM客户端';

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get country => '国家';

  @override
  String get language => '语言';

  @override
  String get gender => '性别';

  @override
  String get nickname => '昵称';

  @override
  String get verificationCode => '验证码';

  @override
  String get sendCode => '获取验证码';

  @override
  String resendIn(int seconds) {
    return '$seconds秒后重发';
  }

  @override
  String get submit => '提交';

  @override
  String get goHome => '进入首页';

  @override
  String get backToLogin => '返回登录';
}
