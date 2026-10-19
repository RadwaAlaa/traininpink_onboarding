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
    // If she has started, skip the splash and resume where she left off.
    final resume = dependencies.onboardingCubit.state.hasStarted;

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
          initialRoute: resume ? RouteNames.onboarding : RouteNames.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
