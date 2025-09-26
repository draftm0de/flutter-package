import 'package:draftmode/l10n/app_localizations.dart';
import 'package:draftmode/l10n/app_localizations_en.dart';
import 'package:draftmode/page/page.dart';
import 'package:draftmode/page/navigation/bottom_item.dart';
import 'package:draftmode/platform/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _cupertinoShell(Widget home) {
  return CupertinoApp(
    localizationsDelegates: const [
      _TestDraftModeLocalizationsDelegate(),
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  );
}

Widget _materialShell(Widget home) {
  return MaterialApp(
    localizationsDelegates: const [
      _TestDraftModeLocalizationsDelegate(),
      GlobalWidgetsLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
    ],
    home: home,
  );
}

class _TestDraftModeLocalizationsDelegate
    extends LocalizationsDelegate<DraftModeLocalizations> {
  const _TestDraftModeLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<DraftModeLocalizations> load(Locale locale) async {
    return DraftModeLocalizationsEn(locale.languageCode);
  }

  @override
  bool shouldReload(LocalizationsDelegate<DraftModeLocalizations> old) => false;
}

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  tearDown(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  group('DraftModePage', () {
    testWidgets('renders Cupertino scaffold with default back button', (
      tester,
    ) async {
      PlatformConfig.mode = ForcedPlatform.ios;
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        _cupertinoShell(
          Navigator(
            key: navigatorKey,
            onGenerateRoute: (_) =>
                CupertinoPageRoute(builder: (_) => const Placeholder()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      navigatorKey.currentState!.push(
        CupertinoPageRoute(
          builder: (_) =>
              DraftModePage(navigationTitle: 'Title', body: const Text('Body')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('invokes save callback and pops when true', (tester) async {
      PlatformConfig.mode = ForcedPlatform.ios;
      bool called = false;
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        _cupertinoShell(
          Navigator(
            key: navigatorKey,
            onGenerateRoute: (_) =>
                CupertinoPageRoute(builder: (_) => const Placeholder()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      navigatorKey.currentState!.push(
        CupertinoPageRoute(
          builder: (_) => DraftModePage(
            navigationTitle: 'Edit',
            body: const Text('Body'),
            onSavePressed: () async {
              called = true;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ready'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('renders Material scaffold on Android', (tester) async {
      PlatformConfig.mode = ForcedPlatform.android;
      await tester.pumpWidget(
        _materialShell(
          DraftModePage(navigationTitle: 'Title', body: const Text('Body')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('renders bottom navigation when provided', (tester) async {
      PlatformConfig.mode = ForcedPlatform.android;
      await tester.pumpWidget(
        _materialShell(
          DraftModePage(
            navigationTitle: 'Title',
            body: const SizedBox.expand(),
            bottomLeading: const [DraftModePageNavigationBottomItem(text: 'A')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('uses explicit top leading widget when provided', (
      tester,
    ) async {
      PlatformConfig.mode = ForcedPlatform.ios;

      await tester.pumpWidget(
        _cupertinoShell(
          DraftModePage(
            navigationTitle: 'Title',
            topLeading: const Icon(CupertinoIcons.settings),
            body: const Text('Body'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == CupertinoIcons.settings,
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'falls back to provided leading text when localisation missing',
      (tester) async {
        PlatformConfig.mode = ForcedPlatform.ios;

        await tester.pumpWidget(
          CupertinoApp(
            home: DraftModePage(
              navigationTitle: 'Title',
              topLeadingText: 'Zurück',
              body: const Text('Body'),
            ),
          ),
        );

        expect(find.text('Zurück'), findsOneWidget);
      },
    );

    testWidgets('shows save icon on Android and stays when callback false', (
      tester,
    ) async {
      PlatformConfig.mode = ForcedPlatform.android;
      bool called = false;

      await tester.pumpWidget(
        _materialShell(
          DraftModePage(
            navigationTitle: 'Title',
            body: const Text('Body'),
            onSavePressed: () async {
              called = true;
              return false;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('renders body directly and applies background override', (
      tester,
    ) async {
      PlatformConfig.mode = ForcedPlatform.android;

      await tester.pumpWidget(
        _materialShell(
          DraftModePage(
            navigationTitle: 'Title',
            body: const Text('Body'),
            horizontalContainerPadding: 4,
            verticalContainerPadding: 10,
            containerBackgroundColor: const Color(0xFFABCDEF),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFABCDEF));
      expect(
        scaffold.body,
        isA<Text>().having((text) => text.data, 'body text', 'Body'),
      );
    });
  });
}
