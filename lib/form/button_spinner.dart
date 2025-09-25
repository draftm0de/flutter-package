import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DraftModeFormButtonSpinner extends StatefulWidget {
  final Color color;
  const DraftModeFormButtonSpinner({super.key, required this.color});
  @override
  State<DraftModeFormButtonSpinner> createState() => _DraftModeFormButtonSpinnerState();
}

class _DraftModeFormButtonSpinnerState extends State<DraftModeFormButtonSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  late final List<Animation<double>> _scales = List.generate(3, (i) {
    final start = i * 0.15;
    final end = start + 0.7;
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 50),
    ]).animate(CurvedAnimation(parent: _c, curve: Interval(start, end, curve: Curves.easeInOut)));
  });

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _c,
          builder: (bc, bcc) => Transform.scale(
            scale: _scales[i].value,
            child: Container(
              width: 7, height: 7,
              margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
              decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
            ),
          ),
        );
      }),
    );
  }
}
