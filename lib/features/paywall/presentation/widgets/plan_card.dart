import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../onboarding/domain/entities/plan.dart';

/// One selectable plan: title, optional badge, price, period and trial.
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final Plan plan;
  final bool selected;
  final VoidCallback onTap;

  /// The selected plan gets a thicker outline than the default hairline.
  static const double _selectedBorder = 2;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final badge = plan.badge;

    return MergeSemantics(
      // Announced as a radio button in the group of plans.
      child: Semantics(
        checked: selected,
        inMutuallyExclusiveGroup: true,
        child: Material(
          color: selected ? colors.primaryContainer : colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            side: BorderSide(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? _selectedBorder : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              plan.title.resolve(language),
                              style: theme.textTheme.titleMedium,
                            ),
                            if (badge != null) _Badge(badge.resolve(language)),
                          ],
                        ),
                        Text(plan.period.resolve(language)),
                        if (plan.trialDays > 0)
                          Text(
                            AppLocalizations.of(context)
                                .planTrial(plan.trialDays),
                            style: TextStyle(color: colors.primary),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    plan.priceLabel.resolve(language),
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: colors.onPrimary),
        ),
      ),
    );
  }
}
