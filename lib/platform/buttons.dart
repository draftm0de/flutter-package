import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform/config.dart';

/// Convenience accessors for platform-aware icons.
class PlatformButtons {
  static IconData get back =>
      PlatformConfig.isIOS ? CupertinoIcons.back : Icons.arrow_back;

  static IconData get close =>
      PlatformConfig.isIOS ? CupertinoIcons.clear : Icons.close;

  static IconData get cancel =>
      PlatformConfig.isIOS ? CupertinoIcons.clear_circled : Icons.circle;

  static IconData get settings =>
      PlatformConfig.isIOS ? CupertinoIcons.settings : Icons.settings;

  static IconData get save =>
      PlatformConfig.isIOS ? CupertinoIcons.check_mark : Icons.check;

  static IconData get logout =>
      PlatformConfig.isIOS ? CupertinoIcons.square_arrow_right : Icons.logout;

  static IconData get start =>
      PlatformConfig.isIOS ? CupertinoIcons.play_arrow_solid : Icons.play_arrow;

  static IconData get stop =>
      PlatformConfig.isIOS ? CupertinoIcons.stop_fill : Icons.stop;

  static IconData get arrowRight =>
      PlatformConfig.isIOS ? CupertinoIcons.right_chevron : Icons.chevron_right;

  static IconData get arrowDown => PlatformConfig.isIOS
      ? CupertinoIcons.chevron_down
      : Icons.arrow_drop_down;

  static IconData get arrowLeft =>
      PlatformConfig.isIOS ? CupertinoIcons.chevron_left : Icons.chevron_left;

  static IconData get arrowUp =>
      PlatformConfig.isIOS ? CupertinoIcons.chevron_up : Icons.arrow_drop_up;

  static IconData get personCircle =>
      PlatformConfig.isIOS ? CupertinoIcons.person_crop_circle : Icons.person;

  static IconData get eye =>
      PlatformConfig.isIOS ? CupertinoIcons.eye : Icons.visibility;

  static IconData get eyeSlash =>
      PlatformConfig.isIOS ? CupertinoIcons.eye_slash : Icons.visibility_off;
}
