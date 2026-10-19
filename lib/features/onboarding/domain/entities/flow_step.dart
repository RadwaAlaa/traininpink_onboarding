import 'package:equatable/equatable.dart';

import 'condition.dart';
import 'localized_text.dart';
import 'option.dart';

enum StepType { singleChoice, multiChoice, text, email }

/// One question in the flow. Named `FlowStep` (not `Step`) to avoid clashing
/// with Flutter's material `Step` widget in presentation code.
class FlowStep extends Equatable {
  const FlowStep({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.required = true,
    this.options = const [],
    this.minSelected,
    this.maxSelected,
    this.maxLength,
    this.showIf,
  });

  final String id;
  final StepType type;
  final LocalizedText title;
  final LocalizedText? subtitle;
  final bool required;

  /// Choice steps only.
  final List<Option> options;

  /// Multi-choice only.
  final int? minSelected;
  final int? maxSelected;

  /// Text steps only.
  final int? maxLength;

  /// The step is on her path only if this is null or evaluates true.
  final Condition? showIf;

  bool get isChoice =>
      type == StepType.singleChoice || type == StepType.multiChoice;

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    subtitle,
    required,
    options,
    minSelected,
    maxSelected,
    maxLength,
    showIf,
  ];
}
