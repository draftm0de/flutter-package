import 'package:flutter/cupertino.dart';
import '../platform/styles.dart';

/// Displays a form row with an optional leading label and adaptive padding.
///
/// When [label] is provided the row renders a fixed-width leading column using
/// `PlatformConfig.labelWidth` before expanding [child]. Padding respects the
/// platform-specific constants exposed by [PlatformConfig].
class DraftModeUIRow extends StatelessWidget {
  final Widget child;
  final String? label;
  final AlignmentGeometry alignment;
  final bool verticalDoubled;

  const DraftModeUIRow({
    super.key,
    required this.child,
    this.label,
    this.alignment = Alignment.centerLeft,
    this.verticalDoubled = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasLabel = (label != null && label!.trim().isNotEmpty);

    final content = Align(alignment: alignment, child: child);

    final paddingVertical = (verticalDoubled)
        ? PlatformStyles.verticalContainerPadding * 2
        : PlatformStyles.verticalContainerPadding;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: PlatformStyles.horizontalContainerPadding,
        vertical: paddingVertical,
      ),
      child: hasLabel
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: PlatformStyles.labelWidth,
                  child: Text(
                    label!,
                    style: PlatformStyles.labelStyle(context),
                  ),
                ),
                Expanded(child: content),
              ],
            )
          : content,
    );
  }
}
