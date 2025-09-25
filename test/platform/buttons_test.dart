import 'package:draftmode/platform/buttons.dart';
import 'package:draftmode/platform/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  test('returns Cupertino icons when forced to iOS', () {
    PlatformConfig.mode = ForcedPlatform.ios;
    expect(PlatformButtons.back, CupertinoIcons.back);
    expect(PlatformButtons.save, CupertinoIcons.check_mark);
  });

  test('returns Material icons when forced to Android', () {
    PlatformConfig.mode = ForcedPlatform.android;
    expect(PlatformButtons.back, Icons.arrow_back);
    expect(PlatformButtons.save, Icons.check);
  });
}
