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
}
