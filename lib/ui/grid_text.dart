import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../platform/styles.dart';

enum DraftModeUIGridTextVariant { chip, number, calendar }

class DraftModeUIGridText<T> extends StatelessWidget {
  final List<T> values;
  final ValueChanged<T>? onPressed;
  final DraftModeUIGridTextVariant variant;
  final double itemHeight;
  final double itemWidth;
  final String Function(T value, int index) labelBuilder;
  final bool Function(T value, int index)? isSelected;
  final bool Function(T value, int index)? isActive;
  final Key? Function(T value, int index)? keyBuilder;

  const DraftModeUIGridText({
    super.key,
    required this.values,
    this.onPressed,
    required this.variant,
    required this.itemHeight,
    required this.itemWidth,
    required this.labelBuilder,
    this.isSelected,
    this.isActive,
    this.keyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(values.length, (index) {
        final value = values[index];
        if (value == null) {
          return Expanded(child: SizedBox(height: itemHeight));
        }
        final itemKey = keyBuilder?.call(value, index);
        final content = _GridTextContent(
          label: labelBuilder(value, index),
          isSelected: isSelected?.call(value, index) ?? false,
          isActive: isActive?.call(value, index) ?? false,
          variant: variant,
          height: itemHeight,
          width: itemWidth,
        );

        if (onPressed == null) {
          return Expanded(
            child: SizedBox(
              height: itemHeight,
              child: Center(
                child: KeyedSubtree(key: itemKey, child: content),
              ),
            ),
          );
        }

        return Expanded(
          child: CupertinoButton(
            key: itemKey,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: () => onPressed!(value),
            child: content,
          ),
        );
      }),
    );
  }
}

class _GridTextContent extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isActive;
  final DraftModeUIGridTextVariant variant;
  final double height;
  final double width;

  const _GridTextContent({
    required this.label,
    required this.isSelected,
    required this.isActive,
    required this.variant,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case DraftModeUIGridTextVariant.chip:
        return _buildChip();
      case DraftModeUIGridTextVariant.number:
        return _buildNumber();
      case DraftModeUIGridTextVariant.calendar:
        return _buildCalendar();
    }
  }

  Widget _buildChip() {
    final textStyle = TextStyle(
      fontSize: DraftModeStyleFontSize.tertiary,
      fontWeight: DraftModeStyleFontWeight.primary,
      color: isSelected
          ? DraftModeStyleColorActive.secondary.text
          : DraftModeStyleColor.primary.text,
    );

    final decoration = isSelected
        ? BoxDecoration(
            color: DraftModeStyleColorActive.secondary.background,
            borderRadius: BorderRadius.circular(20),
          )
        : null;

    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      decoration: decoration,
      child: Text(label, style: textStyle, textAlign: TextAlign.center),
    );
  }

  Widget _buildNumber() {
    final textColor = isActive
        ? DraftModeStyleColorActive.secondary.background
        : DraftModeStyleColor.primary.text;

    final fontWeight = isSelected
        ? DraftModeStyleFontWeight.secondary
        : DraftModeStyleFontWeight.primary;

    return SizedBox(
      height: height,
      width: width,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: DraftModeStyleFontSize.primary,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final bool isToday = isActive;

    Color textColor = DraftModeStyleColor.primary.text;
    Color? backgroundColor;
    FontWeight fontWeight = DraftModeStyleFontWeight.primary;

    if (isToday && isSelected) {
      backgroundColor = DraftModeStyleColorActive.quaternary.background;
      textColor = DraftModeStyleColorActive.quaternary.text;
      fontWeight = DraftModeStyleFontWeight.secondary;
    } else if (isToday && !isSelected) {
      backgroundColor = null;
      textColor = DraftModeStyleColorActive.secondary.background;
    } else if (!isToday && isSelected) {
      backgroundColor = DraftModeStyleColorActive.secondary.background;
      textColor = DraftModeStyleColorActive.secondary.text;
      fontWeight = DraftModeStyleFontWeight.secondary;
    }

    final BoxDecoration? decoration = backgroundColor != null
        ? BoxDecoration(color: backgroundColor, shape: BoxShape.circle)
        : null;

    final circleSize = math.min(height, width);

    return SizedBox(
      height: height,
      width: width,
      child: Center(
        child: Container(
          alignment: Alignment.center,
          height: circleSize,
          width: circleSize,
          decoration: decoration,
          child: Text(
            label,
            style: TextStyle(
              fontSize: DraftModeStyleFontSize.primary,
              fontWeight: fontWeight,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
