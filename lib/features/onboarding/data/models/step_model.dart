import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/condition.dart';
import '../../domain/entities/flow_step.dart';
import '../../domain/entities/localized_text.dart';
import 'condition_model.dart';
import 'option_model.dart';
import 'step_type_model.dart';

part 'step_model.g.dart';

@JsonSerializable(createToJson: false)
class StepModel {
  const StepModel({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.required = true,
    this.options = const [],
    this.minSelected,
    this.maxSelected,
    this.maxLength,
    this.showIf,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) =>
      _$StepModelFromJson(json);

  final String id;

  @JsonKey(unknownEnumValue: StepTypeModel.unknown)
  final StepTypeModel type;

  final Map<String, String> title;
  final Map<String, String>? subtitle;
  final bool required;
  final List<OptionModel> options;
  final int? minSelected;
  final int? maxSelected;
  final int? maxLength;
  final ConditionModel? showIf;

  FlowStep toEntity() {
    final subtitle = this.subtitle;
    return FlowStep(
      id: id,
      type: switch (type) {
        StepTypeModel.singleChoice => StepType.singleChoice,
        StepTypeModel.multiChoice => StepType.multiChoice,
        StepTypeModel.text => StepType.text,
        StepTypeModel.email => StepType.email,
        StepTypeModel.unknown => throw FormatException(
          'Step "$id" has an unknown type.',
        ),
      },
      title: LocalizedText(title),
      subtitle: subtitle == null ? null : LocalizedText(subtitle),
      required: required,
      options: [for (final option in options) option.toEntity()],
      minSelected: minSelected,
      maxSelected: maxSelected,
      maxLength: maxLength,
      showIf: _showIfEntity(),
    );
  }

  Condition? _showIfEntity() {
    try {
      return showIf?.toEntity();
    } on FormatException catch (e) {
      throw FormatException('Step "$id": ${e.message}');
    }
  }
}
