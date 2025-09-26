import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:draftmode/entity.dart';
import 'package:draftmode/form.dart';

void main() {
  testWidgets('stores drafts and resets cleanly', (tester) async {
    final attribute = DraftModeEntityAttribute<String>(value: 'saved');
    final formKey = GlobalKey<DraftModeFormState>();

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          key: formKey,
          child: Builder(
            builder: (context) {
              final form = DraftModeFormState.of(context)!;
              form.registerProperty(attribute);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    final form = formKey.currentState!;
    expect(form.read<String>(attribute), isNull);

    form.updateProperty(attribute, 'draft');
    expect(form.read<String>(attribute), 'draft');

    form.reset();
    expect(form.read<String>(attribute), 'saved');
    expect(form.enableValidation, isFalse);

    form.validate();
    expect(form.enableValidation, isTrue);
  });

  testWidgets('registering and unregistering fields drives validation', (
    tester,
  ) async {
    final attribute = DraftModeEntityAttribute<String>();

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          child: DraftModeFormField<String>(
            key: const ValueKey('field'),
            element: attribute,
            label: 'Name',
          ),
        ),
      ),
    );

    final formContext = tester.element(find.byKey(const ValueKey('field')));
    final form = DraftModeFormState.of(formContext)!;

    final fieldState = tester.state<FormFieldState>(
      find.byWidgetPredicate((widget) => widget is FormField),
    );
    final fieldKey = fieldState.widget.key as GlobalKey<FormFieldState>;

    expect(() => form.validateAttribute(attribute), returnsNormally);
    form.unregisterField(attribute, fieldKey);
    form.validateAttribute(attribute);
  });
}
