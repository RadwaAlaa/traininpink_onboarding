import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/localized_text.dart';
import '../../domain/entities/summary_rule.dart';
import 'condition_model.dart';

part 'summary_rule_model.g.dart';

@JsonSerializable(createToJson: false)
class SummaryRuleModel {
  const SummaryRuleModel({required this.text, this.showIf});

  factory SummaryRuleModel.fromJson(Map<String, dynamic> json) =>
      _$SummaryRuleModelFromJson(json);

  final Map<String, String> text;
  final ConditionModel? showIf;

  SummaryRule toEntity() =>
      SummaryRule(text: LocalizedText(text), showIf: showIf?.toEntity());
}
