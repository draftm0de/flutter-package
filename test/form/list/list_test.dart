import 'package:draftmode/element.dart';
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

class _OptionalListItem extends DraftModeListItem<String?> {
  final String label;

  _OptionalListItem(this.label);

  @override
  String? getId() => null;
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

class _OptionalTile extends DraftModeFormListItemWidget<_OptionalListItem> {
  const _OptionalTile({required super.item, required super.isSelected});

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

  testWidgets('invokes onRefresh when pulled down', (tester) async {
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
            onRefresh: () async {
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

  testWidgets('renders cupertino refresh control in cupertino apps', (
    tester,
  ) async {
    PlatformConfig.mode = ForcedPlatform.ios;

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeFormList<_ListItem, String>(
          items: [_ListItem('a', 'Alpha')],
          shrinkWrap: false,
          itemBuilder: (context, item, isSelected) =>
              _SimpleTile(item: item, isSelected: isSelected),
          onRefresh: () async {},
        ),
      ),
    );

    await tester.pump();

    expect(PlatformConfig.isIOS, isTrue);
    final refreshWrapper = tester.widget<DraftModeElementRefreshList>(
      find.byType(DraftModeElementRefreshList),
    );
    expect(refreshWrapper.list, isA<ListView>());
    final customScrollView = tester.widget<CustomScrollView>(
      find.byType(CustomScrollView),
    );
    expect(
      customScrollView.slivers.first,
      isA<CupertinoSliverRefreshControl>(),
    );
    expect(tester.takeException(), isNull);
    expect(
      find.byType(CupertinoSliverRefreshControl, skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('wraps items with dismissible configuration', (tester) async {
    final items = [_ListItem('a', 'Alpha')];
    final confirmCalls = <DismissDirection>[];
    final dismissedCalls = <DismissDirection>[];
    final confirmedItems = <DraftModeListItem<String>>[];
    final dismissedItems = <DraftModeListItem<String>>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraftModeFormList<_ListItem, String>(
            items: items,
            itemBuilder: (context, item, isSelected) =>
                _SimpleTile(item: item, isSelected: isSelected),
            dismissible: DraftModeFormListDismissible<_ListItem>(
              backgroundBuilder: (_, __) => const SizedBox.shrink(),
              secondaryBackgroundBuilder: (_, __) => const SizedBox.shrink(),
              confirmDismiss: (item, direction) async {
                confirmedItems.add(item);
                confirmCalls.add(direction);
                return true;
              },
              onDismissed: (item, direction) {
                dismissedItems.add(item);
                dismissedCalls.add(direction);
              },
            ),
          ),
        ),
      ),
    );

    final dismissibleFinder = find.byType(Dismissible);
    expect(dismissibleFinder, findsOneWidget);

    await tester.drag(find.text('Alpha'), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(confirmedItems.single, same(items.first));
    expect(confirmCalls.single, DismissDirection.endToStart);
    expect(dismissedItems.single, same(items.first));
    expect(dismissedCalls.single, DismissDirection.endToStart);
    expect(find.text('Alpha'), findsNothing);
  });

  testWidgets('uses ValueKey when list items provide an id', (tester) async {
    final item = _ListItem('a', 'Alpha');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraftModeFormList<_ListItem, String>(
            items: [item],
            itemBuilder: (context, item, isSelected) =>
                _SimpleTile(item: item, isSelected: isSelected),
            dismissible: const DraftModeFormListDismissible<_ListItem>(),
          ),
        ),
      ),
    );

    final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
    expect(dismissible.key, const ValueKey('a'));
  });

  testWidgets('falls back to ObjectKey when list item id is null', (
    tester,
  ) async {
    final item = _OptionalListItem('Transient');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraftModeFormList<_OptionalListItem, String?>(
            items: [item],
            itemBuilder: (context, item, isSelected) =>
                _OptionalTile(item: item, isSelected: isSelected),
            dismissible:
                const DraftModeFormListDismissible<_OptionalListItem>(),
          ),
        ),
      ),
    );

    final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
    expect(dismissible.key, ObjectKey(item));
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
            onRefresh: () async {},
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
