import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/engine/flow_engine.dart';
import '../../domain/entities/flow_config.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/progress.dart';
import '../../domain/repositories/onboarding_repository.dart';
import 'onboarding_state.dart';
import 'onboarding_status.dart';

/// Owns her answers and current step. The [FlowEngine] decides the path; this
/// cubit only applies her input to it and saves progress after every change.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._repository) : super(const OnboardingState());

  final OnboardingRepository _repository;

  /// Set by [load] before the state becomes ready; every other method runs
  /// only on a ready state.
  late FlowEngine _engine;

  /// The loaded config, for the summary (and later the paywall).
  FlowConfig get config => _engine.config;

  Future<void> load() async {
    try {
      _engine = FlowEngine(await _repository.loadFlowConfig());
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: OnboardingStatus.failure));
      return;
    }

    final saved = _repository.loadProgress();
    final restored = saved == null ? null : _engine.restore(saved);
    final answers = restored?.answers ?? const {};
    final path = _engine.resolvePath(answers);
    emit(
      OnboardingState(
        status: OnboardingStatus.ready,
        path: path,
        answers: answers,
        currentStepId: restored?.currentStepId ?? path.first.id,
        reachedSummary: restored?.reachedSummary ?? false,
      ),
    );
  }

  void selectOption(String optionId) =>
      _setAnswer(SingleChoiceAnswer(optionId));

  /// Adds or removes [optionId]. Adding past `maxSelected` is ignored.
  void toggleOption(String optionId) {
    final current = switch (state.currentAnswer) {
      MultiChoiceAnswer(:final optionIds) => optionIds,
      _ => const <String>{},
    };
    if (current.contains(optionId)) {
      final rest = {...current}..remove(optionId);
      _setAnswer(rest.isEmpty ? null : MultiChoiceAnswer(rest));
    } else if (!state.currentStep.isAtMax(state.currentAnswer)) {
      _setAnswer(MultiChoiceAnswer({...current, optionId}));
    }
  }

  /// Stores trimmed text; blank text clears the answer.
  void enterText(String text) {
    final value = text.trim();
    _setAnswer(value.isEmpty ? null : TextAnswer(value));
  }

  /// Moves to the next step on the path. Does nothing if the current answer
  /// isn't complete or this is the last step.
  void next() {
    if (!state.canContinue) return;
    final target = _engine.next(state.path, state.currentStepId);
    if (target == null) return;
    _emitAndSave(state.copyWith(currentStepId: target.id, movedBack: false));
  }

  /// Moves to the previous step; her answer there is kept.
  void back() {
    final target = _engine.previous(state.path, state.currentStepId);
    if (target == null) return;
    _emitAndSave(state.copyWith(currentStepId: target.id, movedBack: true));
  }

  /// Called when she moves on to the summary, and with false when she comes
  /// back from it to edit an answer.
  void setReachedSummary(bool reached) =>
      _emitAndSave(state.copyWith(reachedSummary: reached));

  /// Applies an answer to the current step, then re-routes: the path is
  /// re-resolved and answers that fell off it are pruned.
  void _setAnswer(Answer? answer) {
    final answers = {...state.answers}..remove(state.currentStepId);
    if (answer != null) answers[state.currentStepId] = answer;

    final path = _engine.resolvePath(answers);
    _emitAndSave(
      state.copyWith(path: path, answers: _engine.pruneAnswers(path, answers)),
    );
  }

  void _emitAndSave(OnboardingState next) {
    if (next == state) return;
    emit(next);
    unawaited(
      _repository.saveProgress(
        Progress(
          flowVersion: _engine.config.version,
          currentStepId: next.currentStepId,
          answers: next.answers,
          reachedSummary: next.reachedSummary,
        ),
      ),
    );
  }
}
