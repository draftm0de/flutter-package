import 'package:draftmode/entity.dart';
import 'package:draftmode/form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DraftModeFormDependencyContext', () {
    testWidgets('revalidates dependents when source attribute changes', (
      tester,
    ) async {
      final source = DraftModeEntityAttribute<String>('initial');
      final dependent = DraftModeEntityAttribute<String>('value');

      var revalidated = 0;
      dependent.addValidator((context, form, value) {
        form?.read(source);
        revalidated++;
        return null;
      });

      await tester.pumpWidget(
        CupertinoApp(
          home: DraftModeForm(
            child: Column(
              children: [
                DraftModeFormField<String>(attribute: source),
                DraftModeFormField<String>(attribute: dependent),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      final formState = tester.state<DraftModeFormState>(
        find.byType(DraftModeForm),
      );

      revalidated = 0;
      formState.validateAttribute(dependent);
      expect(revalidated, 1);

      revalidated = 0;
      formState.updateProperty(source, 'updated');
      expect(revalidated, 1);
    });
  });
}
