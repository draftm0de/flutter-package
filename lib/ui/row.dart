import 'package:flutter/cupertino.dart';
import 'package:draftmode/platform.dart';

class DraftModeUIRow extends StatelessWidget {
  final Widget child;
  final String? label;
  final AlignmentGeometry alignment;
  final bool verticalDoubled;
  const DraftModeUIRow({
    super.key,
    required this.child,
    this.label,
    this.alignment = AlignmentGeometry.centerLeft,
    this.verticalDoubled = false
  });

  @override
  Widget build(BuildContext context) {
    final hasLabel = (label != null && label!.trim().isNotEmpty);

    final content = Align(
      alignment: alignment,
      child: child,
    );

    final paddingVertical = (verticalDoubled) ? PlatformConfig.verticalContainerPadding * 2 : PlatformConfig.verticalContainerPadding;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: PlatformConfig.horizontalContainerPadding,
        vertical: paddingVertical
      ),
      child: hasLabel ?
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: PlatformConfig.labelWidth,
              child: Text(
                label!,
                style: PlatformConfig.labelStyle(context)
              ),
            ),
            Expanded(
              child: content,
              /*child: SizedBox(
                child: child,
              )*/
            ),
          ]
        ) : content,
    );
  }
}
