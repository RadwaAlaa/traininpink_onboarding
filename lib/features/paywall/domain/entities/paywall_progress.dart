import 'package:equatable/equatable.dart';

/// What she did on the paywall, saved so a relaunch can return her there.
class PaywallProgress extends Equatable {
  const PaywallProgress({
    this.selectedPlanId,
    this.onPaywall = false,
    this.subscribedPlanId,
  });

  final String? selectedPlanId;

  /// She is on the paywall (and not past it).
  final bool onPaywall;

  /// Set once she taps subscribe. Nothing is charged; this records her choice.
  final String? subscribedPlanId;

  @override
  List<Object?> get props => [selectedPlanId, onPaywall, subscribedPlanId];
}
