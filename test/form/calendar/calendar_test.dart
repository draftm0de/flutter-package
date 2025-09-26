import 'package:draftmode/entity.dart';
import 'package:draftmode/form.dart';
import 'package:draftmode/form/calender/iso.dart';
import 'package:draftmode/platform/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.ios;
  });

  tearDown(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  testWidgets('rounds selections to five minute increments', (tester) async {
    final fromAttr = DraftModeEntityAttribute<DateTime>(
      value: DateTime(2024, 1, 1, 10, 3),
    );

    await tester.pumpWidget(
      CupertinoApp(home: DraftModeFormCalendar(from: fromAttr)),
    );

    expect(find.text('10:00'), findsOneWidget);

    await tester.tap(find.text('10:00'));
    await tester.pump();
    expect(find.byType(DraftModeCalendarIOS), findsOneWidget);
  });

  testWidgets('displays duration when range is enabled', (tester) async {
    final fromAttr = DraftModeEntityAttribute<DateTime>(
      value: DateTime(2024, 1, 1, 9, 15),
    );
    final toAttr = DraftModeEntityAttribute<DateTime>(
      value: DateTime(2024, 1, 1, 11, 0),
    );

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeFormCalendar(
          from: fromAttr,
          to: toAttr,
          durationMode: DraftModeFormCalendarDurationMode.hours,
          durationLabel: 'Duration',
        ),
      ),
    );

    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('1:45'), findsOneWidget);
  });
}
