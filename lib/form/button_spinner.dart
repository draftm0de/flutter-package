import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Minimal three-dot bounce animation used while form buttons await async
/// callbacks. Kept lightweight to avoid pulling in the heavier progress
/// indicators from `material` or `cupertino`.
class DraftModeFormButtonSpinner extends StatefulWidget {
  final Color color;
  const DraftModeFormButtonSpinner({super.key, required this.color});

  @override
  State<DraftModeFormButtonSpinner> createState() =>
      _DraftModeFormButtonSpinnerState();
}

class _DraftModeFormButtonSpinnerState extends State<DraftModeFormButtonSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  late final List<Animation<double>> _scales = List.generate(3, (index) {
    final start = index * 0.15;
    final end = start + 0.7;
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeInOut),
      ),
    );
  });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => Transform.scale(
            scale: _scales[index].value,
            child: Container(
              width: 7,
              height: 7,
              margin: EdgeInsets.only(left: index == 0 ? 0 : 6),
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
