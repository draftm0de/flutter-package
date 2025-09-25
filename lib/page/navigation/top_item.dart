import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'item.dart';
import '../../platform/config.dart';

class DraftModePageNavigationTopItem extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final bool iconExpanded;
  final Color? iconColor;
  final Future<void> Function()? onTap;
  final Widget? loadWidget;

  const DraftModePageNavigationTopItem({
    super.key,
    this.text,
    this.icon,
    this.iconExpanded = false,
    this.iconColor,
    this.onTap,
    this.loadWidget
  });

  @override
  Widget build(BuildContext context) {
    return DraftModePageNavigationItem(
      text: text,
      icon: icon,
      iconSize: PlatformConfig.topNavigationBarIconHeight,
      iconExpanded: iconExpanded,
      iconColor: iconColor,
      onTap: onTap,
      loadWidget: loadWidget,
    );
  }
}
