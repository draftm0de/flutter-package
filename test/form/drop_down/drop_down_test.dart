import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:draftmode/entity.dart';
import 'package:draftmode/form.dart';
import 'package:draftmode/platform/config.dart';

class _TestItem extends DraftModeEntityInterface<String> {
  final String id;
  final String label;
  _TestItem(this.id, this.label);

  @override
  String getId() => id;
}

class _Tile extends DraftModeFormListItemWidget<_TestItem> {
  const _Tile({required super.item, required super.isSelected});

  @override
  Widget build(BuildContext context) => Text(item.label);
}

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.ios;
  });

  tearDown(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  testWidgets('shows selection page and updates attribute', (tester) async {
    final attribute = DraftModeEntityAttribute<String>(null);
    final items = <_TestItem>[_TestItem('a', 'Alpha'), _TestItem('b', 'Beta')];

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          child: DraftModeFormDropDown<_TestItem, String>(
            items: items,
            attribute: attribute,
            placeholder: 'Pick one',
            label: 'Choice',
            selectionTitle: 'Choose option',
            renderItem: (item, selected) =>
                _Tile(item: item, isSelected: selected),
          ),
        ),
      ),
    );

    expect(find.text('Pick one'), findsOneWidget);

    await tester.tap(find.text('Pick one'));
    await tester.pumpAndSettle();

    expect(find.text('Choose option'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.back), findsOneWidget);
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();

    final formState = tester.state<DraftModeFormState>(
      find.byType(DraftModeForm),
    );
    expect(formState.read(attribute), 'b');
    expect(find.text('Beta'), findsWidgets);
  });

  testWidgets('respects readOnly flag', (tester) async {
    final attribute = DraftModeEntityAttribute<String>(null);
    final items = <_TestItem>[_TestItem('a', 'Alpha')];

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          child: DraftModeFormDropDown<_TestItem, String>(
            items: items,
            attribute: attribute,
            placeholder: 'Read only',
            label: 'Choice',
            readOnly: true,
            renderItem: (item, selected) =>
                _Tile(item: item, isSelected: selected),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Read only'));
    await tester.pumpAndSettle();
    expect(find.text('Choice'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);
  });
}
