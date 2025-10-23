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
      null,
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
    final attribute = DraftModeEntityAttribute<String>('secret');

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

  testWidgets('limits text input length when vMaxLen registered', (
    tester,
  ) async {
    final attribute = DraftModeEntityAttribute<String>(
      null,
      validators: <DraftModeEntityValidator>[vMaxLen(8)],
    );

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          child: DraftModeFormField<String>(
            attribute: attribute,
            label: 'Code',
          ),
        ),
      ),
    );

    final textField = tester.widget<CupertinoTextField>(
      find.byType(CupertinoTextField),
    );
    expect(textField.maxLength, 8);
  });

  testWidgets('configures keyboard type from attribute kind', (tester) async {
    Future<CupertinoTextField> pumpField(
      DraftModeEntityAttributeKind kind,
    ) async {
      final attribute = DraftModeEntityAttribute<String>(null, kind: kind);

      await tester.pumpWidget(
        CupertinoApp(
          home: DraftModeForm(
            child: DraftModeFormField<String>(attribute: attribute),
          ),
        ),
      );
      await tester.pump();

      return tester.widget<CupertinoTextField>(find.byType(CupertinoTextField));
    }

    final phoneField = await pumpField(DraftModeEntityAttributeKind.phone);
    expect(phoneField.keyboardType, TextInputType.phone);

    final emailField = await pumpField(DraftModeEntityAttributeKind.email);
    expect(emailField.keyboardType, TextInputType.emailAddress);

    final dateField = await pumpField(DraftModeEntityAttributeKind.datetime);
    expect(dateField.keyboardType, TextInputType.datetime);
  });

  testWidgets('formats decimal input with localized separators', (
    tester,
  ) async {
    await tester.enterText(find.byType(CupertinoTextField), '1234567,89');
    await tester.pump();

    final textField = tester.widget<CupertinoTextField>(
      find.byType(CupertinoTextField),
    );
    expect(textField.controller?.text, '1.234.567,89');
  });

  testWidgets('coerces numeric generics into typed values', (tester) async {
    final intAttribute = DraftModeEntityAttribute<int>(null);

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          child: DraftModeFormField<int>(attribute: intAttribute),
        ),
      ),
    );

    final fieldFinder = find.byType(CupertinoTextField);

    await tester.enterText(fieldFinder, '42');
    await tester.pump();

    var textField = tester.widget<CupertinoTextField>(fieldFinder);
    expect(textField.controller?.text, '42');

    final intFormState = tester.state<DraftModeFormState>(
      find.byType(DraftModeForm),
    );
    expect(intFormState.read(intAttribute), 42);

    await tester.enterText(fieldFinder, '1234'); // should group on next pump
    await tester.pump();

    textField = tester.widget<CupertinoTextField>(fieldFinder);
    expect(textField.controller?.text, '1.234');
    expect(intFormState.read(intAttribute), 1234);

    final doubleAttribute = DraftModeEntityAttribute<double>(null);

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          child: DraftModeFormField<double>(attribute: doubleAttribute),
        ),
      ),
    );

    await tester.enterText(fieldFinder, '12,5'); // decimal comma stays visible
    await tester.pump();

    textField = tester.widget<CupertinoTextField>(fieldFinder);
    expect(textField.controller?.text, '12,5');

    final doubleFormState = tester.state<DraftModeFormState>(
      find.byType(DraftModeForm),
    );
    expect(doubleFormState.read(doubleAttribute), 12.5);

    await tester.enterText(fieldFinder, '1234567,89');
    await tester.pump();

    textField = tester.widget<CupertinoTextField>(fieldFinder);
    expect(textField.controller?.text, '1.234.567,89');
    expect(doubleFormState.read(doubleAttribute), 1234567.89);
  });
}
