// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressModel _$ProgressModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ProgressModel',
      json,
      ($checkedConvert) {
        final val = ProgressModel(
          flowVersion: $checkedConvert(
            'flow_version',
            (v) => (v as num).toInt(),
          ),
          currentStepId: $checkedConvert('current_step_id', (v) => v as String),
          answers: $checkedConvert(
            'answers',
            (v) => (v as Map<String, dynamic>).map(
              (k, e) =>
                  MapEntry(k, AnswerModel.fromJson(e as Map<String, dynamic>)),
            ),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'flowVersion': 'flow_version',
        'currentStepId': 'current_step_id',
      },
    );

Map<String, dynamic> _$ProgressModelToJson(ProgressModel instance) =>
    <String, dynamic>{
      'flow_version': instance.flowVersion,
      'current_step_id': instance.currentStepId,
      'answers': instance.answers.map((k, e) => MapEntry(k, e.toJson())),
    };
