import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/flow_config.dart';
import 'step_model.dart';

part 'flow_config_model.g.dart';

@JsonSerializable(createToJson: false)
class FlowConfigModel {
  const FlowConfigModel({required this.version, required this.steps});

  factory FlowConfigModel.fromJson(Map<String, dynamic> json) =>
      _$FlowConfigModelFromJson(json);

  final int version;
  final List<StepModel> steps;

  FlowConfig toEntity() => FlowConfig(
    version: version,
    steps: [for (final step in steps) step.toEntity()],
  );
}
