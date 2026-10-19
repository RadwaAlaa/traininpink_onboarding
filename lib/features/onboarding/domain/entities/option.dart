import 'package:equatable/equatable.dart';

import 'localized_text.dart';

/// One choice of a single- or multi-choice step.
class Option extends Equatable {
  const Option({required this.id, required this.label});

  final String id;
  final LocalizedText label;

  @override
  List<Object?> get props => [id, label];
}
