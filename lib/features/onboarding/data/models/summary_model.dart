import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/summary_config.dart';
import 'summary_rule_model.dart';

part 'summary_model.g.dart';

@JsonSerializable(createToJson: false)
class SummaryModel {
  const SummaryModel({required this.headlines, required this.lines});

  factory SummaryModel.fromJson(Map<String, dynamic> json) =>
      _$SummaryModelFromJson(json);

  final List<SummaryRuleModel> headlines;
  final List<SummaryRuleModel> lines;

  SummaryConfig toEntity() => SummaryConfig(
    headlines: [for (final rule in headlines) rule.toEntity()],
    lines: [for (final rule in lines) rule.toEntity()],
  );
}
