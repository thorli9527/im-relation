// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'IMクライアント';

  @override
  String get login => 'ログイン';

  @override
  String get register => '登録';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get country => '国/地域';

  @override
  String get language => '言語';

  @override
  String get gender => '性別';

  @override
  String get nickname => 'ニックネーム';

  @override
  String get verificationCode => '認証コード';

  @override
  String get sendCode => 'コードを送信';

  @override
  String resendIn(int seconds) {
    return '$seconds秒後に再送';
  }

  @override
  String get submit => '送信';

  @override
  String get goHome => 'ホームへ';

  @override
  String get backToLogin => 'ログインに戻る';

  @override
  String get sort => '並び替え';

  @override
  String get sortByName => '名前順';

  @override
  String get sortByLastLogin => '最終ログイン順';

  @override
  String get contacts => '連絡先';

  @override
  String get add => '追加';

  @override
  String get addContactTitle => '連絡先を追加';

  @override
  String get addContactHint => 'UID / メール / 電話番号';

  @override
  String get nicknameOptional => 'ニックネーム（任意）';

  @override
  String get remarkOptional => '備考（任意）';

  @override
  String get cancel => 'キャンセル';

  @override
  String get create => '作成';

  @override
  String get contentCannotBeEmpty => '内容は必須です';

  @override
  String get alreadyFriend => 'すでに友達です';

  @override
  String get userNotFound => 'ユーザーが見つかりません';

  @override
  String get targetRejectsFriendRequest => '相手が友達申請を拒否しました';

  @override
  String get friendRequestTitle => '友達申請';

  @override
  String get reason => '理由';

  @override
  String get remark => '備考';

  @override
  String get friendRequestSent => '友達申請を送信しました';

  @override
  String get addedAsFriend => '友達として追加しました';

  @override
  String get confirm => '確認';

  @override
  String get userSummaryTitle => 'ユーザー情報';

  @override
  String emailWithValue(String email) {
    return 'メール：$email';
  }

  @override
  String phoneWithValue(String phone) {
    return '電話番号：$phone';
  }

  @override
  String usernameWithValue(String username) {
    return 'ユーザー名：$username';
  }

  @override
  String uidWithValue(String uid) {
    return 'UID $uid';
  }

  @override
  String countryWithValue(String country) {
    return '国/地域：$country';
  }

  @override
  String languageWithValue(String language) {
    return '言語：$language';
  }

  @override
  String addFriendFailed(String error) {
    return '友達追加に失敗しました：$error';
  }

  @override
  String get passiveLogoutTitle => '別の端末でログインしました';

  @override
  String get passiveLogoutMessage => 'アカウントが別の端末でログインされました。再ログインしてください。';

  @override
  String passiveLogoutDevice(String deviceId) {
    return 'デバイスID：$deviceId';
  }

  @override
  String passiveLogoutReason(String reason) {
    return '理由：$reason';
  }

  @override
  String get passiveLogoutAction => '再ログイン';
}
