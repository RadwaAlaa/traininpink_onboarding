import 'package:equatable/equatable.dart';

import 'condition.dart';
import 'localized_text.dart';

/// One piece of summary text, shown when [showIf] is null or true for the
/// answers on her path. `{step_id}` in the text is replaced by her answer to
/// that text step (e.g. `{name}`).
class SummaryRule extends Equatable {
  const SummaryRule({required this.text, this.showIf});

  /// Matches `{step_id}`; group 1 is the step id.
  static final RegExp placeholder = RegExp(r'\{(\w+)\}');

  final LocalizedText text;
  final Condition? showIf;

  @override
  List<Object?> get props => [text, showIf];
}
