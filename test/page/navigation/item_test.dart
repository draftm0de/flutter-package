import 'package:draftmode/page/navigation/item.dart';
import 'package:draftmode/platform/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  group('DraftModePageNavigationItem', () {
    testWidgets('invokes onTap when provided', (tester) async {
      bool tapped = false;
      PlatformConfig.mode = ForcedPlatform.android;

      await tester.pumpWidget(
        MaterialApp(
          home: DraftModePageNavigationItem(
            text: 'Press',
            onTap: () async {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Press'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('pushes loadWidget when onTap not supplied', (tester) async {
      PlatformConfig.mode = ForcedPlatform.ios;

      await tester.pumpWidget(
        CupertinoApp(
          home: Navigator(
            onGenerateRoute: (_) => CupertinoPageRoute(
              builder: (_) => DraftModePageNavigationItem(
                text: 'Open',
                loadWidget: const Placeholder(),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('renders icon and text combination', (tester) async {
      PlatformConfig.mode = ForcedPlatform.android;

      await tester.pumpWidget(
        MaterialApp(
          home: DraftModePageNavigationItem(
            text: 'Next',
            icon: Icons.chevron_right,
            iconExpanded: true,
          ),
        ),
      );

      expect(find.text('Next'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}
