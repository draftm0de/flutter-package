import 'package:flutter/cupertino.dart';
import '../platform/styles.dart';

/// Displays a form row with an optional leading label and adaptive padding.
///
/// When [label] is provided the row renders a fixed-width leading column using
/// [PlatformStyles.labelWidth] before expanding [child]. Padding follows the
/// shared spacing constants in [DraftModeStylePadding] so rows visually align
/// with native grouped lists.
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
        ? DraftModeStylePadding.tertiary * 2
        : DraftModeStylePadding.tertiary;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DraftModeStylePadding.primary,
        vertical: paddingVertical,
      ),
      child: hasLabel
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: PlatformStyles.labelWidth,
                  child: Text(label!, style: DraftModeStyleText.primary),
                ),
                Expanded(child: content),
              ],
            )
          : content,
    );
  }
}
