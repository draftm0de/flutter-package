import 'package:flutter/cupertino.dart';

class DraftModeUIBoxCircle extends StatelessWidget {
  final double size;
  final Color color;
  final Color? borderColor;
  final Color backgroundColor;
  final double borderWidth;
  final Widget? child;

  const DraftModeUIBoxCircle({
    super.key,
    this.child,
    this.size = 26,
    this.color = CupertinoColors.activeBlue,
    this.borderColor,
    this.backgroundColor = CupertinoColors.white,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedBorderColor = borderColor ?? color;

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
          if (child != null) child!,
        ],
      ),
    );
  }
}
