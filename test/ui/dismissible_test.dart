import 'package:draftmode/entity.dart';
import 'package:draftmode/form.dart';
import 'package:draftmode/l10n/app_localizations.dart';
import 'package:draftmode/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ListItem extends DraftModeListItem<String> {
  _ListItem(this.id, this.label);

  final String id;
  final String label;

  @override
  String getId() => id;
}

class _DismissibleTile extends DraftModeFormListItemWidget<_ListItem> {
  const _DismissibleTile({required super.item, required super.isSelected});

  @override
  Widget build(BuildContext context) => Text(item.label);
}

void main() {
  DraftModeUIDismissibleDelete<_ListItem> _buildConfig({
    required Future<bool> Function(_ListItem item) onDelete,
  }) {
    return DraftModeUIDismissibleDelete<_ListItem>(onDelete: onDelete);
  }

  Widget _buildApp({
    Locale? locale,
    required DraftModeUIDismissibleDelete<_ListItem> dismissible,
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: DraftModeLocalizations.localizationsDelegates,
      supportedLocales: DraftModeLocalizations.supportedLocales,
      home: Scaffold(
        body: DraftModeFormList<_ListItem, String>(
          items: [_ListItem('a', 'Alpha')],
          itemBuilder: (context, item, isSelected) =>
              _DismissibleTile(item: item, isSelected: isSelected),
          dismissible: dismissible,
        ),
      ),
    );
  }

  testWidgets('uses english delete label in secondary background', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(dismissible: _buildConfig(onDelete: (_) async => false)),
    );

    final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
    final background = dismissible.secondaryBackground;
    expect(background, isNotNull);

    await tester.pumpWidget(
      Directionality(textDirection: TextDirection.ltr, child: background!),
    );

    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('uses german delete label when locale is de', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        locale: const Locale('de'),
        dismissible: _buildConfig(onDelete: (_) async => false),
      ),
    );

    final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
    final background = dismissible.secondaryBackground;
    expect(background, isNotNull);

    await tester.pumpWidget(
      Directionality(textDirection: TextDirection.ltr, child: background!),
    );

    expect(find.text('Löschen'), findsOneWidget);
  });

  testWidgets('invokes onDelete and removes the item when swipe completes', (
    tester,
  ) async {
    final calls = <String>[];

    await tester.pumpWidget(
      _buildApp(
        dismissible: _buildConfig(
          onDelete: (item) async {
            calls.add(item.id);
            return true;
          },
        ),
      ),
    );

    await tester.drag(find.text('Alpha'), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(calls, ['a']);
    expect(find.text('Alpha'), findsNothing);
  });

  testWidgets('restores the item when onDelete returns false', (tester) async {
    bool called = false;

    await tester.pumpWidget(
      _buildApp(
        dismissible: _buildConfig(
          onDelete: (item) async {
            called = true;
            return false;
          },
        ),
      ),
    );

    await tester.drag(find.text('Alpha'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(called, isTrue);
    expect(find.text('Alpha'), findsOneWidget);
  });
}
