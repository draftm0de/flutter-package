import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../platform/config.dart';

/// Shared navigation button used by top and bottom bars.
class DraftModePageNavigationItem extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final bool iconExpanded;
  final Color? iconColor;
  final Future<void> Function()? onTap;
  final Widget? loadWidget;
  final double? iconSize;

  const DraftModePageNavigationItem({
    super.key,
    this.text,
    this.icon,
    this.iconSize,
    this.iconExpanded = false,
    this.iconColor,
    this.onTap,
    this.loadWidget,
  });

  Future<void> _onTap(BuildContext context) async {
    if (onTap != null) {
      await onTap!();
      return;
    }
    if (loadWidget != null) {
      await Navigator.of(context).push(
        PlatformConfig.isIOS
            ? CupertinoPageRoute(builder: (_) => loadWidget!)
            : MaterialPageRoute(builder: (_) => loadWidget!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    late final Widget child;
    if (icon != null && text?.isNotEmpty == true) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: iconExpanded
            ? [
                Expanded(child: Text(text!)),
                Icon(icon, size: iconSize, color: iconColor),
              ]
            : [Icon(icon, size: iconSize, color: iconColor), Text(text!)],
      );
    } else if (icon != null) {
      child = Padding(
        padding: EdgeInsets.zero,
        child: Icon(icon, size: iconSize, color: iconColor),
      );
    } else if (text?.isNotEmpty == true) {
      child = Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Text(text!),
      );
    } else {
      child = const SizedBox();
    }

    return PlatformConfig.isIOS
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _onTap(context),
            child: child,
          )
        : TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
            onPressed: () => _onTap(context),
            child: child,
          );
  }
}
