import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'item.dart';
import '../../platform/config.dart';

class DraftModePageNavigationBottomItem extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color? iconColor;
  final bool iconExpanded;
  final Future<void> Function()? onTap;
  final Widget? loadWidget;

  const DraftModePageNavigationBottomItem({
    super.key,
    this.text,
    this.icon,
    this.iconColor,
    this.iconExpanded = false,
    this.onTap,
    this.loadWidget
  });

  @override
  Widget build(BuildContext context) {
    return DraftModePageNavigationItem(
      text: text,
      icon: icon,
      iconSize: PlatformConfig.bottomNavigationBarIconHeight,
      iconExpanded: iconExpanded,
      iconColor: iconColor,
      onTap: onTap,
      loadWidget: loadWidget,
    );
  }
}
