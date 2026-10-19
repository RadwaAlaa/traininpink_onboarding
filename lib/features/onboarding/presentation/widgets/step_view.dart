import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/flow_step.dart';
import 'choice_step.dart';
import 'text_input_step.dart';

/// Title, subtitle and the input for one step, scrollable so the keyboard
/// never hides the focused field.
class StepView extends StatelessWidget {
  const StepView({
    super.key,
    required this.step,
    required this.answer,
    required this.onOptionTap,
    required this.onTextChanged,
    required this.onSubmitted,
  });

  final FlowStep step;
  final Answer? answer;
  final ValueChanged<String> onOptionTap;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final textTheme = Theme.of(context).textTheme;
    final subtitle = step.subtitle;

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(step.title.resolve(language), style: textTheme.headlineSmall),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(subtitle.resolve(language), style: textTheme.bodyLarge),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (step.isChoice)
            ChoiceStep(step: step, answer: answer, onTap: onOptionTap)
          else
            TextInputStep(
              step: step,
              answer: answer,
              onChanged: onTextChanged,
              onSubmitted: onSubmitted,
            ),
        ],
      ),
    );
  }
}
