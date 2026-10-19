import 'package:equatable/equatable.dart';

import 'summary_rule.dart';

/// How the personalised plan summary is written, from config.
class SummaryConfig extends Equatable {
  const SummaryConfig({required this.headlines, required this.lines});

  /// The first matching headline is shown. The last one has no condition, so
  /// there is always a headline.
  final List<SummaryRule> headlines;

  /// Every matching line is shown, in order.
  final List<SummaryRule> lines;

  @override
  List<Object?> get props => [headlines, lines];
}
