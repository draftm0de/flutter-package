import 'package:draftmode/platform/styles.dart';
import 'package:draftmode/ui/date_time/week_day.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de');
    Intl.defaultLocale = 'de';
  });

  Widget _wrap(Widget child) => CupertinoApp(
    locale: const Locale('de'),
    supportedLocales: const [Locale('de')],
    localizationsDelegates: const [
      GlobalWidgetsLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );

  testWidgets('renders week layout for selected day', (tester) async {
    final selected = DateTime(2025, 10, 6);
    final expectedHeader = DateFormat('d. MMMM y', 'de').format(selected);

    await tester.pumpWidget(
      _wrap(DraftModeUIDateTimeWeekDay(dateTime: selected, onSelect: (_) {})),
    );
    await tester.pumpAndSettle();

    final header = tester.widget<Text>(
      find.byKey(const ValueKey('week_day_header')),
    );
    expect(header.data, expectedHeader);

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byType(CupertinoButton), findsNWidgets(7));

    const expectedDays = ['6', '7', '8', '9', '10', '11', '12'];
    for (final day in expectedDays) {
      expect(find.text(day), findsOneWidget);
    }

    expect(find.text('MO'), findsOneWidget);
    expect(find.text('DI'), findsOneWidget);
    expect(find.text('SO'), findsOneWidget);
  });

  testWidgets('invokes callback when a day is tapped', (tester) async {
    final selected = DateTime(2025, 10, 6);
    DateTime? tapped;

    await tester.pumpWidget(
      _wrap(
        DraftModeUIDateTimeWeekDay(
          dateTime: selected,
          onSelect: (value) => tapped = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final target = DateTime(2025, 10, 8);
    await tester.tap(find.byKey(ValueKey<DateTime>(target)));
    await tester.pumpAndSettle();

    expect(tapped, target);
    final header = tester.widget<Text>(
      find.byKey(const ValueKey('week_day_header')),
    );
    expect(header.data, DateFormat('d. MMMM y', 'de').format(target));
  });

  testWidgets('tapping selected day still notifies without shifting state', (
    tester,
  ) async {
    final selected = DateTime(2025, 10, 6);
    DateTime? tapped;

    await tester.pumpWidget(
      _wrap(
        DraftModeUIDateTimeWeekDay(
          dateTime: selected,
          onSelect: (value) => tapped = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ValueKey<DateTime>(selected)));
    await tester.pumpAndSettle();

    expect(tapped, selected);
    final header = tester.widget<Text>(
      find.byKey(const ValueKey('week_day_header')),
    );
    expect(header.data, DateFormat('d. MMMM y', 'de').format(selected));
  });

  testWidgets('highlights selected weekday label', (tester) async {
    final selected = DateTime(2025, 10, 6);

    await tester.pumpWidget(
      _wrap(DraftModeUIDateTimeWeekDay(dateTime: selected, onSelect: (_) {})),
    );
    await tester.pumpAndSettle();

    final moText = tester.widget<Text>(find.text('MO'));
    final diText = tester.widget<Text>(find.text('DI'));

    expect(moText.style?.color, DraftModeStyleColorActive.secondary.text);
    expect(diText.style?.color, DraftModeStyleColor.primary.text);

    final selectedButton = find.byKey(ValueKey<DateTime>(selected));
    final chipFinder = find.descendant(
      of: selectedButton,
      matching: find.byType(Container),
    );
    final containers = tester.widgetList<Container>(chipFinder).toList();
    expect(containers, isNotEmpty);

    final chipContainer = containers.firstWhere(
      (container) =>
          container.decoration is BoxDecoration &&
          (container.decoration as BoxDecoration?)?.borderRadius != null,
      orElse: () => containers.first,
    );
    final chipDecoration = chipContainer.decoration as BoxDecoration?;
    expect(
      chipDecoration?.color,
      DraftModeStyleColorActive.secondary.background,
    );

    final numberText = tester.widget<Text>(find.text('6'));
    expect(numberText.style?.color, DraftModeStyleColor.primary.text);

    final circularDecorations = containers
        .where(
          (container) =>
              container.decoration is BoxDecoration &&
              (container.decoration as BoxDecoration).shape == BoxShape.circle,
        )
        .toList();
    expect(circularDecorations, isEmpty);
  });

  testWidgets('marks today number in red without circle', (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await tester.pumpWidget(
      _wrap(DraftModeUIDateTimeWeekDay(dateTime: today, onSelect: (_) {})),
    );
    await tester.pumpAndSettle();

    final dayFinder = find.text('${today.day}');
    expect(dayFinder, findsOneWidget);
    final dayText = tester.widget<Text>(dayFinder);
    expect(
      dayText.style?.color,
      DraftModeStyleColorActive.secondary.background,
    );

    final selectedButton = find.byKey(ValueKey<DateTime>(today));
    final containers = tester.widgetList<Container>(
      find.descendant(of: selectedButton, matching: find.byType(Container)),
    );
    final circularDecorations = containers
        .where(
          (container) =>
              container.decoration is BoxDecoration &&
              (container.decoration as BoxDecoration).shape == BoxShape.circle,
        )
        .toList();
    expect(circularDecorations, isEmpty);
  });

  testWidgets('swiping updates week and selection', (tester) async {
    final selected = DateTime(2025, 10, 6);
    DateTime? lastEmitted;

    await tester.pumpWidget(
      _wrap(
        DraftModeUIDateTimeWeekDay(
          dateTime: selected,
          onSelect: (value) => lastEmitted = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();

    final expectedSelection = DateTime(2025, 10, 13);
    final header = tester.widget<Text>(
      find.byKey(const ValueKey('week_day_header')),
    );
    expect(
      header.data,
      DateFormat('d. MMMM y', 'de').format(expectedSelection),
    );
    expect(find.text('13'), findsWidgets);
    expect(lastEmitted, expectedSelection);
  });

  testWidgets('swiping backwards moves to previous week', (tester) async {
    final selected = DateTime(2025, 10, 6);
    DateTime? lastEmitted;

    await tester.pumpWidget(
      _wrap(
        DraftModeUIDateTimeWeekDay(
          dateTime: selected,
          onSelect: (value) => lastEmitted = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.fling(find.byType(PageView), const Offset(400, 0), 800);
    await tester.pumpAndSettle();

    final expectedSelection = DateTime(2025, 9, 29);
    final header = tester.widget<Text>(
      find.byKey(const ValueKey('week_day_header')),
    );
    expect(
      header.data,
      DateFormat('d. MMMM y', 'de').format(expectedSelection),
    );
    expect(find.text('29'), findsWidgets);
    expect(lastEmitted, expectedSelection);
  });

  testWidgets('external date updates sync the visible week', (tester) async {
    DateTime externalDate = DateTime(2025, 10, 6);
    StateSetter? update;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            update ??= setState;
            return DraftModeUIDateTimeWeekDay(
              dateTime: externalDate,
              onSelect: (_) {},
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final nextWeek = DateTime(2025, 10, 20);
    update?.call(() => externalDate = nextWeek);
    await tester.pumpAndSettle();

    final header = tester.widget<Text>(
      find.byKey(const ValueKey('week_day_header')),
    );
    expect(header.data, DateFormat('d. MMMM y', 'de').format(nextWeek));
    expect(find.text('20'), findsWidgets);
  });
}
