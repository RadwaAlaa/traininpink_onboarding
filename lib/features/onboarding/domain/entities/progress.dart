import 'package:equatable/equatable.dart';

import 'answer.dart';

/// Where she is in the flow, saved on every change so she can resume.
class Progress extends Equatable {
  const Progress({
    required this.flowVersion,
    required this.currentStepId,
    required this.answers,
  });

  /// The config version this was saved against; other versions are discarded.
  final int flowVersion;
  final String currentStepId;
  final Map<String, Answer> answers;

  @override
  List<Object?> get props => [flowVersion, currentStepId, answers];
}
