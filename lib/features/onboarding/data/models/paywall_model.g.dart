// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paywall_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaywallModel _$PaywallModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PaywallModel', json, ($checkedConvert) {
      final val = PaywallModel(
        plans: $checkedConvert(
          'plans',
          (v) => (v as List<dynamic>)
              .map((e) => PlanModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });
