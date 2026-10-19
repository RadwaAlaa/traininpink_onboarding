import 'package:flutter_test/flutter_test.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/engine/flow_engine.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/answer.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/progress.dart';

import 'sample_flow.dart';

void main() {
  final engine = FlowEngine(sampleFlow);

  List<String> pathIds(Map<String, Answer> answers) =>
      engine.resolvePath(answers).map((s) => s.id).toList();

  String? nextId(String id, Map<String, Answer> answers) =>
      engine.next(engine.resolvePath(answers), id)?.id;

  String? previousId(String id, Map<String, Answer> answers) =>
      engine.previous(engine.resolvePath(answers), id)?.id;

  /// What the cubit does on every change: resolve, then prune.
  Map<String, Answer> settle(Map<String, Answer> answers) =>
      engine.pruneAnswers(engine.resolvePath(answers), answers);

  test('unconditional steps form the path when nothing is answered', () {
    expect(pathIds({}), ['goal', 'focus_areas', 'name', 'email']);
  });

  group('brief example: last_trained only for get_back_into_it', () {
    const getBack = SingleChoiceAnswer('get_back_into_it');
    const buildStrength = SingleChoiceAnswer('build_strength');

    test('is asked when goal is get_back_into_it', () {
      expect(pathIds({'goal': getBack}), contains('last_trained'));
      expect(nextId('goal', {'goal': getBack}), 'last_trained');
    });

    test('switching goal to build_strength removes it from path and answers, '
        'keeping answers still on the path', () {
      final before = settle({
        'goal': getBack,
        'last_trained': const SingleChoiceAnswer('under_3_months'),
        'focus_areas': MultiChoiceAnswer({'arms'}),
        'name': const TextAnswer('Sara'),
      });
      expect(before, contains('last_trained'));

      final after = settle({...before, 'goal': buildStrength});

      expect(pathIds(after), isNot(contains('last_trained')));
      expect(after, isNot(contains('last_trained')));
      expect(after['focus_areas'], MultiChoiceAnswer({'arms'}));
      expect(after['name'], const TextAnswer('Sara'));
      expect(nextId('goal', after), 'focus_areas');
    });

    test('switching back re-asks it with no stale answer', () {
      final strength = settle({
        'goal': getBack,
        'last_trained': const SingleChoiceAnswer('over_a_year'),
      });
      final changed = settle({...strength, 'goal': buildStrength});
      final back = settle({...changed, 'goal': getBack});

      expect(pathIds(back), contains('last_trained'));
      expect(back, isNot(contains('last_trained')));
    });
  });

  test('a stale answer from a skipped step cannot switch a later step on', () {
    final answers = {
      'goal': const SingleChoiceAnswer('build_strength'),
      'last_trained': const SingleChoiceAnswer('over_a_year'),
    };

    expect(pathIds(answers), isNot(contains('restart_pace')));
  });

  test('nested branch follows its parent: restart_pace leaves with goal', () {
    final deep = settle({
      'goal': const SingleChoiceAnswer('get_back_into_it'),
      'last_trained': const SingleChoiceAnswer('over_a_year'),
      'restart_pace': const SingleChoiceAnswer('gentle'),
    });
    expect(pathIds(deep), containsAllInOrder(['last_trained', 'restart_pace']));

    final changed = settle({
      ...deep,
      'goal': const SingleChoiceAnswer('lose_weight'),
    });
    expect(changed.keys, ['goal']);
  });

  test('multi-choice contains branch: core_pain only when core selected', () {
    expect(
      pathIds({
        'focus_areas': MultiChoiceAnswer({'legs', 'core'}),
      }),
      contains('core_pain'),
    );
    expect(
      pathIds({
        'focus_areas': MultiChoiceAnswer({'legs'}),
      }),
      isNot(contains('core_pain')),
    );
  });

  group('nested all/any/not: heavy_lifting', () {
    bool shown(String goal, Set<String> focus) => pathIds({
      'goal': SingleChoiceAnswer(goal),
      'focus_areas': MultiChoiceAnswer(focus),
    }).contains('heavy_lifting');

    test('any: build_strength (eq) or lose_weight (in)', () {
      expect(shown('build_strength', {'legs'}), isTrue);
      expect(shown('lose_weight', {'legs'}), isTrue);
      expect(shown('get_back_into_it', {'legs'}), isFalse);
    });

    test('not: hidden when arms is selected', () {
      expect(shown('build_strength', {'legs', 'arms'}), isFalse);
    });

    test('not on an unanswered step is true, but all still needs any', () {
      expect(pathIds({}), isNot(contains('heavy_lifting')));
    });
  });

  test('a multi-choice answer cannot be changed in place', () {
    final answer = MultiChoiceAnswer({'legs'});
    expect(() => answer.optionIds.add('core'), throwsUnsupportedError);
  });

  group('next / previous', () {
    final answers = {'goal': const SingleChoiceAnswer('get_back_into_it')};

    test('walk the resolved path in both directions', () {
      expect(previousId('focus_areas', answers), 'last_trained');
      expect(previousId('focus_areas', {}), 'goal');
      expect(nextId('name', answers), 'email');
    });

    test('return null at either end or for a step off the path', () {
      expect(previousId('goal', answers), isNull);
      expect(nextId('email', answers), isNull);
      expect(nextId('last_trained', {}), isNull);
    });
  });

  group('restore', () {
    Progress saved({
      int flowVersion = 1,
      String currentStepId = 'name',
      Map<String, Answer> answers = const {},
      bool reachedSummary = false,
    }) => Progress(
      flowVersion: flowVersion,
      currentStepId: currentStepId,
      answers: answers,
      reachedSummary: reachedSummary,
    );

    test('keeps progress that still fits the config', () {
      final progress = saved(
        answers: {'goal': const SingleChoiceAnswer('build_strength')},
      );

      expect(engine.restore(progress), progress);
    });

    test('discards progress from another config version', () {
      expect(engine.restore(saved(flowVersion: 2)), isNull);
    });

    test('drops answers off the path and restarts a step that left it', () {
      final restored = engine.restore(
        saved(
          currentStepId: 'removed_step',
          answers: {
            'goal': const SingleChoiceAnswer('build_strength'),
            'last_trained': const SingleChoiceAnswer('over_a_year'),
          },
        ),
      );

      expect(restored?.currentStepId, 'goal');
      expect(restored?.answers.keys, ['goal']);
    });

    test('reopens the summary only if every step on the path is answered', () {
      final answers = {
        'goal': const SingleChoiceAnswer('build_strength'),
        'focus_areas': MultiChoiceAnswer({'legs'}),
        'heavy_lifting': const SingleChoiceAnswer('yes'),
        'name': const TextAnswer('Sara'),
        'email': const TextAnswer('sara@mail.com'),
      };
      Progress atSummary(Map<String, Answer> answers) =>
          saved(currentStepId: 'email', answers: answers, reachedSummary: true);

      expect(engine.restore(atSummary(answers))?.reachedSummary, isTrue);
      expect(
        engine.restore(atSummary({...answers}..remove('name')))?.reachedSummary,
        isFalse,
      );
    });
  });
}
