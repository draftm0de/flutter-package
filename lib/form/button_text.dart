import 'package:draftmode/form.dart';
import 'package:flutter/cupertino.dart';

import '../platform/styles.dart';

/// Convenience wrapper around [DraftModeFormButton] that renders a styled text
/// label matching the platform typography conventions defined in
/// [PlatformStyles].
class DraftModeFormButtonText extends StatelessWidget {
  final String text;
  final Widget? loadWidget;
  final Future<void> Function()? onPressed;
  final GlobalKey<FormState>? formKey;
  final DraftModeFormButtonSize? styleSize;
  final DraftModeFormButtonColor? styleColor;
  final bool stretched;

  const DraftModeFormButtonText({
    super.key,
    required this.text,
    this.loadWidget,
    this.onPressed,
    this.formKey,
    this.styleSize,
    this.styleColor,
    this.stretched = false,
  });

  TextStyle _resolveTextStyle(BuildContext context) {
    final base = PlatformStyles.buttonTextStyle(context);
    final resolvedColor = () {
      switch (styleColor ?? DraftModeFormButtonColor.submit) {
        case DraftModeFormButtonColor.dateTime:
          return CupertinoColors.black;
        case DraftModeFormButtonColor.submit:
          return CupertinoColors.white;
      }
    }();

    final resolvedSize = () {
      switch (styleSize ?? DraftModeFormButtonSize.medium) {
        case DraftModeFormButtonSize.large:
          return 16.0;
        case DraftModeFormButtonSize.medium:
          return 14.0;
      }
    }();

    return base.copyWith(color: resolvedColor, fontSize: resolvedSize);
  }

  @override
  Widget build(BuildContext context) {
    final content = Text(text, style: _resolveTextStyle(context));
    return DraftModeFormButton(
      content: content,
      loadWidget: loadWidget,
      onPressed: onPressed,
      formKey: formKey,
      styleSize: styleSize,
      styleColor: styleColor,
      stretched: stretched,
    );
  }
}
