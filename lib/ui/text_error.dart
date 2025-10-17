import 'package:flutter/cupertino.dart';
import '../platform/styles.dart';

/// Displays validation errors with consistent spacing and styling.
class DraftModeUITextError extends StatelessWidget {
  final String? text;
  final bool visible;

  const DraftModeUITextError({super.key, this.text, this.visible = false});

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty || !visible) {
      return SizedBox.shrink();
    }
    final Widget content = Text(
      text!,
      style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 14),
    );
    return Padding(
      padding: EdgeInsets.only(
        left: DraftModeStylePadding.primary,
        right: DraftModeStylePadding.primary,
        bottom: DraftModeStylePadding.tertiary,
        top: DraftModeStylePadding.tertiary,
      ),
      child: SizedBox(width: double.infinity, child: content),
    );
  }
}
