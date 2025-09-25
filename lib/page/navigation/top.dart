import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../platform/config.dart';

class DraftModePageNavigationTop extends StatelessWidget
    implements PreferredSizeWidget, ObstructingPreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? trailing;
  final bool centerTitle;
  final Color? backgroundColor;

  const DraftModePageNavigationTop({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.centerTitle = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasTitle = title != null && title!.isNotEmpty;
    if (PlatformConfig.isIOS) {
      return CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.zero,
        middle: hasTitle ? Text(title!) : null,
        leading: leading,
        trailing: trailing != null && trailing!.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(right: PlatformConfig.verticalContainerPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: trailing!
                      .map(
                        (widget) => widget,
                      )
                      .toList(),
                )
              )
            : null,
        backgroundColor: backgroundColor,
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
