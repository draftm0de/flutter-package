import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../platform/config.dart';
import '../../platform/styles.dart';

/// Platform-aware top navigation bar used by [DraftModePage].
class DraftModePageNavigationTop extends StatelessWidget
    implements PreferredSizeWidget, ObstructingPreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? trailing;
  final bool centerTitle;
  final Color? backgroundColor;
  final double? containerHeight;

  const DraftModePageNavigationTop({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.centerTitle = true,
    this.backgroundColor,
    this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    final double useContainerHeight =
        containerHeight ?? DraftModeStyleNavigationBar.top.containerHeight;
    final bool hasTitle = title != null && title!.isNotEmpty;
    if (PlatformConfig.isIOS) {
      return Container(
        constraints: BoxConstraints(minHeight: useContainerHeight),
        child: CupertinoNavigationBar(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: DraftModeStylePadding.tertiary,
          ),
          middle: hasTitle ? Text(title!) : null,
          leading: leading,
          trailing: trailing != null && trailing!.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: trailing!.map((widget) => widget).toList(),
                )
              : null,
          backgroundColor: backgroundColor,
        ),
      );
    } else {
      return AppBar(
        title: hasTitle ? Text(title!) : null,
        leading: leading,
        actions: trailing,
        centerTitle: centerTitle,
        backgroundColor:
            backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      );
    }
  }

  @override
  bool shouldFullyObstruct(BuildContext context) => true;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
