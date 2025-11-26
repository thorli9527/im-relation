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
}
