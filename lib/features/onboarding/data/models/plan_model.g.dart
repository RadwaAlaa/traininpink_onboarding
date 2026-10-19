// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanModel _$PlanModelFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PlanModel',
  json,
  ($checkedConvert) {
    final val = PlanModel(
      id: $checkedConvert('id', (v) => v as String),
      title: $checkedConvert(
        'title',
        (v) => Map<String, String>.from(v as Map),
      ),
      priceLabel: $checkedConvert(
        'price_label',
        (v) => Map<String, String>.from(v as Map),
      ),
      period: $checkedConvert(
        'period',
        (v) => Map<String, String>.from(v as Map),
      ),
      trialDays: $checkedConvert(
        'trial_days',
        (v) => (v as num?)?.toInt() ?? 0,
      ),
      badge: $checkedConvert(
        'badge',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as String),
        ),
      ),
      defaultSelected: $checkedConvert(
        'default_selected',
        (v) => v as bool? ?? false,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'priceLabel': 'price_label',
    'trialDays': 'trial_days',
    'defaultSelected': 'default_selected',
  },
);
