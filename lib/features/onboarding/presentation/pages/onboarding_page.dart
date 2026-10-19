import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../../domain/entities/flow_step.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../cubit/onboarding_status.dart';
import '../widgets/progress_header.dart';
import '../widgets/step_transition.dart';
import '../widgets/step_view.dart';

/// Every question lives on this one route; the cubit, not the navigator,
/// decides which step is showing. Back (app bar or system) walks the path.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  /// True while a step transition or the push to the summary is running.
  /// Taps are ignored meanwhile, so a double tap can't skip a step.
  bool _busy = false;
  Timer? _unlock;

  @override
  void dispose() {
    _unlock?.cancel();
    super.dispose();
  }

  void _lockDuringTransition() {
    setState(() => _busy = true);
    _unlock?.cancel();
    _unlock = Timer(AppMotion.transition, () {
      if (mounted) setState(() => _busy = false);
    });
  }

  Future<void> _continue() async {
    final cubit = context.read<OnboardingCubit>();
    if (_busy || !cubit.state.canContinue) return;

    FocusScope.of(context).unfocus();
    if (!cubit.state.isLastStep) return cubit.next();

    setState(() => _busy = true);
    cubit.setReachedSummary(true);
    await Navigator.pushNamed(context, RouteNames.summary);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();

    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) =>
          previous.status == OnboardingStatus.ready &&
          previous.currentStepId != current.currentStepId,
      listener: (_, _) => _lockDuringTransition(),
      builder: (context, state) => PopScope(
        canPop:
            state.status != OnboardingStatus.ready || state.currentIndex == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) cubit.back();
        },
        child: Scaffold(
          appBar: AppBar(actions: const [LanguageToggle()]),
          body: SafeArea(
            child: switch (state.status) {
              OnboardingStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              OnboardingStatus.failure => Center(
                child: Padding(
                  padding: EdgeInsetsDirectional.all(context.pagePadding),
                  child: Text(
                    AppLocalizations.of(context).loadError,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              OnboardingStatus.ready => IgnorePointer(
                ignoring: _busy,
                child: _ReadyBody(state: state, onContinue: _continue),
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _ReadyBody extends StatelessWidget {
  const _ReadyBody({required this.state, required this.onContinue});

  final OnboardingState state;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    final l10n = AppLocalizations.of(context);
    final step = state.currentStep;
    final skippable = !step.required && state.currentAnswer == null;

    return Column(
      children: [
        ProgressHeader(
          current: state.currentIndex + 1,
          total: state.path.length,
        ),
        Expanded(
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
                      child: StepTransition(
                        stepKey: ValueKey(step.id),
                        movedBack: state.movedBack,
                        child: StepView(
                          step: step,
                          answer: state.currentAnswer,
                          onOptionTap: step.type == StepType.multiChoice
                              ? cubit.toggleOption
                              : cubit.selectOption,
                          onTextChanged: cubit.enterText,
                          onSubmitted: onContinue,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: FilledButton(
                        onPressed: state.canContinue ? onContinue : null,
                        child: Text(skippable ? l10n.skip : l10n.continueLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
