// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flow_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlowConfigModel _$FlowConfigModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FlowConfigModel', json, ($checkedConvert) {
      final val = FlowConfigModel(
        version: $checkedConvert('version', (v) => (v as num).toInt()),
        steps: $checkedConvert(
          'steps',
          (v) => (v as List<dynamic>)
              .map((e) => StepModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });
