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

    testWidgets('renders icon-only button when text omitted', (tester) async {
      PlatformConfig.mode = ForcedPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(home: DraftModePageNavigationItem(icon: Icons.close)),
      );

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Padding && widget.padding == EdgeInsets.zero,
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('renders text-only button when icon omitted', (tester) async {
      PlatformConfig.mode = ForcedPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(home: DraftModePageNavigationItem(text: 'Only text')),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding == const EdgeInsets.only(right: 5),
        ),
        findsOneWidget,
      );
      expect(find.text('Only text'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('renders empty placeholder when no content provided', (
      tester,
    ) async {
      PlatformConfig.mode = ForcedPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(home: DraftModePageNavigationItem()),
      );

      expect(
        find.descendant(
          of: find.byType(TextButton),
          matching: find.byType(SizedBox),
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses MaterialPageRoute when pushing load widget on Android', (
      tester,
    ) async {
      PlatformConfig.mode = ForcedPlatform.android;

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) =>
                  DraftModePageNavigationItem(loadWidget: const Placeholder()),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(find.byType(Placeholder), findsOneWidget);
    });
  });
}
