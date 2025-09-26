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

  testWidgets('toggles attribute when switched', (tester) async {
    final attribute = DraftModeEntityAttribute<bool>(value: false);
    final formKey = GlobalKey<DraftModeFormState>();

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          key: formKey,
          child: DraftModeFormSwitch(element: attribute, label: 'Enabled'),
        ),
      ),
    );

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pump();

    final formState = formKey.currentState!;
    expect(formState.read(attribute), isTrue);

    formState.save();
    expect(attribute.value, isTrue);
  });
}
