import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/flow_config.dart';
import 'paywall_model.dart';
import 'step_model.dart';
import 'summary_model.dart';

part 'flow_config_model.g.dart';

@JsonSerializable(createToJson: false)
class FlowConfigModel {
  const FlowConfigModel({
    required this.version,
    required this.steps,
    required this.summary,
    required this.paywall,
  });

  factory FlowConfigModel.fromJson(Map<String, dynamic> json) =>
      _$FlowConfigModelFromJson(json);

  final int version;
  final List<StepModel> steps;
  final SummaryModel summary;
  final PaywallModel paywall;

  FlowConfig toEntity() => FlowConfig(
    version: version,
    steps: [for (final step in steps) step.toEntity()],
    summary: summary.toEntity(),
    plans: paywall.toEntity(),
  );
}
