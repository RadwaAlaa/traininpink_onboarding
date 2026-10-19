import 'package:equatable/equatable.dart';

import '../../../onboarding/domain/entities/plan.dart';

class PaywallState extends Equatable {
  const PaywallState({
    required this.plans,
    this.selectedPlanId,
    this.onPaywall = false,
    this.subscribedPlanId,
    this.subscribing = false,
  });

  final List<Plan> plans;
  final String? selectedPlanId;
  final bool onPaywall;
  final String? subscribedPlanId;

  /// True while her choice is being recorded; subscribe is disabled meanwhile.
  final bool subscribing;

  Plan? get selectedPlan => _plan(selectedPlanId);
  Plan? get subscribedPlan => _plan(subscribedPlanId);

  Plan? _plan(String? id) => plans.where((p) => p.id == id).firstOrNull;

  PaywallState copyWith({
    String? selectedPlanId,
    bool? onPaywall,
    String? subscribedPlanId,
    bool? subscribing,
  }) => PaywallState(
    plans: plans,
    selectedPlanId: selectedPlanId ?? this.selectedPlanId,
    onPaywall: onPaywall ?? this.onPaywall,
    subscribedPlanId: subscribedPlanId ?? this.subscribedPlanId,
    subscribing: subscribing ?? this.subscribing,
  );

  @override
  List<Object?> get props => [
    plans,
    selectedPlanId,
    onPaywall,
    subscribedPlanId,
    subscribing,
  ];
}
