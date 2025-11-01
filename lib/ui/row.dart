import 'package:flutter/cupertino.dart';
import '../platform/styles.dart';

/// Displays a form row with an optional leading label and adaptive padding.
///
/// When [label] is provided the row renders a fixed-width leading column using
/// [PlatformStyles.labelWidth] before expanding [child]. Padding follows the
/// shared spacing constants in [DraftModeStylePadding] so rows visually align
/// with native grouped lists.
/// Use [alignment] to fine-tune how [child] should sit within the content area
/// and provide custom [padding], [backgroundColor], or [height] overrides to
/// blend with bespoke grouped list treatments.
class DraftModeUIRow extends StatelessWidget {
  final Widget child;
  final String? label;
  final AlignmentGeometry alignment;
  final EdgeInsets? padding;
  final double? height;
  final Color? backgroundColor;

  const DraftModeUIRow({
    super.key,
    required this.child,
    this.label,
    this.alignment = Alignment.centerLeft,
    this.padding,
    this.backgroundColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasLabel = label?.trim().isNotEmpty ?? false;
    final Widget content = Align(alignment: alignment, child: child);

    final Widget body = hasLabel
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
        : content;

    final EdgeInsets containerPadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: DraftModeStylePadding.primary,
          vertical: DraftModeStylePadding.tertiary,
        );

    if (backgroundColor != null || height != null) {
      return Container(
        height: height,
        color: backgroundColor,
        padding: containerPadding,
        child: body,
      );
    }

    return Padding(padding: containerPadding, child: body);
  }
}
