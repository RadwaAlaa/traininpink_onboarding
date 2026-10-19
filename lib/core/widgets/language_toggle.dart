import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/generated/app_localizations.dart';
import '../locale/locale_cubit.dart';

/// Switches between English and Arabic. The label is the other language's name.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: context.read<LocaleCubit>().toggle,
      child: Text(AppLocalizations.of(context).switchLanguage),
    );
  }
}
