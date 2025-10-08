import 'package:draftmode/ui/date_time/week_day.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

    final header = tester.widget<Text>(
      find.byKey(const ValueKey('week_day_header')),
    );
    expect(header.data, expectedHeader);

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

    final target = DateTime(2025, 10, 8);
    await tester.tap(find.byKey(ValueKey<DateTime>(target)));
    await tester.pump();

    expect(tapped, target);
  });

  testWidgets('highlights selected weekday label', (tester) async {
    final selected = DateTime(2025, 10, 6);

    await tester.pumpWidget(
      _wrap(DraftModeUIDateTimeWeekDay(dateTime: selected, onSelect: (_) {})),
    );

    final moText = tester.widget<Text>(find.text('MO'));
    final diText = tester.widget<Text>(find.text('DI'));

    expect(moText.style?.color, CupertinoColors.white);
    expect(diText.style?.color, CupertinoColors.secondaryLabel);

    final selectedButtonFinder = find.byKey(ValueKey<DateTime>(selected));
    final chipFinder = find.descendant(
      of: selectedButtonFinder,
      matching: find.byType(Container),
    );
    final containers = tester.widgetList<Container>(chipFinder).toList();
    expect(containers, isNotEmpty);

    final moContainerFinder = find.ancestor(
      of: find.text('MO'),
      matching: find.byType(Container),
    );
    final moContainers = tester
        .widgetList<Container>(moContainerFinder)
        .toList();
    expect(moContainers, isNotEmpty);
    final chipDecoration = moContainers.first.decoration as BoxDecoration?;
    expect(chipDecoration?.color, CupertinoColors.activeBlue);
  });
}
