import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/plan.dart';
import 'plan_model.dart';

part 'paywall_model.g.dart';

/// The config's `paywall` section.
@JsonSerializable(createToJson: false)
class PaywallModel {
  const PaywallModel({required this.plans});

  factory PaywallModel.fromJson(Map<String, dynamic> json) =>
      _$PaywallModelFromJson(json);

  final List<PlanModel> plans;

  List<Plan> toEntity() => [for (final plan in plans) plan.toEntity()];
}
