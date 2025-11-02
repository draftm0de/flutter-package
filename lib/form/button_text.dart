import 'package:flutter/cupertino.dart';

import '../platform/styles.dart';
import 'button.dart';

/// Convenience wrapper around [DraftModeFormButton] that renders a styled text
/// label using the shared `DraftModeStyleButton*` tokens. Opt into alternate
/// palettes or sizing by supplying the relevant role objects.
class DraftModeFormButtonText extends StatelessWidget {
  final String text;
  final Widget? loadWidget;
  final Future<void> Function()? onPressed;
  final GlobalKey<FormState>? formKey;
  final DraftModeStyleButtonSizeRole? styleSize;
  final DraftModeStyleButtonColorRole? styleColor;
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
    final Color textColor = (styleColor != null)
        ? styleColor!.font
        : DraftModeStyleButtonColor.submit.font;

    final double fontSize = (styleSize != null)
        ? styleSize!.fontSize
        : DraftModeStyleButtonSize.large.fontSize;

    final FontWeight fontWeight = (styleSize != null)
        ? styleSize!.fontWeight
        : DraftModeStyleButtonSize.large.fontWeight;

    return TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = Text(text, style: _resolveTextStyle(context));
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
