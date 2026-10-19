import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/flow_step.dart';
import 'option_tile.dart';

/// Options of a single- or multi-choice step.
class ChoiceStep extends StatelessWidget {
  const ChoiceStep({
    super.key,
    required this.step,
    required this.answer,
    required this.onTap,
  });

  final FlowStep step;
  final Answer? answer;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final multi = step.type == StepType.multiChoice;
    final selected = switch (answer) {
      SingleChoiceAnswer(:final optionId) => {optionId},
      MultiChoiceAnswer(:final optionIds) => optionIds,
      _ => const <String>{},
    };
    final atMax = step.isAtMax(answer);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in step.options) ...[
          OptionTile(
            label: option.label.resolve(language),
            selected: selected.contains(option.id),
            multi: multi,
            onTap: atMax && !selected.contains(option.id)
                ? null
                : () => onTap(option.id),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
