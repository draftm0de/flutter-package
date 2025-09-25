import 'package:flutter/cupertino.dart';
import '../platform/config.dart';

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
    Widget content = Text(
      text!,
      style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 14),
    );
    return Padding(
      padding: EdgeInsets.only(
        left: PlatformConfig.horizontalContainerPadding,
        right: PlatformConfig.horizontalContainerPadding,
        bottom: PlatformConfig.verticalContainerPadding,
      ),
      child: content,
    );
  }
}
