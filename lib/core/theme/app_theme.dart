import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  /// Bundled Cairo covers both Latin and Arabic, so one family serves EN + AR.
  static const String fontFamily = 'Cairo';

  /// Cairo's tall Arabic glyphs need a little extra leading to avoid clipping.
  static const double _bodyLineHeight = 1.5;

  static ThemeData light() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.seed),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: fontFamily,
    );

    return base.copyWith(
      textTheme: _withVariableWeights(base.textTheme),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.ctaHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
        ),
      ),
    );
  }

  /// Cairo is a variable font: map each style's [FontWeight] onto the `wght`
  /// axis so bold/medium weights actually render.
  static TextTheme _withVariableWeights(TextTheme theme) {
    TextStyle? apply(TextStyle? style, {double? height}) {
      final weight = style?.fontWeight ?? FontWeight.w400;
      return style?.copyWith(
        height: height,
        fontVariations: [FontVariation.weight(weight.value.toDouble())],
      );
    }

    return theme.copyWith(
      displayLarge: apply(theme.displayLarge),
      displayMedium: apply(theme.displayMedium),
      displaySmall: apply(theme.displaySmall),
      headlineLarge: apply(theme.headlineLarge),
      headlineMedium: apply(theme.headlineMedium),
      headlineSmall: apply(theme.headlineSmall),
      titleLarge: apply(theme.titleLarge),
      titleMedium: apply(theme.titleMedium),
      titleSmall: apply(theme.titleSmall),
      bodyLarge: apply(theme.bodyLarge, height: _bodyLineHeight),
      bodyMedium: apply(theme.bodyMedium, height: _bodyLineHeight),
      bodySmall: apply(theme.bodySmall, height: _bodyLineHeight),
      labelLarge: apply(theme.labelLarge),
      labelMedium: apply(theme.labelMedium),
      labelSmall: apply(theme.labelSmall),
    );
  }
}
