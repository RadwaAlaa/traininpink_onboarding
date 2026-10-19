import 'package:equatable/equatable.dart';

import '../../onboarding/domain/entities/answer.dart';
import '../../onboarding/domain/entities/summary_config.dart';
import '../../onboarding/domain/entities/summary_rule.dart';

/// Her personalised plan, written in one language.
class PlanSummary extends Equatable {
  const PlanSummary({required this.headline, required this.lines});

  /// Builds the summary from [answers], which must be the pruned answers on
  /// her path: a branch she didn't take can't add a line or pick a headline.
  factory PlanSummary.fromAnswers(
    SummaryConfig summary,
    Map<String, Answer> answers,
    String languageCode,
  ) {
    bool matches(SummaryRule rule) => rule.showIf?.evaluate(answers) ?? true;

    String write(SummaryRule rule) => rule.text
        .resolve(languageCode)
        .replaceAllMapped(
          SummaryRule.placeholder,
          (match) => switch (answers[match.group(1)]) {
            TextAnswer(:final value) => value,
            _ => '',
          },
        );

    return PlanSummary(
      // The validator guarantees the last headline always matches.
      headline: write(summary.headlines.firstWhere(matches)),
      lines: [
        for (final rule in summary.lines)
          if (matches(rule)) write(rule),
      ],
    );
  }

  final String headline;
  final List<String> lines;

  @override
  List<Object?> get props => [headline, lines];
}
