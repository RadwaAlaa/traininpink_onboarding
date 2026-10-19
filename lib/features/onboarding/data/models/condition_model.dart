import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/condition.dart';

part 'condition_model.g.dart';

/// A `show_if` object. Exactly one operator key must be set:
/// `eq: [step, option]`, `in: [step, [options]]`, `contains: [step, option]`,
/// `all: [conditions]`, `any: [conditions]` or `not: condition`.
@JsonSerializable(createToJson: false)
class ConditionModel {
  const ConditionModel({
    this.eq,
    this.inList,
    this.contains,
    this.all,
    this.any,
    this.not,
  });

  factory ConditionModel.fromJson(Map<String, dynamic> json) =>
      _$ConditionModelFromJson(json);

  final List<String>? eq;

  /// `in` is a Dart keyword, hence the field name. It mixes a step id with a
  /// list of option ids, so its shape is checked in [toEntity].
  @JsonKey(name: 'in')
  final List<Object?>? inList;

  final List<String>? contains;
  final List<ConditionModel>? all;
  final List<ConditionModel>? any;
  final ConditionModel? not;

  Condition toEntity() {
    final operatorCount = [eq, inList, contains, all, any, not].nonNulls.length;
    if (operatorCount == 1) {
      if (eq case [final stepId, final value]) {
        return EqCondition(stepId, value);
      }
      if (contains case [final stepId, final value]) {
        return ContainsCondition(stepId, value);
      }
      if (inList case [final String stepId, final List<Object?> values]
          when values.every((v) => v is String)) {
        return InCondition(stepId, List<String>.from(values));
      }
      if (all case final children?) {
        return AllCondition([for (final c in children) c.toEntity()]);
      }
      if (any case final children?) {
        return AnyCondition([for (final c in children) c.toEntity()]);
      }
      if (not case final child?) return NotCondition(child.toEntity());
    }
    throw const FormatException(
      'Invalid show_if: use exactly one of eq [step, option], '
      'in [step, [options]], contains [step, option], all, any or not.',
    );
  }
}
