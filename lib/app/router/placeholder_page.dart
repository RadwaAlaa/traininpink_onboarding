import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/language_toggle.dart';

/// Temporary screen used by the router until each feature page is built.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;

    return Scaffold(
      appBar: AppBar(actions: const [LanguageToggle()]),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Breakpoints.maxContentWidth,
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.all(context.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  if (label != null)
                    FilledButton(onPressed: onAction, child: Text(label)),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
