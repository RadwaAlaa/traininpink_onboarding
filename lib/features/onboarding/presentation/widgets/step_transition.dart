import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';

/// Slides and fades between steps. Forward moves enter from the end edge and
/// back moves from the start edge, so the direction flips in Arabic.
class StepTransition extends StatelessWidget {
  const StepTransition({
    super.key,
    required this.stepKey,
    required this.movedBack,
    required this.child,
  });

  /// Changes whenever the step changes; this is what triggers the transition.
  final Key stepKey;
  final bool movedBack;
  final Widget child;

  /// How far a step slides, as a fraction of its width.
  static const double _shift = 0.15;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // +1 means the new step enters from the right: forward in LTR, or back
    // in RTL. Otherwise it enters from the left.
    final fromRight = (movedBack ? -1.0 : 1.0) * (rtl ? -1.0 : 1.0);

    return AnimatedSwitcher(
      duration: AppMotion.transition,
      switchInCurve: AppMotion.curve,
      switchOutCurve: AppMotion.curve,
      layoutBuilder: (current, previous) =>
          Stack(fit: StackFit.expand, children: [...previous, ?current]),
      transitionBuilder: (child, animation) {
        // The outgoing step runs this animation in reverse, so it leaves
        // towards the opposite edge from the one the new step enters from.
        final incoming = child.key == stepKey;
        final begin = Offset((incoming ? 1 : -1) * fromRight * _shift, 0);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: begin, end: Offset.zero).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: stepKey, child: child),
    );
  }
}
