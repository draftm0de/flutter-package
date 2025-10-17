import 'package:flutter/cupertino.dart';
import '../../platform/styles.dart';

/// Platform-aware bottom navigation bar used by [DraftModePage].
class DraftModePageNavigationBottom extends StatelessWidget {
  final List<Widget>? leading;
  final Widget? primary;
  final List<Widget>? trailing;
  final bool centerTitle;
  final Color? backgroundColor;
  final double? containerHeight;

  const DraftModePageNavigationBottom({
    super.key,
    this.leading,
    this.primary,
    this.trailing,
    this.centerTitle = true,
    this.backgroundColor,
    this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    final double useContainerHeight =
        containerHeight ?? DraftModeStyleNavigationBar.top.containerHeight;
    final content = SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(minHeight: useContainerHeight),
        padding: EdgeInsets.symmetric(
          horizontal: DraftModeStylePadding.secondary,
        ),
        child: SizedBox(
          height: useContainerHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _spaced(leading!),
                    ),
                  ),
                ),
              if (primary != null)
                Expanded(
                  child: Align(alignment: Alignment.center, child: primary),
                ),
              if (trailing != null)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _spaced(trailing!),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        //color: translucent ? barColor.withOpacity(0.7) : barColor,
        border: const Border(
          top: BorderSide(
            color: CupertinoColors.separator, // subtle hairline
            width: 0.0,
          ),
        ),
      ),
      child: content,
    );

    return decorated;
  }

  List<Widget> _spaced(List<Widget> items) {
    if (items.isEmpty) return items;
    return [
      for (int i = 0; i < items.length; i++) ...[
        items[i],
        if (i != items.length - 1) const SizedBox(width: 8),
      ],
    ];
  }
}
