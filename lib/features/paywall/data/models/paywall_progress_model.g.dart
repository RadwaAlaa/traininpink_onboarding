// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paywall_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaywallProgressModel _$PaywallProgressModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PaywallProgressModel',
  json,
  ($checkedConvert) {
    final val = PaywallProgressModel(
      selectedPlanId: $checkedConvert('selected_plan_id', (v) => v as String?),
      onPaywall: $checkedConvert('on_paywall', (v) => v as bool? ?? false),
      subscribedPlanId: $checkedConvert(
        'subscribed_plan_id',
        (v) => v as String?,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'selectedPlanId': 'selected_plan_id',
    'onPaywall': 'on_paywall',
    'subscribedPlanId': 'subscribed_plan_id',
  },
);

Map<String, dynamic> _$PaywallProgressModelToJson(
  PaywallProgressModel instance,
) => <String, dynamic>{
  'selected_plan_id': ?instance.selectedPlanId,
  'on_paywall': instance.onPaywall,
  'subscribed_plan_id': ?instance.subscribedPlanId,
};
