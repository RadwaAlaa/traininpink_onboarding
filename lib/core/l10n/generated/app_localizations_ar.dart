// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ترين إن بينك';

  @override
  String get getStarted => 'ابدئي الآن';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get summaryTitle => 'خطتكِ';

  @override
  String get paywallTitle => 'اختاري خطتكِ';

  @override
  String get doneTitle => 'كل شيء جاهز';

  @override
  String get switchLanguage => 'English';

  @override
  String get skip => 'تخطي';

  @override
  String stepProgress(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get textHint => 'اكتبي إجابتكِ';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailError => 'أدخلي بريدًا إلكترونيًا صحيحًا';

  @override
  String get loadError => 'تعذّر تحميل الأسئلة. يُرجى إعادة تشغيل التطبيق.';

  @override
  String get seePlans => 'عرض الخطط';

  @override
  String trialHeadline(int days) {
    return 'جرّبيها مجانًا لمدة $days أيام';
  }

  @override
  String get noTrialHeadline => 'ابدئي التمرين اليوم';

  @override
  String planTrial(int days) {
    return 'تجربة مجانية لمدة $days أيام';
  }

  @override
  String startTrial(int days) {
    return 'ابدئي التجربة المجانية ($days أيام)';
  }

  @override
  String get subscribe => 'اشتركي';

  @override
  String get demoNote => 'نسخة تجريبية — لن يُخصم أي مبلغ.';

  @override
  String doneTrial(String plan, int days) {
    return 'تبدأ خطتكِ «$plan» بتجربة مجانية لمدة $days أيام.';
  }

  @override
  String doneSubscribed(String plan) {
    return 'أنتِ مشتركة في الخطة «$plan».';
  }

  @override
  String get startOver => 'البدء من جديد';
}
