import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../onboarding/domain/entities/plan.dart';
import '../../domain/entities/paywall_progress.dart';
import '../../domain/repositories/paywall_repository.dart';
import 'paywall_state.dart';

/// Owns plan selection and the recorded subscription. Nothing is purchased:
/// subscribing only saves which plan she chose.
class PaywallCubit extends Cubit<PaywallState> {
  PaywallCubit(this._repository, List<Plan> plans)
    : super(_initial(plans, _repository.load()));

  final PaywallRepository _repository;

  /// Her saved choice if it is still a plan, otherwise the default plan.
  static PaywallState _initial(List<Plan> plans, PaywallProgress saved) {
    final ids = plans.map((p) => p.id).toSet();
    final savedId = saved.selectedPlanId;
    final defaultId = plans.where((p) => p.defaultSelected).firstOrNull?.id;

    return PaywallState(
      plans: plans,
      selectedPlanId: ids.contains(savedId) ? savedId : defaultId,
      onPaywall: saved.onPaywall,
      // Kept even if the plan has since left the config: she still subscribed.
      subscribedPlanId: saved.subscribedPlanId,
    );
  }

  /// Called when she opens the paywall, and with false when she leaves it.
  void setOnPaywall(bool onPaywall) =>
      _emitAndSave(state.copyWith(onPaywall: onPaywall));

  void select(String planId) {
    if (state.subscribing) return;
    _emitAndSave(state.copyWith(selectedPlanId: planId));
  }

  /// Records her chosen plan. Ignored while already recording.
  Future<void> subscribe() async {
    final planId = state.selectedPlanId;
    if (state.subscribing || planId == null) return;

    emit(state.copyWith(subscribing: true));
    final subscribed = state.copyWith(
      subscribedPlanId: planId,
      onPaywall: false,
      subscribing: false,
    );
    try {
      await _repository.save(_progressOf(subscribed));
      emit(subscribed);
    } catch (error, stackTrace) {
      // Re-enable subscribe so she can try again instead of being stuck.
      addError(error, stackTrace);
      emit(state.copyWith(subscribing: false));
    }
  }

  /// Forgets her plan choice and subscription, for starting over.
  void reset() => _emitAndSave(_initial(state.plans, const PaywallProgress()));

  void _emitAndSave(PaywallState next) {
    if (next == state) return;
    emit(next);
    unawaited(_repository.save(_progressOf(next)));
  }

  static PaywallProgress _progressOf(PaywallState state) => PaywallProgress(
    selectedPlanId: state.selectedPlanId,
    onPaywall: state.onPaywall,
    subscribedPlanId: state.subscribedPlanId,
  );
}
