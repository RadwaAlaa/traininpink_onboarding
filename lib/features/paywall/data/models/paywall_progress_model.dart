import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/paywall_progress.dart';

part 'paywall_progress_model.g.dart';

@JsonSerializable(includeIfNull: false)
class PaywallProgressModel {
  const PaywallProgressModel({
    this.selectedPlanId,
    this.onPaywall = false,
    this.subscribedPlanId,
  });

  factory PaywallProgressModel.fromJson(Map<String, dynamic> json) =>
      _$PaywallProgressModelFromJson(json);

  factory PaywallProgressModel.fromEntity(PaywallProgress progress) =>
      PaywallProgressModel(
        selectedPlanId: progress.selectedPlanId,
        onPaywall: progress.onPaywall,
        subscribedPlanId: progress.subscribedPlanId,
      );

  final String? selectedPlanId;
  final bool onPaywall;
  final String? subscribedPlanId;

  Map<String, dynamic> toJson() => _$PaywallProgressModelToJson(this);

  PaywallProgress toEntity() => PaywallProgress(
    selectedPlanId: selectedPlanId,
    onPaywall: onPaywall,
    subscribedPlanId: subscribedPlanId,
  );
}
