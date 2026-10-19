import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// One tappable answer. Radio-style for single choice, checkbox-style for
/// multi choice. [onTap] null renders it disabled (multi choice at its max).
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.multi,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool multi;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final icon = switch ((multi, selected)) {
      (true, true) => Icons.check_box,
      (true, false) => Icons.check_box_outline_blank,
      (false, true) => Icons.radio_button_checked,
      (false, false) => Icons.radio_button_unchecked,
    };

    return MergeSemantics(
      // Announced as a checkbox (multi) or radio button (single).
      child: Semantics(
        checked: selected,
        inMutuallyExclusiveGroup: !multi,
        child: Material(
          color: selected ? colors.primaryContainer : colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            side: BorderSide(
              color: selected ? colors.primary : colors.outlineVariant,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.ctaHeight,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: onTap == null ? colors.outline : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ExcludeSemantics(
                      child: Icon(
                        icon,
                        color: selected ? colors.primary : colors.outline,
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
