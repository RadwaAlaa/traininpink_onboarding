import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/progress.dart';
import 'answer_model.dart';

part 'progress_model.g.dart';

@JsonSerializable()
class ProgressModel {
  const ProgressModel({
    required this.flowVersion,
    required this.currentStepId,
    required this.answers,
    this.reachedSummary = false,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) =>
      _$ProgressModelFromJson(json);

  factory ProgressModel.fromEntity(Progress progress) => ProgressModel(
    flowVersion: progress.flowVersion,
    currentStepId: progress.currentStepId,
    answers: progress.answers.map(
      (stepId, answer) => MapEntry(stepId, AnswerModel.fromEntity(answer)),
    ),
    reachedSummary: progress.reachedSummary,
  );

  final int flowVersion;
  final String currentStepId;
  final Map<String, AnswerModel> answers;
  final bool reachedSummary;

  Map<String, dynamic> toJson() => _$ProgressModelToJson(this);

  Progress toEntity() => Progress(
    flowVersion: flowVersion,
    currentStepId: currentStepId,
    answers: answers.map(
      (stepId, answer) => MapEntry(stepId, answer.toEntity()),
    ),
    reachedSummary: reachedSummary,
  );
}
