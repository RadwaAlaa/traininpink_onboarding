import 'package:flutter_test/flutter_test.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/answer.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/flow_step.dart';

import 'sample_flow.dart';

void main() {
  FlowStep step(String id) => sampleFlow.steps.firstWhere((s) => s.id == id);

  test('a required step needs an answer; an optional one does not', () {
    expect(step('goal').isComplete(null), isFalse);
    expect(step('goal').isComplete(const SingleChoiceAnswer('tone')), isTrue);
    expect(
      FlowStep(
        id: 'notes',
        type: StepType.text,
        title: t('notes'),
        required: false,
      ).isComplete(null),
      isTrue,
    );
  });

  test('multi choice respects min and max selected', () {
    final limited = FlowStep(
      id: 'focus',
      type: StepType.multiChoice,
      title: t('focus'),
      options: options(['a', 'b', 'c']),
      minSelected: 2,
      maxSelected: 2,
    );

    expect(limited.isComplete(MultiChoiceAnswer({'a'})), isFalse);
    expect(limited.isComplete(MultiChoiceAnswer({'a', 'b'})), isTrue);
    expect(limited.isComplete(MultiChoiceAnswer({'a', 'b', 'c'})), isFalse);
    expect(limited.isAtMax(MultiChoiceAnswer({'a'})), isFalse);
    expect(limited.isAtMax(MultiChoiceAnswer({'a', 'b'})), isTrue);
  });

  test('email must look like an address', () {
    for (final valid in ['sara@example.com', ' sara.k+fit@mail.co.uk ']) {
      expect(FlowStep.isValidEmail(valid), isTrue, reason: valid);
    }
    for (final invalid in [
      'sara',
      'sara@',
      'sara@mail',
      'sa ra@mail.com',
      '@mail.com',
    ]) {
      expect(FlowStep.isValidEmail(invalid), isFalse, reason: invalid);
    }
    expect(step('email').isComplete(const TextAnswer('sara@mail')), isFalse);
  });
}
