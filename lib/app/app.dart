import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/l10n/generated/app_localizations.dart';
import '../core/locale/locale_cubit.dart';
import '../core/theme/app_theme.dart';
import 'di/app_dependencies.dart';
import 'router/app_router.dart';
import 'router/route_names.dart';

class App extends StatelessWidget {
  const App({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    // Rebuild the stack she left: splash, then the questions if she started,
    // the summary and paywall if she reached them. Back walks the same way.
    // Once she has subscribed, only the done screen remains.
    final onboarding = dependencies.onboardingCubit.state;
    final paywall = dependencies.paywallCubit.state;
    final initialRoutes = paywall.subscribedPlanId != null
        ? [RouteNames.done]
        : [
            RouteNames.splash,
            if (onboarding.hasStarted) RouteNames.onboarding,
            if (onboarding.reachedSummary) RouteNames.summary,
            if (paywall.onPaywall) RouteNames.paywall,
          ];

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => dependencies.createLocaleCubit()),
        // Above the navigator, so the summary and paywall can read her answers.
        BlocProvider.value(value: dependencies.onboardingCubit),
        BlocProvider.value(value: dependencies.paywallCubit),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) => MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          theme: AppTheme.light(),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          onGenerateInitialRoutes: (_) => [
            for (final name in initialRoutes)
              AppRouter.onGenerateRoute(RouteSettings(name: name)),
          ],
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
