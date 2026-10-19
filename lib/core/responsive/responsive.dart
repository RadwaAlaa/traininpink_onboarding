import 'package:flutter/widgets.dart';

import '../theme/app_spacing.dart';

abstract final class Breakpoints {
  /// shortestSide at or above this is a tablet, in either orientation.
  static const double tablet = 600;

  /// Questions and single-column content never grow wider than this.
  static const double maxContentWidth = 560;
}

extension ResponsiveContext on BuildContext {
  bool get isTablet =>
      MediaQuery.sizeOf(this).shortestSide >= Breakpoints.tablet;

  /// Side gutter for page content.
  double get pagePadding => isTablet ? AppSpacing.xl : AppSpacing.md;
}
