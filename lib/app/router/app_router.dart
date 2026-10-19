import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_motion.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/paywall/presentation/pages/done_page.dart';
import '../../features/paywall/presentation/pages/paywall_page.dart';
import '../../features/summary/presentation/pages/summary_page.dart';
import 'placeholder_page.dart';
import 'route_names.dart';

abstract final class AppRouter {
  static Route<void> onGenerateRoute(RouteSettings settings) {
    return _SlideRoute(settings: settings, builder: _builderFor(settings.name));
  }

  static WidgetBuilder _builderFor(String? name) {
    return switch (name) {
      RouteNames.onboarding => (_) => const OnboardingPage(),
      RouteNames.summary => (_) => const SummaryPage(),
      RouteNames.paywall => (_) => const PaywallPage(),
      RouteNames.done => (_) => const DonePage(),
      // Splash, and any unknown route, falls back to the splash screen.
      _ => (context) => PlaceholderPage(
        title: AppLocalizations.of(context).appTitle,
        actionLabel: AppLocalizations.of(context).getStarted,
        onAction: () => Navigator.pushNamed(context, RouteNames.onboarding),
      ),
    };
  }
}

/// Slides the new page in from the end edge (right in LTR, left in RTL) and
/// nudges the old page towards the start edge. Reversed automatically on pop.
class _SlideRoute extends PageRouteBuilder<void> {
  _SlideRoute({required super.settings, required WidgetBuilder builder})
    : super(
        transitionDuration: AppMotion.transition,
        reverseTransitionDuration: AppMotion.transition,
        pageBuilder: (context, _, _) => builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final direction = Directionality.of(context) == TextDirection.rtl
              ? -1.0
              : 1.0;
          final curve = CurveTween(curve: AppMotion.curve);
          final enter = Tween(
            begin: Offset(direction, 0),
            end: Offset.zero,
          ).chain(curve);
          final exit = Tween(
            begin: Offset.zero,
            end: Offset(-direction * _exitShift, 0),
          ).chain(curve);

          return SlideTransition(
            position: secondaryAnimation.drive(exit),
            child: SlideTransition(
              position: animation.drive(enter),
              child: child,
            ),
          );
        },
      );

  /// How far the outgoing page drifts, as a fraction of its width.
  static const double _exitShift = 0.3;
}
