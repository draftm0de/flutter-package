import 'package:draftmode/platform/buttons.dart';
import 'package:draftmode/platform/config.dart';
import 'package:draftmode/platform/styles.dart';
import 'package:draftmode/ui/button.dart';
import 'package:draftmode/ui/confirm.dart';
import 'package:draftmode/ui/date_time/time_line.dart';
import 'package:draftmode/ui/row.dart';
import 'package:draftmode/ui/section.dart';
import 'package:draftmode/ui/switch.dart';
import 'package:draftmode/ui/error_dialog.dart';
import 'package:draftmode/ui/error_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
        EdgeInsets.symmetric(
          horizontal: DraftModeStylePadding.primary,
          vertical: DraftModeStylePadding.tertiary,
        ),
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
        EdgeInsets.symmetric(
          horizontal: DraftModeStylePadding.primary,
          vertical: DraftModeStylePadding.tertiary * 2,
        ),
      );
      expect(find.byType(Row), findsNothing);
    });
  });

  group('DraftModeDateTimeline', () {
    testWidgets('paints with expected gutter width and inherited height', (
      tester,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: UnconstrainedBox(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 80,
              child: DraftModeDateTimeline(
                checkedIcon: PlatformButtons.checkSecondary,
              ),
            ),
          ),
        ),
      );

      final Size size = tester.getSize(find.byType(DraftModeDateTimeline));
      expect(size, const Size(32, 80));
      expect(
        find.descendant(
          of: find.byType(DraftModeDateTimeline),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(PlatformButtons.checkSecondary), findsOneWidget);
    });

    testWidgets('allows width customisation', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: UnconstrainedBox(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 64,
              child: DraftModeDateTimeline(width: 40, checkedIcon: null),
            ),
          ),
        ),
      );

      final Size size = tester.getSize(find.byType(DraftModeDateTimeline));
      expect(size, const Size(40, 64));
      expect(
        find.descendant(
          of: find.byType(DraftModeDateTimeline),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('falls back to intrinsic height when unconstrained', (
      tester,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            height: 120,
            child: ListView(
              shrinkWrap: true,
              children: const [DraftModeDateTimeline(checkedIcon: null)],
            ),
          ),
        ),
      );

      final Size size = tester.getSize(find.byType(DraftModeDateTimeline));
      expect(size.height, 44);
    });

    testWidgets('repaints when configuration changes', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: DraftModeDateTimeline(),
        ),
      );

      var renderObject = tester.renderObject<RenderCustomPaint>(
        find.byType(CustomPaint),
      );
      final CustomPainter initialPainter = renderObject.painter!;
      expect(initialPainter.shouldRepaint(initialPainter), isFalse);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DraftModeDateTimeline(
            lineColor: CupertinoColors.systemRed,
            checkedIcon: PlatformButtons.checkSecondary,
          ),
        ),
      );

      renderObject = tester.renderObject<RenderCustomPaint>(
        find.byType(CustomPaint),
      );
      final CustomPainter updatedPainter = renderObject.painter!;
      expect(updatedPainter.shouldRepaint(initialPainter), isTrue);
    });
  });

  group('DraftModeDateTimeline asserts', () {
    test('throws when width is not positive', () {
      expect(() => DraftModeDateTimeline(width: 0), throwsAssertionError);
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
      expect(find.byType(CupertinoListSection), findsOneWidget);
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

  group('DraftModeUIButton', () {
    testWidgets('renders Cupertino button on iOS', (tester) async {
      PlatformConfig.mode = ForcedPlatform.ios;

      await tester.pumpWidget(
        CupertinoApp(
          home: DraftModeUIButton(child: const Text('Tap'), onPressed: () {}),
        ),
      );

      expect(find.byType(CupertinoButton), findsOneWidget);
    });

    testWidgets('renders FilledButton on Android', (tester) async {
      PlatformConfig.mode = ForcedPlatform.android;

      await tester.pumpWidget(
        MaterialApp(
          home: DraftModeUIButton(child: const Text('Tap'), onPressed: () {}),
        ),
      );

      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('shows pending child when busy', (tester) async {
      PlatformConfig.mode = ForcedPlatform.ios;

      await tester.pumpWidget(
        CupertinoApp(
          home: DraftModeUIButton(
            isPending: true,
            pendingChild: const Text('Loading'),
            child: const Text('Tap'),
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Loading'), findsOneWidget);
      final cupertino = tester.widget<CupertinoButton>(
        find.byType(CupertinoButton),
      );
      expect(
        cupertino.onPressed,
        isNull,
        reason: 'button disabled while pending',
      );
    });
  });

  group('DraftModeUIErrorText', () {
    testWidgets('hides when text is null', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: DraftModeUIErrorText(),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('hides when not visible', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: DraftModeUIErrorText(text: 'error'),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('renders error with spacing when visible', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: DraftModeUIErrorText(text: 'error', visible: true),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      final resolved = padding.padding.resolve(TextDirection.ltr);
      expect(resolved.top, DraftModeStylePadding.tertiary);
      expect(find.text('error'), findsOneWidget);
    });
  });

  group('DraftModeUIErrorDialog', () {
    testWidgets('presents and dismisses dialog', (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) => CupertinoPageScaffold(
              navigationBar: const CupertinoNavigationBar(),
              child: Center(
                child: CupertinoButton(
                  onPressed: () => DraftModeUIErrorDialog(
                    context,
                    title: 'Failure',
                    message: 'Something went wrong',
                  ),
                  child: const Text('Trigger'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Failure'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Failure'), findsNothing);
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
