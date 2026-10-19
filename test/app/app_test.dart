import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traininpink_onboarding/app/app.dart';
import 'package:traininpink_onboarding/app/di/app_dependencies.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Locale deviceLocale) async {
    SharedPreferences.setMockInitialValues({});
    final dependencies = await AppDependencies.create(
      deviceLocale: deviceLocale,
    );
    await tester.pumpWidget(App(dependencies: dependencies));
    await tester.pumpAndSettle();
  }

  Future<void> tapCta(WidgetTester tester) async {
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  TextDirection directionOf(WidgetTester tester) =>
      Directionality.of(tester.element(find.byType(Scaffold).last));

  testWidgets('navigates splash → onboarding → summary → paywall → done '
      'by name in English', (tester) async {
    await pumpApp(tester, const Locale('en'));

    expect(find.text('TrainInPink'), findsOneWidget);
    expect(directionOf(tester), TextDirection.ltr);

    await tapCta(tester);
    expect(find.text('Tell us about you'), findsOneWidget);
    await tapCta(tester);
    expect(find.text('Your plan'), findsOneWidget);
    await tapCta(tester);
    expect(find.text('Choose your plan'), findsOneWidget);
    await tapCta(tester);
    expect(find.text("You're all set"), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('Arabic device renders RTL and the toggle switches to English', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('ar'));

    expect(find.text('ابدئي الآن'), findsOneWidget);
    expect(directionOf(tester), TextDirection.rtl);

    await tapCta(tester);
    expect(find.text('أخبرينا عنكِ'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Tell us about you'), findsOneWidget);
    expect(directionOf(tester), TextDirection.ltr);
  });
}
