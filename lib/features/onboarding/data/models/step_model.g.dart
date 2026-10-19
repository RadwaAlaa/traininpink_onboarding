// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepModel _$StepModelFromJson(Map<String, dynamic> json) => $checkedCreate(
  'StepModel',
  json,
  ($checkedConvert) {
    final val = StepModel(
      id: $checkedConvert('id', (v) => v as String),
      type: $checkedConvert(
        'type',
        (v) => $enumDecode(
          _$StepTypeModelEnumMap,
          v,
          unknownValue: StepTypeModel.unknown,
        ),
      ),
      title: $checkedConvert(
        'title',
        (v) => Map<String, String>.from(v as Map),
      ),
      subtitle: $checkedConvert(
        'subtitle',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as String),
        ),
      ),
      required: $checkedConvert('required', (v) => v as bool? ?? true),
      options: $checkedConvert(
        'options',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => OptionModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      ),
      minSelected: $checkedConvert('min_selected', (v) => (v as num?)?.toInt()),
      maxSelected: $checkedConvert('max_selected', (v) => (v as num?)?.toInt()),
      maxLength: $checkedConvert('max_length', (v) => (v as num?)?.toInt()),
      showIf: $checkedConvert(
        'show_if',
        (v) => v == null
            ? null
            : ConditionModel.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'minSelected': 'min_selected',
    'maxSelected': 'max_selected',
    'maxLength': 'max_length',
    'showIf': 'show_if',
  },
);

const _$StepTypeModelEnumMap = {
  StepTypeModel.singleChoice: 'single_choice',
  StepTypeModel.multiChoice: 'multi_choice',
  StepTypeModel.text: 'text',
  StepTypeModel.email: 'email',
  StepTypeModel.unknown: 'unknown',
};
