// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TrainInPink';

  @override
  String get getStarted => 'Get started';

  @override
  String get continueLabel => 'Continue';

  @override
  String get summaryTitle => 'Your plan';

  @override
  String get paywallTitle => 'Choose your plan';

  @override
  String get doneTitle => 'You\'re all set';

  @override
  String get switchLanguage => 'العربية';

  @override
  String get skip => 'Skip';

  @override
  String stepProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get textHint => 'Type your answer';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailError => 'Enter a valid email address';

  @override
  String get loadError =>
      'We couldn\'t load your questions. Please restart the app.';

  @override
  String get seePlans => 'See plans';

  @override
  String trialHeadline(int days) {
    return 'Try it free for $days days';
  }

  @override
  String get noTrialHeadline => 'Start training today';

  @override
  String planTrial(int days) {
    return '$days-day free trial';
  }

  @override
  String startTrial(int days) {
    return 'Start $days-day free trial';
  }

  @override
  String get subscribe => 'Subscribe';

  @override
  String get demoNote => 'Demo only — nothing is charged.';

  @override
  String doneTrial(String plan, int days) {
    return 'Your $plan plan starts with a $days-day free trial.';
  }

  @override
  String doneSubscribed(String plan) {
    return 'You\'re subscribed to the $plan plan.';
  }

  @override
  String get startOver => 'Start over';
}
