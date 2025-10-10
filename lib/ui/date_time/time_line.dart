import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

import '../../platform/styles.dart';

/// Paints a vertical timeline gutter used in date/time pickers to match the
/// native grouped form layout on iOS.
///
/// The widget owns the draw logic so consumers can drop it next to a column of
/// content without wiring up their own [CustomPainter]. The timeline keeps a
/// fixed [width] to align with native list gutters while exposing knobs for
/// colour or radius tweaks when necessary.
class DraftModeDateTimeline extends StatelessWidget {
  const DraftModeDateTimeline({
    super.key,
    this.width = 28,
    this.lineColor,
    this.lineWidth = 3,
    this.nodeRadius = 12,
    this.nodeStroke = 2,
    this.nodeAlignment = 0.22,
    this.padTop = 6,
    this.padBottom = 6,
    this.showCheck = true,
  }) : assert(width > 0),
       assert(lineWidth >= 0),
       assert(nodeRadius > 0),
       assert(nodeStroke >= 0),
       assert(nodeAlignment >= 0 && nodeAlignment <= 1),
       assert(padTop >= 0),
       assert(padBottom >= 0);

  /// Gutter width reserved for the painted timeline.
  final double width;

  /// Colour used for the main axis and outer stroke of the node.
  final Color? lineColor;

  /// Stroke width applied to the vertical connector.
  final double lineWidth;

  /// Radius of the highlight node that marks the active date.
  final double nodeRadius;

  /// Stroke width drawn around the node.
  final double nodeStroke;

  /// Relative position of the node (0 for top, 1 for bottom).
  final double nodeAlignment;

  /// Padding applied to lift the stroke off the rounded section corners.
  final double padTop;

  /// Padding applied at the bottom of the stroke.
  final double padBottom;

  /// When true the inner node paints a completion checkmark.
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final double clampedAlignment = nodeAlignment.clamp(0.0, 1.0);
    final Color resolvedLineColor =
        lineColor ?? DraftModeStyleColorActive.primary.background;

    return SizedBox(
      width: width,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final double fallbackHeight = math.max(
            (nodeRadius + nodeStroke) * 2 + padTop + padBottom,
            lineWidth,
          );
          final double height = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : constraints.constrainHeight(fallbackHeight);

          return CustomPaint(
            size: Size(width, height),
            painter: _TimelinePainter(
              lineColor: resolvedLineColor,
              lineWidth: lineWidth,
              nodeRadius: nodeRadius,
              nodeStroke: nodeStroke,
              nodeAlignment: clampedAlignment,
              padTop: padTop,
              padBottom: padBottom,
              showCheck: showCheck,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that renders the timeline stroke, node, and optional check.
class _TimelinePainter extends CustomPainter {
  const _TimelinePainter({
    required this.lineColor,
    required this.lineWidth,
    required this.nodeRadius,
    required this.nodeStroke,
    required this.nodeAlignment,
    required this.padTop,
    required this.padBottom,
    required this.showCheck,
  });

  final Color lineColor;
  final double lineWidth;
  final double nodeRadius;
  final double nodeStroke;
  final double nodeAlignment;
  final double padTop;
  final double padBottom;
  final bool showCheck;

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double top = padTop;
    final double bottom = math.max(top, size.height - padBottom);

    final Paint line = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, top), Offset(cx, bottom), line);

    final double? cy = ui.lerpDouble(top, bottom, nodeAlignment);
    if (cy == null) {
      return;
    }

    final Paint inner = Paint()
      ..style = PaintingStyle.fill
      ..color = DraftModeStyleColor.primary.background;
    final Paint outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = nodeStroke
      ..color = lineColor.withAlpha(_scaledAlpha(lineColor, 0.6));

    final Offset center = Offset(cx, cy);
    canvas.drawCircle(center, nodeRadius, inner);
    canvas.drawCircle(center, nodeRadius, outer);

    if (!showCheck) {
      return;
    }

    final double r = nodeRadius * 0.55;
    final Path check = Path()
      ..moveTo(cx - r * 0.9, cy)
      ..lineTo(cx - r * 0.2, cy + r * 0.7)
      ..lineTo(cx + r * 1.1, cy - r * 0.6);

    final Paint stroke = Paint()
      ..color = lineColor.withAlpha(_scaledAlpha(lineColor, 0.9))
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, nodeStroke)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(check, stroke);
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.nodeRadius != nodeRadius ||
        oldDelegate.nodeStroke != nodeStroke ||
        oldDelegate.nodeAlignment != nodeAlignment ||
        oldDelegate.padTop != padTop ||
        oldDelegate.padBottom != padBottom ||
        oldDelegate.showCheck != showCheck;
  }

  int _scaledAlpha(Color color, double factor) {
    final int scaled = (color.a * 255.0 * factor).round();
    return scaled.clamp(0, 255).toInt();
  }
}
