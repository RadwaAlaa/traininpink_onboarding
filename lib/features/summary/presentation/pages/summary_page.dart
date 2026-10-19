import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../../../onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../../onboarding/presentation/cubit/onboarding_state.dart';
import '../../domain/plan_summary.dart';

/// Her plan, built only from the answers on the path she actually took.
/// Going back returns to the last question so she can change any answer.
class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  /// True while the paywall is being pushed, so a double tap pushes it once.
  bool _opening = false;

  Future<void> _seePlans() async {
    if (_opening) return;
    _opening = true;
    await Navigator.pushNamed(context, RouteNames.paywall);
    _opening = false;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) cubit.setReachedSummary(false);
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
                      child: BlocBuilder<OnboardingCubit, OnboardingState>(
                        builder: (context, state) {
                          final summary = PlanSummary.fromAnswers(
                            cubit.config.summary,
                            state.answers,
                            Localizations.localeOf(context).languageCode,
                          );
                          return ListView(
                            padding: const EdgeInsetsDirectional.symmetric(
                              vertical: AppSpacing.lg,
                            ),
                            children: [
                              Text(
                                l10n.summaryTitle,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                summary.headline,
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              for (final line in summary.lines)
                                _SummaryLine(text: line),
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: FilledButton(
                        onPressed: _seePlans,
                        child: Text(l10n.seePlans),
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
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
