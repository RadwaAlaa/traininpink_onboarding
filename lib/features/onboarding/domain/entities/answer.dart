import 'package:equatable/equatable.dart';

/// What she answered on one step. The variant matches the step type.
sealed class Answer extends Equatable {
  const Answer();
}

final class SingleChoiceAnswer extends Answer {
  const SingleChoiceAnswer(this.optionId);

  final String optionId;

  @override
  List<Object?> get props => [optionId];
}

final class MultiChoiceAnswer extends Answer {
  /// Copies into an unmodifiable set: changing a selection must build a new
  /// answer, or state equality would hide the change.
  MultiChoiceAnswer(Iterable<String> optionIds)
    : optionIds = Set.unmodifiable(optionIds);

  final Set<String> optionIds;

  @override
  List<Object?> get props => [optionIds];
}

/// Free text and email answers.
final class TextAnswer extends Answer {
  const TextAnswer(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}
