import 'package:equatable/equatable.dart';

import 'answer.dart';

/// A `show_if` rule, evaluated against the answers already on her path.
/// A step that has not been answered never matches a leaf condition.
sealed class Condition extends Equatable {
  const Condition();

  bool evaluate(Map<String, Answer> answers);

  /// Every leaf in this tree, so the validator can check what they reference.
  Iterable<AnswerCondition> get leaves;
}

/// Leaf condition: tests the answer of one earlier step.
sealed class AnswerCondition extends Condition {
  const AnswerCondition(this.stepId);

  final String stepId;

  /// The option ids this condition compares against.
  List<String> get values;

  @override
  Iterable<AnswerCondition> get leaves => [this];
}

/// `{"eq": [stepId, value]}` — single choice is [value].
final class EqCondition extends AnswerCondition {
  const EqCondition(super.stepId, this.value);

  final String value;

  @override
  List<String> get values => [value];

  @override
  bool evaluate(Map<String, Answer> answers) => switch (answers[stepId]) {
    SingleChoiceAnswer(:final optionId) => optionId == value,
    _ => false,
  };

  @override
  List<Object?> get props => [stepId, value];
}

/// `{"in": [stepId, [a, b]]}` — single choice is one of [values].
final class InCondition extends AnswerCondition {
  const InCondition(super.stepId, this.values);

  @override
  final List<String> values;

  @override
  bool evaluate(Map<String, Answer> answers) => switch (answers[stepId]) {
    SingleChoiceAnswer(:final optionId) => values.contains(optionId),
    _ => false,
  };

  @override
  List<Object?> get props => [stepId, values];
}

/// `{"contains": [stepId, value]}` — multi choice includes [value].
final class ContainsCondition extends AnswerCondition {
  const ContainsCondition(super.stepId, this.value);

  final String value;

  @override
  List<String> get values => [value];

  @override
  bool evaluate(Map<String, Answer> answers) => switch (answers[stepId]) {
    MultiChoiceAnswer(:final optionIds) => optionIds.contains(value),
    _ => false,
  };

  @override
  List<Object?> get props => [stepId, value];
}

/// `{"all": [...]}` — every child is true.
final class AllCondition extends Condition {
  const AllCondition(this.children);

  final List<Condition> children;

  @override
  bool evaluate(Map<String, Answer> answers) =>
      children.every((c) => c.evaluate(answers));

  @override
  Iterable<AnswerCondition> get leaves => children.expand((c) => c.leaves);

  @override
  List<Object?> get props => [children];
}

/// `{"any": [...]}` — at least one child is true.
final class AnyCondition extends Condition {
  const AnyCondition(this.children);

  final List<Condition> children;

  @override
  bool evaluate(Map<String, Answer> answers) =>
      children.any((c) => c.evaluate(answers));

  @override
  Iterable<AnswerCondition> get leaves => children.expand((c) => c.leaves);

  @override
  List<Object?> get props => [children];
}

/// `{"not": {...}}` — the child is false.
final class NotCondition extends Condition {
  const NotCondition(this.child);

  final Condition child;

  @override
  bool evaluate(Map<String, Answer> answers) => !child.evaluate(answers);

  @override
  Iterable<AnswerCondition> get leaves => child.leaves;

  @override
  List<Object?> get props => [child];
}
