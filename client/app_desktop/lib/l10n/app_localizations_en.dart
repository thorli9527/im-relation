// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'IM Client';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get country => 'Country';

  @override
  String get language => 'Language';

  @override
  String get gender => 'Gender';

  @override
  String get nickname => 'Nickname';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get sendCode => 'Send Code';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get submit => 'Submit';

  @override
  String get goHome => 'Go Home';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get sort => 'Sort';

  @override
  String get sortByName => 'by name';

  @override
  String get sortByLastLogin => 'by last login';

  @override
  String get contacts => 'Contacts';

  @override
  String get add => 'Add';

  @override
  String get addContactTitle => 'Add Contact';

  @override
  String get addContactHint => 'UID/Email/Phone';

  @override
  String get nicknameOptional => 'Nickname (optional)';

  @override
  String get remarkOptional => 'Remark (optional)';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get contentCannotBeEmpty => 'Content cannot be empty';

  @override
  String get alreadyFriend => 'Already a friend';

  @override
  String get userNotFound => 'User not found';

  @override
  String get targetRejectsFriendRequest => 'Target does not accept friend requests';

  @override
  String get friendRequestTitle => 'Friend Request';

  @override
  String get reason => 'Reason';

  @override
  String get remark => 'Remark';

  @override
  String get friendRequestSent => 'Friend request sent';

  @override
  String get addedAsFriend => 'Added as friend';

  @override
  String get confirm => 'Confirm';

  @override
  String get userSummaryTitle => 'User Summary';

  @override
  String emailWithValue(String email) {
    return 'Email: $email';
  }

  @override
  String phoneWithValue(String phone) {
    return 'Phone: $phone';
  }

  @override
  String usernameWithValue(String username) {
    return 'Username: $username';
  }

  @override
  String uidWithValue(String uid) {
    return 'UID $uid';
  }

  @override
  String countryWithValue(String country) {
    return 'Country: $country';
  }

  @override
  String languageWithValue(String language) {
    return 'Language: $language';
  }

  @override
  String addFriendFailed(String error) {
    return 'Add friend failed: $error';
  }

  @override
  String get passiveLogoutTitle => 'Signed in elsewhere';

  @override
  String get passiveLogoutMessage => 'Your account signed in on another device and must log in again.';

  @override
  String passiveLogoutDevice(String deviceId) {
    return 'Device ID: $deviceId';
  }

  @override
  String passiveLogoutReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get passiveLogoutAction => 'Re-login';

  @override
  String passiveLogoutCountdown(String seconds) {
    return 'Auto redirecting to login in ${seconds}s';
  }
}
