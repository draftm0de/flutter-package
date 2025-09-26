import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:draftmode/entity.dart';
import 'package:draftmode/form.dart';
import 'package:draftmode/platform/config.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.ios;
  });

  tearDown(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  testWidgets('updates draft values as the user types', (tester) async {
    final attribute = DraftModeEntityAttribute<String>(
      validators: [
        (context, form, value) =>
            (value == null || value.isEmpty) ? 'Required' : null,
      ],
    );

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          child: DraftModeFormField<String>(
            attribute: attribute,
            label: 'Name',
            placeholder: 'Enter name',
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(CupertinoTextField), 'Ada');
    await tester.pump();

    final formState = tester.state<DraftModeFormState>(
      find.byType(DraftModeForm),
    );
    expect(formState.read(attribute), 'Ada');

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsNothing);

    await tester.enterText(find.byType(CupertinoTextField), '');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('toggles obscure eye suffix', (tester) async {
    final attribute = DraftModeEntityAttribute<String>(value: 'secret');

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          child: DraftModeFormField<String>(
            attribute: attribute,
            obscureText: true,
            obscureEye: true,
          ),
        ),
      ),
    );

    expect(find.byIcon(CupertinoIcons.eye_slash), findsOneWidget);
    await tester.tap(find.byIcon(CupertinoIcons.eye_slash));
    await tester.pump();
    expect(find.byIcon(CupertinoIcons.eye), findsOneWidget);
  });
}
