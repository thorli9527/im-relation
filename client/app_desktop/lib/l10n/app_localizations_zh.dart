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

  @override
  String get sort => '排序';

  @override
  String get sortByName => '按名称';

  @override
  String get sortByLastLogin => '按最近登录';

  @override
  String get contacts => '联系人';

  @override
  String get add => '添加';

  @override
  String get addContactTitle => '添加联系人';

  @override
  String get addContactHint => 'UID/邮箱/手机号';

  @override
  String get nicknameOptional => '昵称';

  @override
  String get remarkOptional => '备注';

  @override
  String get cancel => '取消';

  @override
  String get create => '创建';

  @override
  String get contentCannotBeEmpty => '内容不能为空';

  @override
  String get alreadyFriend => '已是好友';

  @override
  String get userNotFound => '未找到用户';

  @override
  String get targetRejectsFriendRequest => '对方拒绝加好友';

  @override
  String get friendRequestTitle => '好友申请';

  @override
  String get reason => '理由';

  @override
  String get remark => '备注';

  @override
  String get friendRequestSent => '好友申请已发送';

  @override
  String get addedAsFriend => '已添加为好友';

  @override
  String get confirm => '确认';

  @override
  String get userSummaryTitle => '用户信息';

  @override
  String emailWithValue(String email) {
    return '邮箱：$email';
  }

  @override
  String phoneWithValue(String phone) {
    return '手机号：$phone';
  }

  @override
  String usernameWithValue(String username) {
    return '用户名：$username';
  }

  @override
  String uidWithValue(String uid) {
    return 'UID $uid';
  }

  @override
  String countryWithValue(String country) {
    return '国家：$country';
  }

  @override
  String languageWithValue(String language) {
    return '语言：$language';
  }

  @override
  String addFriendFailed(String error) {
    return '添加好友失败：$error';
  }

  @override
  String get passiveLogoutTitle => '已在其它地方登录';

  @override
  String get passiveLogoutMessage => '你的账号已在其它设备登录，需要重新登录。';

  @override
  String passiveLogoutDevice(String deviceId) {
    return '设备ID：$deviceId';
  }

  @override
  String passiveLogoutReason(String reason) {
    return '原因：$reason';
  }

  @override
  String get passiveLogoutAction => '重新登录';

  @override
  String passiveLogoutCountdown(String seconds) {
    return '$seconds 秒后将自动跳转至登录页面';
  }
}
