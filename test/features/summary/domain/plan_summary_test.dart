import 'package:flutter_test/flutter_test.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/engine/flow_engine.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/answer.dart';
import 'package:traininpink_onboarding/features/summary/domain/plan_summary.dart';

import '../../onboarding/domain/sample_flow.dart';

void main() {
  final engine = FlowEngine(sampleFlow);

  /// What the app does: prune to the path, then write the summary.
  PlanSummary summaryFor(Map<String, Answer> answers) =>
      PlanSummary.fromAnswers(
        sampleSummary,
        engine.pruneAnswers(engine.resolvePath(answers), answers),
        'en',
      );

  final comeback = {
    'goal': const SingleChoiceAnswer('get_back_into_it'),
    'last_trained': const SingleChoiceAnswer('over_a_year'),
    'restart_pace': const SingleChoiceAnswer('gentle'),
    'focus_areas': MultiChoiceAnswer({'core'}),
    'name': const TextAnswer('Sara'),
  };

  test('is written from the path she took, with her name filled in', () {
    expect(
      summaryFor(comeback),
      const PlanSummary(
        headline: 'Sara: comeback',
        lines: ['gentle start', 'core finisher'],
      ),
    );
  });

  test('changes when an earlier answer changes the path', () {
    final changed = summaryFor({
      ...comeback,
      'goal': const SingleChoiceAnswer('build_strength'),
    });

    // The comeback branch is pruned, so its headline and line both go.
    expect(changed.headline, 'Sara: your plan');
    expect(changed.lines, ['core finisher']);
  });
}
