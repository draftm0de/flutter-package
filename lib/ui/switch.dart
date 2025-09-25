import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;

import '../platform/config.dart';

/// Adaptive switch that mirrors the native control for the active platform.
class DraftModeUISwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  const DraftModeUISwitch({super.key, this.value = false, this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (PlatformConfig.isIOS) {
      return CupertinoSwitch(value: value, onChanged: onChanged);
    }
    return material.Switch.adaptive(value: value, onChanged: onChanged);
  }
}
