import 'package:flutter/cupertino.dart';
import '../platform/config.dart';

class DraftModeUISwitch extends StatelessWidget {
  final bool value;
  final Function(bool)? onChanged;
  const DraftModeUISwitch({
    super.key,
    this.value = false,
    required this.onChanged
  });


  Widget _layoutIOS() {
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _layoutAndroid() {
    return Text("not implemented");
  }

  @override
  Widget build(BuildContext context) {
    return PlatformConfig.isIOS ? _layoutIOS() : _layoutAndroid();
  }
}
