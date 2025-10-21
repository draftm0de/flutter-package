import 'package:draftmode/platform/buttons.dart';
import 'package:draftmode/platform/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  Map<String, IconData> _resolveButtons() {
    return {
      'back': PlatformButtons.back,
      'close': PlatformButtons.close,
      'cancel': PlatformButtons.cancel,
      'settings': PlatformButtons.settings,
      'save': PlatformButtons.save,
      'logout': PlatformButtons.logout,
      'start': PlatformButtons.start,
      'stop': PlatformButtons.stop,
      'edit': PlatformButtons.edit,
      'arrowRight': PlatformButtons.arrowRight,
      'arrowDown': PlatformButtons.arrowDown,
      'arrowLeft': PlatformButtons.arrowLeft,
      'arrowUp': PlatformButtons.arrowUp,
      'personCircle': PlatformButtons.personCircle,
      'eye': PlatformButtons.eye,
      'eyeSlash': PlatformButtons.eyeSlash,
    };
  }

  test('returns Cupertino icons when forced to iOS', () {
    PlatformConfig.mode = ForcedPlatform.ios;

    expect(_resolveButtons(), {
      'back': CupertinoIcons.back,
      'close': CupertinoIcons.clear,
      'cancel': CupertinoIcons.multiply_circle,
      'settings': CupertinoIcons.settings,
      'save': CupertinoIcons.check_mark,
      'logout': CupertinoIcons.square_arrow_right,
      'start': CupertinoIcons.largecircle_fill_circle,
      'stop': CupertinoIcons.stop_fill,
      'edit': CupertinoIcons.square_pencil,
      'arrowRight': CupertinoIcons.right_chevron,
      'arrowDown': CupertinoIcons.chevron_down,
      'arrowLeft': CupertinoIcons.chevron_left,
      'arrowUp': CupertinoIcons.chevron_up,
      'personCircle': CupertinoIcons.person_crop_circle,
      'eye': CupertinoIcons.eye,
      'eyeSlash': CupertinoIcons.eye_slash,
    });
  });

  test('returns Material icons when forced to Android', () {
    PlatformConfig.mode = ForcedPlatform.android;

    expect(_resolveButtons(), {
      'back': Icons.arrow_back,
      'close': Icons.close,
      'cancel': Icons.circle,
      'settings': Icons.settings,
      'save': Icons.check,
      'logout': Icons.logout,
      'start': Icons.mode_standby,
      'stop': Icons.stop,
      'edit': Icons.edit_square,
      'arrowRight': Icons.chevron_right,
      'arrowDown': Icons.arrow_drop_down,
      'arrowLeft': Icons.chevron_left,
      'arrowUp': Icons.arrow_drop_up,
      'personCircle': Icons.person,
      'eye': Icons.visibility,
      'eyeSlash': Icons.visibility_off,
    });
  });
}
