import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/localized_text.dart';
import '../../domain/entities/option.dart';

part 'option_model.g.dart';

@JsonSerializable(createToJson: false)
class OptionModel {
  const OptionModel({required this.id, required this.label});

  factory OptionModel.fromJson(Map<String, dynamic> json) =>
      _$OptionModelFromJson(json);

  final String id;
  final Map<String, String> label;

  Option toEntity() => Option(id: id, label: LocalizedText(label));
}
