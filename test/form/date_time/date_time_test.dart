import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:draftmode/entity.dart';
import 'package:draftmode/form.dart';
import 'package:draftmode/platform/config.dart';

void main() {
  setUp(() => PlatformConfig.mode = ForcedPlatform.ios);
  tearDown(() => PlatformConfig.mode = ForcedPlatform.auto);

  testWidgets('updates attribute when selecting a new day', (tester) async {
    final attribute = DraftModeEntityAttribute<DateTime>(
      value: DateTime(2024, 1, 15, 9, 0),
    );
    DateTime? observed;

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeFormDateTime(
          attribute: attribute,
          onChanged: (value) => observed = value,
        ),
      ),
    );

    expect(find.text('01/15/2024'), findsOneWidget);

    await tester.tap(find.text('01/15/2024'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('month_grid')), findsOneWidget);

    await tester.tap(find.text('16'));
    await tester.pumpAndSettle();

    expect(attribute.value, DateTime(2024, 1, 16, 9, 0));
    expect(observed, DateTime(2024, 1, 16, 9, 0));
  });

  testWidgets('opens hour minute picker when time button tapped', (
    tester,
  ) async {
    final attribute = DraftModeEntityAttribute<DateTime>(
      value: DateTime(2024, 1, 15, 9, 0),
    );

    await tester.pumpWidget(
      CupertinoApp(home: DraftModeFormDateTime(attribute: attribute)),
    );

    expect(find.text('09:00'), findsOneWidget);

    await tester.tap(find.text('09:00'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('hour_minute')), findsOneWidget);
  });
}
