import 'package:flutter_test/flutter_test.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/engine/flow_config_validator.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/condition.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/flow_config.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/flow_step.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/localized_text.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/option.dart';

import 'sample_flow.dart';

void main() {
  List<String> errorsWith(FlowStep extra) => FlowConfigValidator.findErrors(
    FlowConfig(version: 1, steps: [...sampleFlow.steps, extra]),
  );

  test('the sample flow is valid', () {
    expect(FlowConfigValidator.findErrors(sampleFlow), isEmpty);
    expect(() => FlowConfigValidator.validate(sampleFlow), returnsNormally);
  });

  test('rejects an empty config', () {
    expect(
      () =>
          FlowConfigValidator.validate(const FlowConfig(version: 1, steps: [])),
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
    );

    expect(FlowConfigValidator.findErrors(config), [
      contains('not an earlier step'),
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
}
