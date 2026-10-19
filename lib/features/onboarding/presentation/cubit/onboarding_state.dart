import 'package:equatable/equatable.dart';

import '../../domain/entities/answer.dart';
import '../../domain/entities/flow_step.dart';
import 'onboarding_status.dart';

class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = OnboardingStatus.loading,
    this.path = const [],
    this.answers = const {},
    this.currentStepId = '',
    this.movedBack = false,
  });

  final OnboardingStatus status;

  /// The resolved path for [answers]; recomputed on every answer change.
  final List<FlowStep> path;

  /// Answers to steps on [path] only — anything else has been pruned.
  final Map<String, Answer> answers;

  final String currentStepId;

  /// Whether the last move was backwards, so the transition can slide the
  /// other way.
  final bool movedBack;

  // The getters below are only read while [status] is ready, when
  // [currentStepId] is always on [path].
  int get currentIndex => path.indexWhere((s) => s.id == currentStepId);
  FlowStep get currentStep => path[currentIndex];
  Answer? get currentAnswer => answers[currentStepId];
  bool get canContinue => currentStep.isComplete(currentAnswer);
  bool get isLastStep => currentIndex == path.length - 1;

  /// Whether restored progress is worth resuming rather than starting over.
  bool get hasStarted =>
      status == OnboardingStatus.ready &&
      (answers.isNotEmpty || currentIndex > 0);

  OnboardingState copyWith({
    OnboardingStatus? status,
    List<FlowStep>? path,
    Map<String, Answer>? answers,
    String? currentStepId,
    bool? movedBack,
  }) => OnboardingState(
    status: status ?? this.status,
    path: path ?? this.path,
    answers: answers ?? this.answers,
    currentStepId: currentStepId ?? this.currentStepId,
    movedBack: movedBack ?? this.movedBack,
  );

  @override
  List<Object?> get props => [status, path, answers, currentStepId, movedBack];
}
