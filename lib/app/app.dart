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
    // then the summary if she reached it. Back still walks the same way.
    final saved = dependencies.onboardingCubit.state;
    final initialRoutes = [
      RouteNames.splash,
      if (saved.hasStarted) RouteNames.onboarding,
      if (saved.reachedSummary) RouteNames.summary,
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => dependencies.createLocaleCubit()),
        // Above the navigator, so the summary and paywall can read her answers.
        BlocProvider.value(value: dependencies.onboardingCubit),
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
