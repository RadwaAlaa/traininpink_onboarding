// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SummaryModel _$SummaryModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SummaryModel', json, ($checkedConvert) {
      final val = SummaryModel(
        headlines: $checkedConvert(
          'headlines',
          (v) => (v as List<dynamic>)
              .map((e) => SummaryRuleModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        lines: $checkedConvert(
          'lines',
          (v) => (v as List<dynamic>)
              .map((e) => SummaryRuleModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });
