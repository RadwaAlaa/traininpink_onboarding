import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/localized_text.dart';
import '../../domain/entities/plan.dart';

part 'plan_model.g.dart';

@JsonSerializable(createToJson: false)
class PlanModel {
  const PlanModel({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.period,
    this.trialDays = 0,
    this.badge,
    this.defaultSelected = false,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) =>
      _$PlanModelFromJson(json);

  final String id;
  final Map<String, String> title;
  final Map<String, String> priceLabel;
  final Map<String, String> period;
  final int trialDays;
  final Map<String, String>? badge;
  final bool defaultSelected;

  Plan toEntity() {
    final badge = this.badge;
    return Plan(
      id: id,
      title: LocalizedText(title),
      priceLabel: LocalizedText(priceLabel),
      period: LocalizedText(period),
      trialDays: trialDays,
      badge: badge == null ? null : LocalizedText(badge),
      defaultSelected: defaultSelected,
    );
  }
}
