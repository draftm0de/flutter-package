import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'item.dart';
import '../../platform/styles.dart';

/// Convenience wrapper configuring a [DraftModePageNavigationItem] for the bottom bar.
class DraftModePageNavigationBottomItem extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final double? iconHeight;
  final Color? iconColor;
  final bool iconExpanded;
  final Future<void> Function()? onTap;
  final Widget? loadWidget;

  const DraftModePageNavigationBottomItem({
    super.key,
    this.text,
    this.icon,
    this.iconColor,
    this.iconHeight,
    this.iconExpanded = false,
    this.onTap,
    this.loadWidget,
  });

  @override
  Widget build(BuildContext context) {
    final double useIconHeight =
        iconHeight ?? DraftModeStyleNavigationBar.bottom.iconHeight;
    return DraftModePageNavigationItem(
      text: text,
      icon: icon,
      iconSize: useIconHeight,
      iconExpanded: iconExpanded,
      iconColor: iconColor,
      onTap: onTap,
      loadWidget: loadWidget,
    );
  }
}
