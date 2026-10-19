import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_motion.dart';

/// Progress through the resolved path. Animates when she moves or when a
/// branch makes the path longer or shorter. Fills from the start edge, so it
/// runs right-to-left in Arabic.
class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key, required this.current, required this.total});

  /// 1-based position of the current step.
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: current / total),
      duration: AppMotion.transition,
      curve: AppMotion.curve,
      builder: (context, value, _) => LinearProgressIndicator(
        value: value,
        semanticsLabel: AppLocalizations.of(context)
            .stepProgress(current, total),
      ),
    );
  }
}
