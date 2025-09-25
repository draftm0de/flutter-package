import 'package:draftmode/page/navigation/bottom.dart';
import 'package:draftmode/page/navigation/bottom_item.dart';
import 'package:draftmode/platform/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  testWidgets(
    'DraftModePageNavigationBottom spreads leading/primary/trailing content',
    (tester) async {
      PlatformConfig.mode = ForcedPlatform.android;
      await tester.pumpWidget(
        MaterialApp(
          home: DraftModePageNavigationBottom(
            leading: const [Text('L')],
            primary: const Text('C'),
            trailing: const [Text('R')],
          ),
        ),
      );

      expect(find.text('L'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
    },
  );

  testWidgets(
    'DraftModePageNavigationBottomItem delegates to navigation item',
    (tester) async {
      PlatformConfig.mode = ForcedPlatform.android;
      await tester.pumpWidget(
        MaterialApp(home: DraftModePageNavigationBottomItem(text: 'Bottom')),
      );

      expect(find.text('Bottom'), findsOneWidget);
    },
  );
}
