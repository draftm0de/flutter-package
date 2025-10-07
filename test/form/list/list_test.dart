import 'package:draftmode/entity.dart';
import 'package:draftmode/form.dart';
import 'package:draftmode/platform/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ListItem extends DraftModeListItem<String> {
  final String id;
  final String label;

  _ListItem(this.id, this.label);

  @override
  String getId() => id;
}

class _ListTile extends DraftModeFormListItemWidget<_ListItem> {
  const _ListTile({required super.item, required super.isSelected});

  @override
  Widget build(BuildContext context) {
    return Text(isSelected ? '${item.label} (selected)' : item.label);
  }
}

class _SimpleTile extends DraftModeFormListItemWidget<_ListItem> {
  const _SimpleTile({required super.item, required super.isSelected});

  @override
  Widget build(BuildContext context) => Text(item.label);
}

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  tearDown(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  testWidgets('passes selection state to the item widget', (tester) async {
    final items = [_ListItem('a', 'Alpha'), _ListItem('b', 'Beta')];

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeFormList<_ListItem, String>(
          items: items,
          selectedId: 'b',
          itemBuilder: (context, item, isSelected) =>
              _ListTile(item: item, isSelected: isSelected),
        ),
      ),
    );

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta (selected)'), findsOneWidget);
  });

  testWidgets('invokes onTap when tapping an item', (tester) async {
    _ListItem? tapped;
    final items = [_ListItem('a', 'Alpha')];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraftModeFormList<_ListItem, String>(
            items: items,
            itemBuilder: (context, item, isSelected) =>
                _SimpleTile(item: item, isSelected: isSelected),
            onTap: (item) => tapped = item,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Alpha'));
    await tester.pump();

    expect(tapped, isNotNull);
    expect(tapped!.id, 'a');
  });

  testWidgets('invokes onSelected only when selection changes', (tester) async {
    _ListItem? selected;
    final items = [_ListItem('a', 'Alpha'), _ListItem('b', 'Beta')];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraftModeFormList<_ListItem, String>(
            items: items,
            selectedId: 'a',
            itemBuilder: (context, item, isSelected) =>
                _SimpleTile(item: item, isSelected: isSelected),
            onSelected: (item) => selected = item,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(selected, isNull);

    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(selected?.id, 'b');
  });

  testWidgets('renders emptyPlaceholder when no items provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeFormList<_ListItem, String>(
          items: const [],
          itemBuilder: (context, item, isSelected) =>
              _SimpleTile(item: item, isSelected: isSelected),
          emptyPlaceholder: 'Nothing here',
        ),
      ),
    );

    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('builds separators when separatorBuilder supplied', (
    tester,
  ) async {
    final items = [_ListItem('a', 'Alpha'), _ListItem('b', 'Beta')];

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeFormList<_ListItem, String>(
          items: items,
          itemBuilder: (context, item, isSelected) =>
              _SimpleTile(item: item, isSelected: isSelected),
          separatorBuilder: (context, index) => Container(
            key: ValueKey('separator-$index'),
            height: 1,
            color: const Color(0xFFCCCCCC),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('separator-0')), findsOneWidget);
  });
}
