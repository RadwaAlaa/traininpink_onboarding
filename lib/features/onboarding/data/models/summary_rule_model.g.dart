// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary_rule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SummaryRuleModel _$SummaryRuleModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SummaryRuleModel', json, ($checkedConvert) {
  final val = SummaryRuleModel(
    text: $checkedConvert('text', (v) => Map<String, String>.from(v as Map)),
    showIf: $checkedConvert(
      'show_if',
      (v) =>
          v == null ? null : ConditionModel.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
}, fieldKeyMap: const {'showIf': 'show_if'});
