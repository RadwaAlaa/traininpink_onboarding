// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConditionModel _$ConditionModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ConditionModel', json, ($checkedConvert) {
      final val = ConditionModel(
        eq: $checkedConvert(
          'eq',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        inList: $checkedConvert('in', (v) => v as List<dynamic>?),
        contains: $checkedConvert(
          'contains',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        all: $checkedConvert(
          'all',
          (v) => (v as List<dynamic>?)
              ?.map((e) => ConditionModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        any: $checkedConvert(
          'any',
          (v) => (v as List<dynamic>?)
              ?.map((e) => ConditionModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        not: $checkedConvert(
          'not',
          (v) => v == null
              ? null
              : ConditionModel.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'inList': 'in'});
