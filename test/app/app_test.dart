import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traininpink_onboarding/app/app.dart';
import 'package:traininpink_onboarding/app/di/app_dependencies.dart';
import 'package:traininpink_onboarding/core/theme/app_motion.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester,
    Locale deviceLocale, {
    Map<String, Object> saved = const {},
  }) async {
    SharedPreferences.setMockInitialValues(saved);
    final dependencies = await AppDependencies.create(
      deviceLocale: deviceLocale,
      assets: _FileAssetBundle(),
    );
    await tester.pumpWidget(App(dependencies: dependencies));
    await tester.pumpAndSettle();
  }

  /// Settles animations and the tap lock that lasts one step transition.
  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.pump(AppMotion.transition);
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await settle(tester);
  }

  /// Types into the step's field and rebuilds, so the CTA reflects it.
  Future<void> typeText(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
  }

  Future<void> tapCta(WidgetTester tester) async {
    await tester.tap(find.byType(FilledButton));
    await settle(tester);
  }

  TextDirection directionOf(WidgetTester tester) =>
      Directionality.of(tester.element(find.byType(Scaffold).last));

  testWidgets('walks a full English path to the summary', (tester) async {
    await pumpApp(tester, const Locale('en'));
    expect(directionOf(tester), TextDirection.ltr);
    await tapText(tester, 'Get started');

    expect(find.text("What's your main goal right now?"), findsOneWidget);
    await tapText(tester, 'Build strength');
    await tapCta(tester);
    await tapText(tester, 'Beginner');
    await tapCta(tester);
    await tapText(tester, 'Glutes & legs');
    await tapCta(tester);
    await tapText(tester, '3 days');
    await tapCta(tester);
    await tapText(tester, 'At home, no equipment');
    await tapCta(tester);

    await typeText(tester, 'Sara');
    await tapCta(tester);

    await typeText(tester, 'sara@mail');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    expect(find.text('Enter a valid email address'), findsOneWidget);

    await typeText(tester, 'sara@mail.com');
    await tapCta(tester);
    expect(find.text('Your plan'), findsOneWidget);
  });

  testWidgets('back returns to the previous step with her answer kept', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('en'));
    await tapText(tester, 'Get started');
    await tapText(tester, 'Get back into training');
    await tapCta(tester);
    expect(find.text('When did you last train regularly?'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await settle(tester);

    expect(find.text("What's your main goal right now?"), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Get back into training')),
      isSemantics(isChecked: true, label: 'Get back into training'),
    );
  });

  testWidgets('relaunching with saved progress resumes at the saved step', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const Locale('en'),
      saved: {
        'onboarding_progress':
            '{"flow_version": 1, "current_step_id": "focus_areas", '
            '"answers": {"goal": {"option_id": "tone_up"}, '
            '"experience": {"option_id": "beginner"}}}',
      },
    );

    expect(find.text('Which areas do you want to focus on?'), findsOneWidget);
  });

  testWidgets('a double tap on Continue moves only one step', (tester) async {
    await pumpApp(tester, const Locale('en'));
    await tapText(tester, 'Get started');
    await tapText(tester, 'Build strength');
    await tapCta(tester);
    await tapText(tester, 'Beginner');
    await tester.tap(find.byType(BackButton));
    await settle(tester);

    // Both steps are answered, so only the transition lock stops the second
    // tap from skipping past "experience".
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.tap(find.byType(FilledButton), warnIfMissed: false);
    await settle(tester);

    expect(
      find.text('How would you describe your training experience?'),
      findsOneWidget,
    );
  });

  testWidgets('an optional step offers Skip until she types', (tester) async {
    await pumpApp(
      tester,
      const Locale('en'),
      saved: {
        'onboarding_progress':
            '{"flow_version": 1, "current_step_id": "pain_notes", '
            '"answers": {"goal": {"option_id": "tone_up"}, '
            '"experience": {"option_id": "beginner"}, '
            '"focus_areas": {"option_ids": ["core"]}, '
            '"back_pain": {"option_id": "often"}}}',
      },
    );
    expect(find.text('Skip'), findsOneWidget);

    await typeText(tester, 'Worse after sitting');
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Arabic device renders RTL and the toggle switches to English', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('ar'));
    expect(directionOf(tester), TextDirection.rtl);

    await tapText(tester, 'ابدئي الآن');
    expect(find.text('ما هدفكِ الأساسي حاليًا؟'), findsOneWidget);

    await tapText(tester, 'English');
    expect(find.text("What's your main goal right now?"), findsOneWidget);
    expect(directionOf(tester), TextDirection.ltr);
  });
}

/// Reads assets straight from disk. Real asset I/O never completes under a
/// widget test's fake clock, so the config would stay "loading" forever.
class _FileAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(File(key).readAsBytesSync());
}
