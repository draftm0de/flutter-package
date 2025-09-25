import 'package:flutter/cupertino.dart';
import '../../platform/config.dart';

class DraftModePageNavigationBottom extends StatelessWidget {
  final List<Widget>? leading;
  final Widget? primary;
  final List<Widget>? trailing;
  final bool centerTitle;
  final Color? backgroundColor;

  const DraftModePageNavigationBottom({
    super.key,
    this.leading,
    this.primary,
    this.trailing,
    this.centerTitle = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          minHeight: PlatformConfig.bottomNavigationBarContainerHeight,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: PlatformConfig.verticalContainerPadding,
        ),
        child: SizedBox(
          height: PlatformConfig.bottomNavigationBarItemHeight,
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
