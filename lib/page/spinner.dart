import 'package:flutter/cupertino.dart';
import '../platform/config.dart';

/// Lightweight activity indicator used while loading page content.
class DraftModePageSpinner extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const DraftModePageSpinner({
    super.key,
    this.size = 20,
    this.color,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? const Color(0xFF888888);
    if (PlatformConfig.isIOS) {
      return Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CupertinoActivityIndicator(color: effectiveColor),
        ),
      );
    }
    // Pure Flutter, without Material import
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: DraftModePageSpinnerPainter(
            strokeWidth: strokeWidth,
            color: effectiveColor,
          ),
        ),
      ),
    );
  }
}

class DraftModePageSpinnerPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  DraftModePageSpinnerPainter({required this.strokeWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = color
      ..style = PaintingStyle.stroke;

    final arcRect = Offset.zero & size;
    canvas.drawArc(arcRect, 0, 3.141592653589793 * 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
