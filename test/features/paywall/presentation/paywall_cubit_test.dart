import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:traininpink_onboarding/features/paywall/domain/entities/paywall_progress.dart';
import 'package:traininpink_onboarding/features/paywall/domain/repositories/paywall_repository.dart';
import 'package:traininpink_onboarding/features/paywall/presentation/cubit/paywall_cubit.dart';

import '../../onboarding/domain/sample_flow.dart';

/// In-memory repository: [saved] is what a relaunch would read back.
class _FakePaywallRepository implements PaywallRepository {
  _FakePaywallRepository([this.saved = const PaywallProgress()]);

  PaywallProgress saved;

  @override
  PaywallProgress load() => saved;

  @override
  Future<void> save(PaywallProgress progress) async => saved = progress;
}

/// Storage that fails every write, like a full disk.
class _FailingPaywallRepository extends _FakePaywallRepository {
  @override
  Future<void> save(PaywallProgress progress) async =>
      throw const FileSystemException('disk full');
}

void main() {
  test('starts on the default plan', () {
    final cubit = PaywallCubit(_FakePaywallRepository(), samplePlans);

    expect(cubit.state.selectedPlanId, 'yearly');
    expect(cubit.state.subscribedPlan, isNull);
  });

  test('keeps a saved choice, but not one that is no longer a plan', () {
    PaywallCubit withSaved(String id) => PaywallCubit(
      _FakePaywallRepository(PaywallProgress(selectedPlanId: id)),
      samplePlans,
    );

    expect(withSaved('monthly').state.selectedPlanId, 'monthly');
    expect(withSaved('weekly').state.selectedPlanId, 'yearly');
  });

  test('selection and being on the paywall are saved', () {
    final repository = _FakePaywallRepository();
    PaywallCubit(repository, samplePlans)
      ..setOnPaywall(true)
      ..select('monthly');

    expect(
      repository.saved,
      const PaywallProgress(selectedPlanId: 'monthly', onPaywall: true),
    );
  });

  test(
    'subscribe records the chosen plan once, even if tapped twice',
    () async {
      final repository = _FakePaywallRepository();
      final cubit = PaywallCubit(repository, samplePlans)..select('monthly');

      final first = cubit.subscribe();
      expect(cubit.state.subscribing, isTrue);
      cubit.select('yearly');
      await Future.wait([first, cubit.subscribe()]);

      expect(cubit.state.subscribedPlan?.id, 'monthly');
      expect(cubit.state.subscribing, isFalse);
      expect(repository.saved.subscribedPlanId, 'monthly');
      expect(repository.saved.onPaywall, isFalse);
    },
  );

  test('a failed save re-enables subscribe instead of sticking', () async {
    final cubit = PaywallCubit(_FailingPaywallRepository(), samplePlans);

    await cubit.subscribe();

    expect(cubit.state.subscribing, isFalse);
    expect(cubit.state.subscribedPlanId, isNull);
  });

  test('a subscription survives its plan leaving the config', () {
    final cubit = PaywallCubit(
      _FakePaywallRepository(
        const PaywallProgress(subscribedPlanId: 'lifetime'),
      ),
      samplePlans,
    );

    expect(cubit.state.subscribedPlanId, 'lifetime');
    expect(cubit.state.subscribedPlan, isNull);
  });

  test('reset forgets the choice and subscription', () async {
    final repository = _FakePaywallRepository();
    final cubit = PaywallCubit(repository, samplePlans)..select('monthly');
    await cubit.subscribe();

    cubit.reset();
    expect(cubit.state.selectedPlanId, 'yearly');
    expect(cubit.state.subscribedPlanId, isNull);
    expect(repository.saved, const PaywallProgress(selectedPlanId: 'yearly'));
  });
}
