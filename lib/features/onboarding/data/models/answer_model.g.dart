// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnswerModel _$AnswerModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AnswerModel', json, ($checkedConvert) {
      final val = AnswerModel(
        optionId: $checkedConvert('option_id', (v) => v as String?),
        optionIds: $checkedConvert(
          'option_ids',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        text: $checkedConvert('text', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'optionId': 'option_id', 'optionIds': 'option_ids'});

Map<String, dynamic> _$AnswerModelToJson(AnswerModel instance) =>
    <String, dynamic>{
      'option_id': ?instance.optionId,
      'option_ids': ?instance.optionIds,
      'text': ?instance.text,
    };
