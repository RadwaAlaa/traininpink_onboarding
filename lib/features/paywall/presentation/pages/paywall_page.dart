import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../cubit/paywall_cubit.dart';
import '../cubit/paywall_state.dart';
import '../widgets/plan_card.dart';

/// Plan choice. Subscribing records her choice (nothing is charged) and
/// replaces the whole stack with the done screen.
class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PaywallCubit>();
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<PaywallCubit, PaywallState>(
      listenWhen: (previous, current) =>
          previous.subscribedPlanId == null && current.subscribedPlanId != null,
      listener: (context, _) => Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.done,
        (_) => false,
      ),
      builder: (context, state) {
        final trialDays = state.selectedPlan?.trialDays ?? 0;
        return PopScope(
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) cubit.setOnPaywall(false);
          },
          child: Scaffold(
            appBar: AppBar(actions: const [LanguageToggle()]),
            body: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: Breakpoints.maxContentWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: context.pagePadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsetsDirectional.symmetric(
                              vertical: AppSpacing.lg,
                            ),
                            children: [
                              Text(
                                l10n.paywallTitle,
                                style: textTheme.headlineSmall,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                trialDays > 0
                                    ? l10n.trialHeadline(trialDays)
                                    : l10n.noTrialHeadline,
                                style: textTheme.bodyLarge,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              for (final plan in state.plans) ...[
                                PlanCard(
                                  plan: plan,
                                  selected: plan.id == state.selectedPlanId,
                                  onTap: () => cubit.select(plan.id),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          l10n.demoNote,
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall,
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: FilledButton(
                            onPressed: state.subscribing
                                ? null
                                : cubit.subscribe,
                            child: Text(
                              trialDays > 0
                                  ? l10n.startTrial(trialDays)
                                  : l10n.subscribe,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
