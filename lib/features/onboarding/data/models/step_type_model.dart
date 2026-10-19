import 'package:json_annotation/json_annotation.dart';

/// Step `type` as written in the config; `unknown` catches typos.
@JsonEnum(fieldRename: FieldRename.snake)
enum StepTypeModel { singleChoice, multiChoice, text, email, unknown }
