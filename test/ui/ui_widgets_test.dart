import 'package:draftmode/platform/config.dart';
import 'package:draftmode/ui/confirm.dart';
import 'package:draftmode/ui/row.dart';
import 'package:draftmode/ui/section.dart';
import 'package:draftmode/ui/switch.dart';
import 'package:draftmode/ui/text_error.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  tearDown(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  group('DraftModeUIRow', () {
    testWidgets('renders label and child with expected padding', (
      tester,
    ) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: DraftModeUIRow(label: 'Email', child: Text('value')),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(
        padding.padding,
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
    });

    testWidgets('doubles vertical padding when requested', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: DraftModeUIRow(child: Text('value'), verticalDoubled: true),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(
        padding.padding,
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );
      expect(find.byType(Row), findsNothing);
    });
  });

  group('DraftModeSectionScope', () {
    testWidgets('wraps children inside Cupertino section when on iOS', (
      tester,
    ) async {
      PlatformConfig.mode = ForcedPlatform.ios;
      bool? isInside;

      await tester.pumpWidget(
        CupertinoApp(
          home: DraftModeUISection(
            header: 'Details',
            transparent: true,
            children: [
              Builder(
                builder: (context) {
                  isInside = DraftModeSectionScope.isInSection(context);
                  return const Text('Child');
                },
              ),
            ],
          ),
        ),
      );

      expect(find.text('Details'), findsOneWidget);
      expect(find.byType(CupertinoFormSection), findsOneWidget);
      expect(isInside, isTrue);
    });

    testWidgets('supports sections without header', (tester) async {
      PlatformConfig.mode = ForcedPlatform.ios;
      bool? isInside;

      await tester.pumpWidget(
        CupertinoApp(
          home: DraftModeUISection(
            children: [
              Builder(
                builder: (context) {
                  isInside = DraftModeSectionScope.isInSection(context);
                  return const Text('Child');
                },
              ),
            ],
          ),
        ),
      );

      expect(find.text('Child'), findsOneWidget);
      expect(isInside, isTrue);
    });

    testWidgets('renders material card when on Android', (tester) async {
      PlatformConfig.mode = ForcedPlatform.android;
      bool? isInside;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DraftModeUISection(
              header: 'Preferences',
              transparent: true,
              children: [
                Builder(
                  builder: (context) {
                    isInside = DraftModeSectionScope.isInSection(context);
                    return const Text('Child');
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(isInside, isTrue);
    });

    test('exposes container padding helper', () {
      expect(
        DraftModeSectionScope.containerPadding,
        const EdgeInsets.symmetric(horizontal: 20),
      );
    });

    testWidgets('reports false when outside a section', (tester) async {
      bool? inside;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              inside = DraftModeSectionScope.isInSection(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(inside, isFalse);
    });
  });

  group('DraftModeUIConfirm', () {
    testWidgets('returns true when confirmation pressed on iOS', (
      tester,
    ) async {
      PlatformConfig.mode = ForcedPlatform.ios;
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        CupertinoApp(navigatorKey: navigatorKey, home: const SizedBox.shrink()),
      );

      final future = DraftModeUIConfirm.show(
        context: navigatorKey.currentContext!,
        title: 'Confirm',
        message: 'Proceed?',
      );

      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(await future, isTrue);
    });

    testWidgets('returns false when cancelled on iOS', (tester) async {
      PlatformConfig.mode = ForcedPlatform.ios;
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        CupertinoApp(navigatorKey: navigatorKey, home: const SizedBox.shrink()),
      );

      final future = DraftModeUIConfirm.show(
        context: navigatorKey.currentContext!,
        title: 'Confirm',
        message: 'Proceed?',
      );

      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await future, isFalse);
    });

    testWidgets('uses material alert dialog when not on iOS', (tester) async {
      PlatformConfig.mode = ForcedPlatform.android;
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(navigatorKey: navigatorKey, home: const SizedBox.shrink()),
      );

      final future = DraftModeUIConfirm.show(
        context: navigatorKey.currentContext!,
        title: 'Confirm',
        message: 'Proceed?',
      );

      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(await future, isTrue);
    });

    testWidgets('returns false when cancelled on Android', (tester) async {
      PlatformConfig.mode = ForcedPlatform.android;
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(navigatorKey: navigatorKey, home: const SizedBox.shrink()),
      );

      final future = DraftModeUIConfirm.show(
        context: navigatorKey.currentContext!,
        title: 'Confirm',
        message: 'Proceed?',
      );

      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await future, isFalse);
    });
  });

  group('DraftModeUITextError', () {
    testWidgets('hides when text is null', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: DraftModeUITextError(),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('hides when not visible', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: DraftModeUITextError(text: 'error'),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('renders error with spacing when visible', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: DraftModeUITextError(text: 'error', visible: true, spacing: 6),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      final resolved = padding.padding.resolve(TextDirection.ltr);
      expect(resolved.top, 6);
      expect(find.text('error'), findsOneWidget);
    });
  });

  group('DraftModeUISwitch', () {
    testWidgets('uses Cupertino switch on iOS', (tester) async {
      PlatformConfig.mode = ForcedPlatform.ios;

      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(),
            child: Center(child: DraftModeUISwitch(value: true)),
          ),
        ),
      );

      expect(find.byType(CupertinoSwitch), findsOneWidget);
    });

    testWidgets('uses adaptive material switch on Android', (tester) async {
      PlatformConfig.mode = ForcedPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DraftModeUISwitch(value: false)),
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('invokes callback when toggled on Android', (tester) async {
      PlatformConfig.mode = ForcedPlatform.android;
      bool? latest;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DraftModeUISwitch(
                  value: latest ?? false,
                  onChanged: (value) {
                    latest = value;
                    setState(() {});
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(latest, isTrue);
    });
  });
}
