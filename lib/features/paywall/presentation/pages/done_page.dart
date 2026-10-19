import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../../../onboarding/presentation/cubit/onboarding_cubit.dart';
import '../cubit/paywall_cubit.dart';

/// The end of the flow: shows the plan she chose. Nothing to go back to.
class DonePage extends StatelessWidget {
  const DonePage({super.key});

  /// The check mark's size, as a multiple of the base spacing.
  static const double _iconSize = AppSpacing.xl * 2;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final plan = context.select((PaywallCubit c) => c.state.subscribedPlan);

    return Scaffold(
      appBar: AppBar(actions: const [LanguageToggle()]),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Breakpoints.maxContentWidth,
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.all(context.pagePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: _iconSize,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.doneTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  if (plan != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      plan.trialDays > 0
                          ? l10n.doneTrial(
                              plan.title.resolve(language),
                              plan.trialDays,
                            )
                          : l10n.doneSubscribed(plan.title.resolve(language)),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  OutlinedButton(
                    onPressed: () => _startOver(context),
                    child: Text(l10n.startOver),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Clears her answers and plan, then returns to the splash. Lets the demo
  /// be run again without reinstalling.
  void _startOver(BuildContext context) {
    context.read<OnboardingCubit>().reset();
    context.read<PaywallCubit>().reset();
    Navigator.pushNamedAndRemoveUntil(context, RouteNames.splash, (_) => false);
  }
}
