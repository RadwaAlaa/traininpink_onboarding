import 'package:flutter_test/flutter_test.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/answer.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/progress.dart';
import 'package:traininpink_onboarding/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:traininpink_onboarding/features/onboarding/presentation/cubit/onboarding_status.dart';

import '../domain/sample_flow.dart';
import 'fake_onboarding_repository.dart';

void main() {
  late FakeOnboardingRepository repository;

  Future<OnboardingCubit> loaded({Progress? saved}) async {
    repository = FakeOnboardingRepository(sampleFlow, saved: saved);
    final cubit = OnboardingCubit(repository);
    await cubit.load();
    return cubit;
  }

  List<String> pathIds(OnboardingCubit cubit) =>
      cubit.state.path.map((s) => s.id).toList();

  test('starts at the first step with nothing answered', () async {
    final cubit = await loaded();

    expect(cubit.state.status, OnboardingStatus.ready);
    expect(cubit.state.currentStepId, 'goal');
    expect(cubit.state.canContinue, isFalse);
  });

  test('shows the failure state if the config cannot load', () async {
    final cubit = OnboardingCubit(FakeOnboardingRepository(null));
    await cubit.load();

    expect(cubit.state.status, OnboardingStatus.failure);
  });

  test('resumes saved progress at the saved step', () async {
    final cubit = await loaded(
      saved: const Progress(
        flowVersion: 1,
        currentStepId: 'last_trained',
        answers: {'goal': SingleChoiceAnswer('get_back_into_it')},
      ),
    );

    expect(cubit.state.currentStepId, 'last_trained');
    expect(cubit.state.answers.keys, ['goal']);
  });

  test('an answer re-routes the path and every change is saved', () async {
    final cubit = await loaded();

    cubit.selectOption('get_back_into_it');
    expect(pathIds(cubit), contains('last_trained'));
    expect(repository.saved?.answers['goal'], isNotNull);

    cubit.next();
    expect(cubit.state.currentStepId, 'last_trained');
    expect(repository.saved?.currentStepId, 'last_trained');
  });

  test(
    'going back keeps her answer; changing it prunes the old branch',
    () async {
      final cubit = await loaded();
      cubit
        ..selectOption('get_back_into_it')
        ..next()
        ..selectOption('over_a_year')
        ..back();

      expect(cubit.state.currentStepId, 'goal');
      expect(cubit.state.movedBack, isTrue);
      expect(
        cubit.state.currentAnswer,
        const SingleChoiceAnswer('get_back_into_it'),
      );

      cubit.selectOption('build_strength');
      expect(pathIds(cubit), isNot(contains('last_trained')));
      expect(cubit.state.answers.keys, ['goal']);
      expect(repository.saved?.answers.keys, ['goal']);
    },
  );

  test('next does nothing until the answer is complete', () async {
    final cubit = await loaded();
    cubit.next();

    expect(cubit.state.currentStepId, 'goal');
  });

  test('toggling options adds and removes; empty clears the answer', () async {
    final cubit = await loaded();
    cubit
      ..selectOption('build_strength')
      ..next()
      ..toggleOption('core')
      ..toggleOption('legs');

    expect(cubit.state.currentAnswer, MultiChoiceAnswer({'core', 'legs'}));
    expect(pathIds(cubit), contains('core_pain'));

    cubit
      ..toggleOption('core')
      ..toggleOption('legs');
    expect(cubit.state.currentAnswer, isNull);
    expect(cubit.state.canContinue, isFalse);
  });

  test('text is stored trimmed and blank text clears the answer', () async {
    final cubit = await loaded(
      saved: const Progress(flowVersion: 1, currentStepId: 'name', answers: {}),
    );

    cubit.enterText('  Sara ');
    expect(cubit.state.currentAnswer, const TextAnswer('Sara'));

    cubit.enterText('   ');
    expect(cubit.state.currentAnswer, isNull);
  });

  test('a resumed path counts as started; a fresh one does not', () async {
    expect((await loaded()).state.hasStarted, isFalse);

    final resumed = await loaded(
      saved: const Progress(
        flowVersion: 1,
        currentStepId: 'focus_areas',
        answers: {'goal': SingleChoiceAnswer('tone_up')},
      ),
    );
    expect(resumed.state.hasStarted, isTrue);
  });

  test('re-selecting the same option saves nothing', () async {
    final cubit = await loaded();
    cubit.selectOption('build_strength');
    repository.saved = null;

    cubit.selectOption('build_strength');
    expect(repository.saved, isNull);
  });

  test('reaching the summary is saved and survives a relaunch', () async {
    final cubit = await loaded(
      saved: Progress(
        flowVersion: 1,
        currentStepId: 'email',
        answers: {
          'goal': const SingleChoiceAnswer('lose_weight'),
          'focus_areas': MultiChoiceAnswer({'legs'}),
          'heavy_lifting': const SingleChoiceAnswer('no'),
          'name': const TextAnswer('Sara'),
          'email': const TextAnswer('sara@mail.com'),
        },
      ),
    );
    cubit.setReachedSummary(true);
    expect(repository.saved?.reachedSummary, isTrue);

    final relaunched = OnboardingCubit(repository);
    await relaunched.load();
    expect(relaunched.state.reachedSummary, isTrue);
  });

  test('reset clears answers and starts at the first step', () async {
    final cubit = await loaded();
    cubit
      ..selectOption('get_back_into_it')
      ..next()
      ..setReachedSummary(true)
      ..reset();

    expect(cubit.state.currentStepId, 'goal');
    expect(cubit.state.answers, isEmpty);
    expect(repository.saved?.reachedSummary, isFalse);
    expect(repository.saved?.answers, isEmpty);
  });
}
