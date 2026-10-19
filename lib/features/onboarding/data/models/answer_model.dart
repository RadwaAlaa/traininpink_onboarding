import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/answer.dart';

part 'answer_model.g.dart';

/// A saved answer. Exactly one field is set, matching the answer type.
@JsonSerializable(includeIfNull: false)
class AnswerModel {
  const AnswerModel({this.optionId, this.optionIds, this.text});

  factory AnswerModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerModelFromJson(json);

  factory AnswerModel.fromEntity(Answer answer) => switch (answer) {
    SingleChoiceAnswer(:final optionId) => AnswerModel(optionId: optionId),
    MultiChoiceAnswer(:final optionIds) => AnswerModel(
      optionIds: optionIds.toList(),
    ),
    TextAnswer(:final value) => AnswerModel(text: value),
  };

  final String? optionId;
  final List<String>? optionIds;
  final String? text;

  Map<String, dynamic> toJson() => _$AnswerModelToJson(this);

  Answer toEntity() => switch ((optionId, optionIds, text)) {
    (final optionId?, null, null) => SingleChoiceAnswer(optionId),
    (null, final optionIds?, null) => MultiChoiceAnswer(optionIds),
    (null, null, final text?) => TextAnswer(text),
    _ => throw const FormatException('Saved answer needs exactly one value.'),
  };
}
