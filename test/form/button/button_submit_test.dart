import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:draftmode/form.dart';
import 'package:draftmode/platform/config.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.ios;
  });

  tearDown(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  testWidgets('forwards submit styling to DraftModeFormButtonText', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    Future<void> onPressed() async {}

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeFormButtonSubmit(
          formKey: formKey,
          onPressed: onPressed,
          label: 'Save draft',
        ),
      ),
    );

    final button = tester.widget<DraftModeFormButtonText>(
      find.byType(DraftModeFormButtonText),
    );
    expect(button.formKey, same(formKey));
    expect(button.text, 'Save draft');
    expect(button.onPressed, same(onPressed));
    expect(button.styleSize, DraftModeFormButtonSize.large);
    expect(button.styleColor, DraftModeFormButtonColor.submit);
    expect(button.stretched, isTrue);
  });

  testWidgets('invokes onPressed only when form validates', (tester) async {
    final formKey = GlobalKey<FormState>();
    var pressed = 0;
    var isValid = false;
    late StateSetter setState;

    await tester.pumpWidget(
      CupertinoApp(
        home: StatefulBuilder(
          builder: (context, setStateFn) {
            setState = setStateFn;
            return DraftModeForm(
              key: formKey,
              child: Column(
                children: [
                  FormField<bool>(
                    validator: (_) => isValid ? null : 'invalid',
                    builder: (field) => const SizedBox.shrink(),
                  ),
                  DraftModeFormButtonSubmit(
                    formKey: formKey,
                    label: 'Submit',
                    onPressed: () async => pressed++,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(pressed, 0);

    setState(() => isValid = true);
    await tester.pump();

    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(pressed, 1);
  });
}
