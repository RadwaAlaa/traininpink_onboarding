// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptionModel _$OptionModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OptionModel', json, ($checkedConvert) {
      final val = OptionModel(
        id: $checkedConvert('id', (v) => v as String),
        label: $checkedConvert(
          'label',
          (v) => Map<String, String>.from(v as Map),
        ),
      );
      return val;
    });
