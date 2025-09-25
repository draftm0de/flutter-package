import 'package:draftmode/page/navigation/top.dart';
import 'package:draftmode/platform/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  testWidgets('DraftModePageNavigationTop renders Cupertino bar on iOS', (
    tester,
  ) async {
    PlatformConfig.mode = ForcedPlatform.ios;
    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModePageNavigationTop(
          title: 'Title',
          leading: const Text('Lead'),
          trailing: const [Text('Action')],
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Lead'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);
  });

  testWidgets('DraftModePageNavigationTop renders AppBar on Android', (
    tester,
  ) async {
    PlatformConfig.mode = ForcedPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(appBar: DraftModePageNavigationTop(title: 'Material')),
      ),
    );

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Material'), findsOneWidget);
  });
}
