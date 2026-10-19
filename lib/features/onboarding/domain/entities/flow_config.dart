import 'package:equatable/equatable.dart';

import 'flow_step.dart';
import 'plan.dart';
import 'summary_config.dart';

/// The whole onboarding flow as loaded from config.
class FlowConfig extends Equatable {
  const FlowConfig({
    required this.version,
    required this.steps,
    required this.summary,
    required this.plans,
  });

  /// Saved progress from a different version is discarded.
  final int version;

  /// Ordered list; the visible path is the steps whose `showIf` passes.
  final List<FlowStep> steps;

  final SummaryConfig summary;

  /// Paywall plans, in display order.
  final List<Plan> plans;

  @override
  List<Object?> get props => [version, steps, summary, plans];
}
