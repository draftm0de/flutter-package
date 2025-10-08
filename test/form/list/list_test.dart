import 'package:draftmode/entity.dart';
import 'package:draftmode/form.dart';
import 'package:draftmode/page/spinner.dart';
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
          emptyPlaceholder: const Text('Nothing here'),
        ),
      ),
    );

    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('builds separators when separator widget supplied', (
    tester,
  ) async {
    final items = [_ListItem('a', 'Alpha'), _ListItem('b', 'Beta')];

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeFormList<_ListItem, String>(
          items: items,
          itemBuilder: (context, item, isSelected) =>
              _SimpleTile(item: item, isSelected: isSelected),
          separator: Container(
            key: const ValueKey('separator'),
            height: 1,
            color: const Color(0xFFCCCCCC),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('separator')), findsNWidgets(1));
  });

  testWidgets('invokes onReload when pulled down', (tester) async {
    int reloadCount = 0;
    final items = [_ListItem('a', 'Alpha'), _ListItem('b', 'Beta')];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraftModeFormList<_ListItem, String>(
            items: items,
            shrinkWrap: false,
            itemBuilder: (context, item, isSelected) =>
                _SimpleTile(item: item, isSelected: isSelected),
            onReload: () async {
              reloadCount += 1;
            },
          ),
        ),
      ),
    );

    final refreshFinder = find.byType(RefreshIndicator);

    await tester.drag(refreshFinder, const Offset(0, 250));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(reloadCount, 1);
  });

  testWidgets('adds material localizations automatically in cupertino apps', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeFormList<_ListItem, String>(
          items: [_ListItem('a', 'Alpha')],
          shrinkWrap: false,
          itemBuilder: (context, item, isSelected) =>
              _SimpleTile(item: item, isSelected: isSelected),
          onReload: () async {},
        ),
      ),
    );

    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('pending spinner remains pinned while content scrolls', (
    tester,
  ) async {
    final items = List.generate(
      20,
      (index) => _ListItem('$index', 'Item $index'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraftModeFormList<_ListItem, String>(
            items: items,
            shrinkWrap: false,
            itemBuilder: (context, item, isSelected) =>
                _SimpleTile(item: item, isSelected: isSelected),
            onReload: () async {},
            isPending: true,
          ),
        ),
      ),
    );

    await tester.pump();

    final spinnerFinder = find.byType(DraftModePageSpinner);
    final listFinder = find.byType(ListView);

    expect(spinnerFinder, findsOneWidget);
    expect(
      find.ancestor(of: spinnerFinder, matching: find.byType(Stack)),
      findsOneWidget,
    );

    final initialTop = tester.getTopLeft(spinnerFinder);

    await tester.drag(listFinder, const Offset(0, 200));
    await tester.pump();

    final afterDragTop = tester.getTopLeft(spinnerFinder);

    expect(afterDragTop, initialTop);
  });
}
