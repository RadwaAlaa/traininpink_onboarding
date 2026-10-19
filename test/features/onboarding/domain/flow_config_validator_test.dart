import 'package:flutter_test/flutter_test.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/engine/flow_config_validator.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/condition.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/flow_config.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/flow_step.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/localized_text.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/option.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/summary_config.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/summary_rule.dart';

import 'sample_flow.dart';

void main() {
  List<String> errorsWith(FlowStep extra) => FlowConfigValidator.findErrors(
    FlowConfig(
      version: 1,
      steps: [...sampleFlow.steps, extra],
      summary: sampleSummary,
    ),
  );

  test('the sample flow is valid', () {
    expect(FlowConfigValidator.findErrors(sampleFlow), isEmpty);
    expect(() => FlowConfigValidator.validate(sampleFlow), returnsNormally);
  });

  test('rejects an empty config', () {
    expect(
      () => FlowConfigValidator.validate(
        FlowConfig(version: 1, steps: const [], summary: sampleSummary),
      ),
      throwsA(isA<InvalidFlowConfigException>()),
    );
  });

  test('rejects duplicate step ids', () {
    expect(errorsWith(single('goal', ['a', 'b'])), [
      contains('Duplicate step id "goal"'),
    ]);
  });

  test('rejects conditions on later or unknown steps', () {
    final config = FlowConfig(
      version: 1,
      steps: [
        single('first', ['a', 'b'], showIf: const EqCondition('second', 'a')),
        single('second', ['a', 'b']),
      ],
      summary: SummaryConfig(
        headlines: [SummaryRule(text: t('x'))],
        lines: const [],
      ),
    );

    expect(FlowConfigValidator.findErrors(config), [
      contains('unknown or comes later'),
    ]);
  });

  test('rejects unknown option ids in conditions', () {
    final step = single('extra', [
      'a',
      'b',
    ], showIf: const InCondition('goal', ['build_strength', 'run_marathon']));

    expect(errorsWith(step), [contains('unknown option "run_marathon"')]);
  });

  test('rejects a condition that does not fit the step type', () {
    final step = single('extra', [
      'a',
      'b',
    ], showIf: const ContainsCondition('goal', 'build_strength'));

    expect(errorsWith(step), [contains('ContainsCondition on "goal"')]);
  });

  test('rejects empty all/any groups, even nested', () {
    final step = single('extra', [
      'a',
      'b',
    ], showIf: const NotCondition(AnyCondition([])));

    expect(errorsWith(step), [contains('empty all/any')]);
  });

  test('rejects text missing a required language', () {
    const step = FlowStep(
      id: 'extra',
      type: StepType.text,
      title: LocalizedText({'en': 'Hi', 'ar': ' '}),
    );

    expect(errorsWith(step), [contains('title is missing ar')]);
  });

  test('rejects choice steps with too few options or bad limits', () {
    final step = FlowStep(
      id: 'extra',
      type: StepType.multiChoice,
      title: t('extra'),
      options: [Option(id: 'a', label: t('a'))],
      minSelected: 2,
    );

    expect(errorsWith(step), [
      contains('at least 2 options'),
      contains('invalid min/max'),
    ]);
  });

  test('rejects maxSelected above the option count', () {
    final step = FlowStep(
      id: 'extra',
      type: StepType.multiChoice,
      title: t('extra'),
      options: options(['a', 'b', 'c']),
      maxSelected: 5,
    );

    expect(errorsWith(step), [contains('invalid min/max')]);
  });

  test('rejects minSelected above maxSelected', () {
    final step = FlowStep(
      id: 'extra',
      type: StepType.multiChoice,
      title: t('extra'),
      options: options(['a', 'b', 'c']),
      minSelected: 3,
      maxSelected: 2,
    );

    expect(errorsWith(step), [contains('invalid min/max')]);
  });

  test(
    'a required multi-choice step needs one pick unless it says otherwise',
    () {
      final step = FlowStep(
        id: 'extra',
        type: StepType.multiChoice,
        title: t('extra'),
        options: options(['a', 'b']),
      );

      expect(step.minSelections, 1);
    },
  );

  test('rejects fields that do not belong to the step type', () {
    final text = FlowStep(
      id: 'extra',
      type: StepType.text,
      title: t('extra'),
      options: options(['a', 'b']),
      maxLength: 0,
    );
    final choice = single('extra', ['a', 'b']);
    final singleWithLimits = FlowStep(
      id: choice.id,
      type: choice.type,
      title: choice.title,
      options: choice.options,
      maxSelected: 1,
      maxLength: 10,
    );

    expect(errorsWith(text), [
      contains('has options'),
      contains('max length below 1'),
    ]);
    expect(errorsWith(singleWithLimits), [
      contains('min/max selected but is not multi choice'),
      contains('max length on a choice step'),
    ]);
  });

  test('rejects conditions on free-text steps', () {
    final step = single('extra', [
      'a',
      'b',
    ], showIf: const EqCondition('name', 'Sara'));

    expect(errorsWith(step), [
      contains('EqCondition on "name"'),
      contains('unknown option "Sara"'),
    ]);
  });

  test('rejects an "in" condition with no values', () {
    final step = single('extra', [
      'a',
      'b',
    ], showIf: const InCondition('goal', []));

    expect(errorsWith(step), [contains('no values')]);
  });

  group('summary', () {
    List<String> summaryErrors(SummaryConfig summary) =>
        FlowConfigValidator.findErrors(
          FlowConfig(version: 1, steps: sampleFlow.steps, summary: summary),
        );

    test('needs a last headline without a condition', () {
      final summary = SummaryConfig(
        headlines: [
          SummaryRule(
            text: t('only'),
            showIf: const EqCondition('goal', 'build_strength'),
          ),
        ],
        lines: const [],
      );

      expect(summaryErrors(summary), [contains('last headline')]);
    });

    test('checks rule conditions, languages and placeholders', () {
      final summary = SummaryConfig(
        headlines: [SummaryRule(text: t('{email} and {nickname}'))],
        lines: [
          const SummaryRule(
            text: LocalizedText({'en': 'Hi'}),
            showIf: EqCondition('goal', 'run_marathon'),
          ),
        ],
      );

      expect(summaryErrors(summary), [
        contains('{email}'),
        contains('{nickname}'),
        contains('Summary line 1 is missing ar'),
        contains('unknown option "run_marathon"'),
      ]);
    });
  });
}
