import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

import '../../platform/buttons.dart';
import '../../platform/styles.dart';
import '../icon_filled.dart';

/// Paints a vertical timeline gutter used in date/time pickers to match the
/// native grouped form layout on iOS.
///
/// The widget owns the draw logic so consumers can drop it next to a column of
/// content without wiring up their own [CustomPainter]. The timeline keeps a
/// fixed [width] to align with native list gutters while exposing knobs for
/// colour or radius tweaks when necessary.
class DraftModeDateTimeline extends StatelessWidget {
  static const IconData _defaultCheckedIconToken = IconData(
    0,
    fontFamily: '_DraftModeTimelineDefault',
  );

  const DraftModeDateTimeline({
    super.key,
    this.width = 32,
    this.lineColor,
    this.checkedIcon = _defaultCheckedIconToken,
  }) : assert(width > 0);

  static const double _padTop = 1;
  static const double _padBottom = 0;
  static const double _lineWidth = 3;
  static const double _nodeAlignment = 0.40;
  static const double _nodeDiameter = 28;
  static const double _nodeBorderWidth = 2;
  static const double _defaultHeight = 44;

  /// Gutter width reserved for the painted timeline.
  final double width;

  /// Colour used for the vertical spine and node border.
  final Color? lineColor;

  /// Icon rendered inside the highlighted node. Pass `null` to render an empty
  /// circle, or omit to use the platform-aware default.
  final IconData? checkedIcon;

  @override
  Widget build(BuildContext context) {
    final Color resolvedLineColor =
        lineColor ?? DraftModeStyleColorActive.primary.background;
    final IconData? resolvedIcon =
        identical(checkedIcon, _defaultCheckedIconToken)
        ? PlatformButtons.checkSecondary
        : checkedIcon;

    return SizedBox(
      width: width,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final double height = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : _defaultHeight;

          final double top = _padTop;
          final double bottom = math.max(top, height - _padBottom);
          final double? nodeCenterY = ui.lerpDouble(
            top,
            bottom,
            _nodeAlignment,
          );
          final double resolvedCenterY =
              nodeCenterY ?? top + (bottom - top) / 2;
          final double nodeTop = resolvedCenterY - _nodeDiameter / 2;
          final double nodeLeft =
              (width - _nodeDiameter) / 2 + _nodeBorderWidth / 2;

          return SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TimelinePainter(lineColor: resolvedLineColor),
                  ),
                ),
                Positioned(
                  left: nodeLeft,
                  top: nodeTop,
                  child: DraftModeUIIconFilled(
                    size: _nodeDiameter,
                    color: resolvedLineColor,
                    borderColor: _scaledOpacity(resolvedLineColor, 0.6),
                    iconColor: _scaledOpacity(resolvedLineColor, 0.9),
                    backgroundColor: DraftModeStyleColor.primary.background,
                    borderWidth: _nodeBorderWidth,
                    innerIcon: resolvedIcon,
                    innerIconSize: resolvedIcon != null ? 20 : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that renders the timeline stroke.
class _TimelinePainter extends CustomPainter {
  const _TimelinePainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double top = DraftModeDateTimeline._padTop;
    final double bottom = math.max(
      top,
      size.height - DraftModeDateTimeline._padBottom,
    );

    final Paint line = Paint()
      ..color = lineColor
      ..strokeWidth = DraftModeDateTimeline._lineWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, top), Offset(cx, bottom), line);
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}

Color _scaledOpacity(Color color, double factor) {
  final double scaled = (color.a * 255.0 * factor).clamp(0.0, 255.0);
  return color.withAlpha(scaled.round());
}
