import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/flow_step.dart';

/// Free-text or email field. An invalid email shows its error only after
/// she leaves the field or submits, never while she is still typing it.
class TextInputStep extends StatefulWidget {
  const TextInputStep({
    super.key,
    required this.step,
    required this.answer,
    required this.onChanged,
    required this.onSubmitted,
  });

  final FlowStep step;
  final Answer? answer;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  State<TextInputStep> createState() => _TextInputStepState();
}

class _TextInputStepState extends State<TextInputStep> {
  late final TextEditingController _controller = TextEditingController(
    text: switch (widget.answer) {
      TextAnswer(:final value) => value,
      _ => '',
    },
  );
  final FocusNode _focusNode = FocusNode();
  bool _showError = false;

  bool get _isEmail => widget.step.type == StepType.email;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _controller.text.trim().isNotEmpty) {
        setState(() => _showError = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final invalid = _isEmail && !FlowStep.isValidEmail(_controller.text);

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: true,
      maxLength: widget.step.maxLength,
      keyboardType: _isEmail ? TextInputType.emailAddress : TextInputType.text,
      textCapitalization: _isEmail
          ? TextCapitalization.none
          : TextCapitalization.sentences,
      autocorrect: !_isEmail,
      autofillHints: _isEmail ? const [AutofillHints.email] : null,
      // Email addresses are always left-to-right, even in Arabic.
      textDirection: _isEmail ? TextDirection.ltr : null,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: _isEmail ? l10n.emailHint : l10n.textHint,
        hintTextDirection: _isEmail ? TextDirection.ltr : null,
        // A blank helper reserves the error's height, so nothing jumps.
        helperText: ' ',
        errorText: _showError && invalid ? l10n.emailError : null,
      ),
      onChanged: (text) {
        setState(() {});
        widget.onChanged(text);
      },
      onSubmitted: (_) {
        setState(() => _showError = true);
        widget.onSubmitted();
      },
      onTapOutside: (_) => _focusNode.unfocus(),
    );
  }
}
