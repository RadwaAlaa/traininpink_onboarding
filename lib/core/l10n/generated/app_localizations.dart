import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// App name shown in the task switcher and on the splash screen.
  ///
  /// In en, this message translates to:
  /// **'TrainInPink'**
  String get appTitle;

  /// Splash call-to-action that starts onboarding.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// Primary call-to-action that moves to the next screen.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// Heading of the personalised summary screen.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get summaryTitle;

  /// Heading of the paywall screen.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get paywallTitle;

  /// Heading of the final confirmation screen.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set'**
  String get doneTitle;

  /// Language toggle label: always the name of the OTHER language, in that language.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get switchLanguage;

  /// Call-to-action on an optional step she left blank.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Screen-reader label for the onboarding progress bar.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepProgress(int current, int total);

  /// Placeholder in free-text answer fields.
  ///
  /// In en, this message translates to:
  /// **'Type your answer'**
  String get textHint;

  /// Placeholder in the email field.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// Inline error under an invalid email.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailError;

  /// Shown if the bundled onboarding config fails to load.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your questions. Please restart the app.'**
  String get loadError;

  /// Summary call-to-action that opens the paywall.
  ///
  /// In en, this message translates to:
  /// **'See plans'**
  String get seePlans;

  /// Paywall subheading when the selected plan has a trial.
  ///
  /// In en, this message translates to:
  /// **'Try it free for {days} days'**
  String trialHeadline(int days);

  /// Paywall subheading when the selected plan has no trial.
  ///
  /// In en, this message translates to:
  /// **'Start training today'**
  String get noTrialHeadline;

  /// Trial line on a plan card.
  ///
  /// In en, this message translates to:
  /// **'{days}-day free trial'**
  String planTrial(int days);

  /// Paywall call-to-action for a plan with a trial.
  ///
  /// In en, this message translates to:
  /// **'Start {days}-day free trial'**
  String startTrial(int days);

  /// Paywall call-to-action for a plan without a trial.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// Small print under the paywall plans.
  ///
  /// In en, this message translates to:
  /// **'Demo only — nothing is charged.'**
  String get demoNote;

  /// Done screen text for a plan with a trial.
  ///
  /// In en, this message translates to:
  /// **'Your {plan} plan starts with a {days}-day free trial.'**
  String doneTrial(String plan, int days);

  /// Done screen text for a plan without a trial.
  ///
  /// In en, this message translates to:
  /// **'You\'re subscribed to the {plan} plan.'**
  String doneSubscribed(String plan);

  /// Done screen button that clears all progress and restarts the flow.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get startOver;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
