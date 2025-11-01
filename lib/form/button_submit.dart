import 'package:flutter/cupertino.dart';

import 'button.dart';
import 'button_text.dart';

/// Primary submit button that stretches to the container width and applies the
/// Draftmode submit styling. The button validates the provided [formKey] before
/// invoking [onPressed], mirroring [DraftModeFormButton] behaviour while
/// exposing a simpler API for the common submit case.
class DraftModeFormButtonSubmit extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Future<void> Function() onPressed;
  final String label;

  const DraftModeFormButtonSubmit({
    super.key,
    required this.formKey,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DraftModeFormButtonText(
      formKey: formKey,
      text: label,
      onPressed: onPressed,
      styleSize: DraftModeFormButtonSize.large,
      styleColor: DraftModeFormButtonColor.submit,
      stretched: true,
    );
  }
}
