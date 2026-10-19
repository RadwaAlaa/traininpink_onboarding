import 'package:traininpink_onboarding/features/onboarding/domain/entities/condition.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/flow_config.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/flow_step.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/localized_text.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/option.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/summary_config.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/summary_rule.dart';

/// Same text in both languages — content is irrelevant to branching tests.
LocalizedText t(String text) => LocalizedText({'en': text, 'ar': text});

List<Option> options(List<String> ids) => [
  for (final id in ids) Option(id: id, label: t(id)),
];

FlowStep single(String id, List<String> optionIds, {Condition? showIf}) =>
    FlowStep(
      id: id,
      type: StepType.singleChoice,
      title: t(id),
      options: options(optionIds),
      showIf: showIf,
    );

/// A small flow that exercises every condition type:
/// goal → [last_trained → [restart_pace]] → focus_areas → [core_pain]
///      → [heavy_lifting] → name → email
final sampleFlow = FlowConfig(
  version: 1,
  steps: [
    single('goal', ['get_back_into_it', 'build_strength', 'lose_weight']),
    single('last_trained', [
      'under_3_months',
      'over_a_year',
    ], showIf: const EqCondition('goal', 'get_back_into_it')),
    single('restart_pace', [
      'gentle',
      'steady',
    ], showIf: const EqCondition('last_trained', 'over_a_year')),
    FlowStep(
      id: 'focus_areas',
      type: StepType.multiChoice,
      title: t('focus_areas'),
      options: options(['core', 'legs', 'arms']),
      minSelected: 1,
    ),
    single('core_pain', [
      'yes',
      'no',
    ], showIf: const ContainsCondition('focus_areas', 'core')),
    single(
      'heavy_lifting',
      ['yes', 'no'],
      showIf: const AllCondition([
        AnyCondition([
          EqCondition('goal', 'build_strength'),
          InCondition('goal', ['lose_weight']),
        ]),
        NotCondition(ContainsCondition('focus_areas', 'arms')),
      ]),
    ),
    FlowStep(id: 'name', type: StepType.text, title: t('name'), maxLength: 40),
    FlowStep(id: 'email', type: StepType.email, title: t('email')),
  ],
  summary: sampleSummary,
);

/// Headline picks on goal, with an unconditional fallback; lines come from
/// a nested branch and a multi-choice, and `{name}` fills in her name.
final sampleSummary = SummaryConfig(
  headlines: [
    SummaryRule(
      text: t('{name}: comeback'),
      showIf: const EqCondition('goal', 'get_back_into_it'),
    ),
    SummaryRule(text: t('{name}: your plan')),
  ],
  lines: [
    SummaryRule(
      text: t('gentle start'),
      showIf: const EqCondition('restart_pace', 'gentle'),
    ),
    SummaryRule(
      text: t('core finisher'),
      showIf: const ContainsCondition('focus_areas', 'core'),
    ),
  ],
);
