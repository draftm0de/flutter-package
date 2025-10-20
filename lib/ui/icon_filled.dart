import 'package:flutter/cupertino.dart';

class DraftModeUIIconFilled extends StatelessWidget {
  final double size;
  final Color color;
  final Color? borderColor;
  final Color? iconColor;
  final Color backgroundColor;
  final double borderWidth;
  final IconData? innerIcon;
  final double? innerIconSize;

  const DraftModeUIIconFilled({
    super.key,
    this.size = 26,
    this.color = CupertinoColors.activeBlue,
    this.borderColor,
    this.iconColor,
    this.backgroundColor = CupertinoColors.white,
    this.borderWidth = 1.5,
    this.innerIcon,
    this.innerIconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final double innerSize = innerIconSize ?? size * 0.8;

    final Color resolvedBorderColor = borderColor ?? color;
    final Color resolvedIconColor = iconColor ?? color;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // White background + border
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: resolvedBorderColor,
                width: borderWidth,
              ),
            ),
          ),
          if (innerIcon != null)
            Icon(innerIcon, size: innerSize, color: resolvedIconColor),
        ],
      ),
    );
  }
}
