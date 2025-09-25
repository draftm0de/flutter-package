import 'package:flutter/cupertino.dart';
import '../platform/config.dart';

/// Displays validation errors with consistent spacing and styling.
class DraftModeUITextError extends StatelessWidget {
  final String? text;
  final bool visible;
  final double spacing;

  const DraftModeUITextError({
    super.key,
    this.text,
    this.visible = false,
    this.spacing = 4,
  });

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
        left: PlatformConfig.horizontalContainerPadding,
        right: PlatformConfig.horizontalContainerPadding,
        bottom: PlatformConfig.verticalContainerPadding,
        top: spacing,
      ),
      child: content,
    );
  }
}
