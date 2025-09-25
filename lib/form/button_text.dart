import 'package:draftmode/form.dart';
import 'package:flutter/cupertino.dart';

class DraftModeFormButtonText extends StatelessWidget {
  final String text;
  final StatefulWidget? loadWidget;
  final Future<void> Function()? onPressed;
  final GlobalKey<FormState>? formKey;
  final DraftModeFromButtonSize? styleSize;
  final DraftModeFromButtonColor? styleColor;
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

  @override
  Widget build(BuildContext context) {
    Color? color;
    switch (styleColor ?? 'none') {
      case DraftModeFromButtonColor.dateTime:
        color = CupertinoColors.systemGrey5;

      case DraftModeFromButtonColor.submit:
        color = CupertinoColors.white;
    }
    double? fontSize;
    switch (styleSize ?? 'none') {
      case DraftModeFromButtonSize.large:
        fontSize = 16;

      case DraftModeFromButtonSize.medium:
        fontSize = 14;
    }

    final Widget content = Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
      ),
    );

    return DraftModeFormButton(
      content: content,
      loadWidget: loadWidget,
      onPressed: onPressed,
      extendIcon: (loadWidget != null),
      formKey: formKey,
      styleSize: styleSize,
      styleColor: styleColor,
      stretched: stretched,
    );
  }
}
