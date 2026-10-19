import 'package:flutter_test/flutter_test.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/engine/flow_engine.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/answer.dart';

import 'sample_flow.dart';

void main() {
  final engine = FlowEngine(sampleFlow);

  List<String> pathIds(Map<String, Answer> answers) =>
      engine.resolvePath(answers).map((s) => s.id).toList();

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
      expect(engine.next('goal', {'goal': getBack})?.id, 'last_trained');
    });

    test('switching goal to build_strength removes it from path and answers, '
        'keeping answers still on the path', () {
      final before = settle({
        'goal': getBack,
        'last_trained': const SingleChoiceAnswer('under_3_months'),
        'focus_areas': const MultiChoiceAnswer({'arms'}),
        'name': const TextAnswer('Sara'),
      });
      expect(before, contains('last_trained'));

      final after = settle({...before, 'goal': buildStrength});

      expect(pathIds(after), isNot(contains('last_trained')));
      expect(after, isNot(contains('last_trained')));
      expect(after['focus_areas'], const MultiChoiceAnswer({'arms'}));
      expect(after['name'], const TextAnswer('Sara'));
      expect(engine.next('goal', after)?.id, 'focus_areas');
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
        'focus_areas': const MultiChoiceAnswer({'legs', 'core'}),
      }),
      contains('core_pain'),
    );
    expect(
      pathIds({
        'focus_areas': const MultiChoiceAnswer({'legs'}),
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

  group('next / previous', () {
    final answers = {'goal': const SingleChoiceAnswer('get_back_into_it')};

    test('walk the resolved path in both directions', () {
      expect(engine.previous('focus_areas', answers)?.id, 'last_trained');
      expect(engine.previous('focus_areas', {})?.id, 'goal');
      expect(engine.next('name', answers)?.id, 'email');
    });

    test('return null at either end or for a step off the path', () {
      expect(engine.previous('goal', answers), isNull);
      expect(engine.next('email', answers), isNull);
      expect(engine.next('last_trained', {}), isNull);
    });
  });
}
