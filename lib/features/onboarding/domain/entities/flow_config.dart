import 'package:equatable/equatable.dart';

import 'flow_step.dart';

/// The whole onboarding flow as loaded from config.
class FlowConfig extends Equatable {
  const FlowConfig({required this.version, required this.steps});

  /// Saved progress from a different version is discarded.
  final int version;

  /// Ordered list; the visible path is the steps whose `showIf` passes.
  final List<FlowStep> steps;

  @override
  List<Object?> get props => [version, steps];
}
