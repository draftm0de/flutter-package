import 'dart:async';

import 'package:draftmode/element.dart';
import 'package:draftmode/page/spinner.dart';
import 'package:draftmode/platform.dart';
import 'package:draftmode/ui.dart';
import 'package:flutter/widgets.dart';

import '../entity/interface.dart';
import 'interface.dart';

typedef DraftModeFormListConfirmDismiss<
  ItemType extends DraftModeEntityInterface<dynamic>
> = Future<bool?> Function(ItemType item, DismissDirection direction);

typedef DraftModeFormListDismissedCallback<
  ItemType extends DraftModeEntityInterface<dynamic>
> = void Function(ItemType item, DismissDirection direction);

/// Configuration object that controls how list items behave when wrapped in a
/// [Dismissible]. Most callers should prefer using one of the presets provided
/// in `package:draftmode/ui.dart` (e.g. [DraftModeUIDismissibleDelete]) instead
/// of instantiating this class directly.
class DraftModeFormListDismissible<
  ItemType extends DraftModeEntityInterface<dynamic>
> {
  final DismissDirection direction;
  final Widget? Function(BuildContext context, ItemType item)?
  backgroundBuilder;
  final Widget? Function(BuildContext context, ItemType item)?
  secondaryBackgroundBuilder;
  final DraftModeFormListConfirmDismiss<ItemType>? confirmDismiss;
  final DraftModeFormListDismissedCallback<ItemType>? onDismissed;
  final Key Function(ItemType item)? keyBuilder;

  const DraftModeFormListDismissible({
    this.direction = DismissDirection.endToStart,
    this.backgroundBuilder,
    this.secondaryBackgroundBuilder,
    this.confirmDismiss,
    this.onDismissed,
    this.keyBuilder,
  });
}

/// Adaptive list view that renders Draftmode entities within form layouts.
///
/// By default the list renders with [shrinkWrap] so callers can embed it within
/// another scroll view. Provide a controller or disable [shrinkWrap] to let it
/// scroll independently.
class DraftModeFormList<
  ItemType extends DraftModeEntityInterface<Identifier>,
  Identifier
>
    extends StatelessWidget {
  final bool isPending;
  final List<ItemType> items;
  final DraftModeFormListItemBuilder<ItemType> renderItem;
  final ItemType? selectedItem;
  final ValueChanged<ItemType>? onTap;
  final ValueChanged<ItemType>? onSelected;

  /// Optional widget rendered when [items] is empty. Defaults to an empty
  /// placeholder when omitted.
  final Widget? emptyPlaceholder;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool? primary;
  final Widget? header;
  final Widget? separator;
  final Future<void> Function()? onRefresh;
  final DraftModeFormListDismissible<ItemType>? dismissible;

  const DraftModeFormList({
    super.key,
    this.isPending = false,
    required this.items,
    required this.renderItem,
    this.selectedItem,
    this.onTap,
    this.onSelected,
    this.emptyPlaceholder,
    this.padding,
    this.shrinkWrap = true,
    this.physics,
    this.controller,
    this.primary,
    this.header,
    this.separator,
    this.onRefresh,
    this.dismissible,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (items.isEmpty) {
      final placeholder = (emptyPlaceholder == null)
          ? const SizedBox.shrink()
          : DraftModeUIRow(child: emptyPlaceholder!);
      content = _maybeWrapPlaceholder(context, placeholder);
    } else {
      final resolvedPadding = padding ?? _defaultPadding(context);
      final resolvedPhysics = _resolvePhysics();

      if (separator != null) {
        final listView = ListView.separated(
          controller: controller,
          primary: primary,
          shrinkWrap: shrinkWrap,
          physics: resolvedPhysics,
          padding: resolvedPadding,
          itemBuilder: (context, index) => _buildItem(context, items[index]),
          separatorBuilder: (context, index) => separator!,
          itemCount: items.length,
        );
        final Widget list = (onRefresh != null)
            ? DraftModeElementRefreshList(list: listView, onRefresh: onRefresh!)
            : listView;
        content = (header != null)
            ? Column(children: [header!, separator!, list])
            : list;
      } else {
        final listView = ListView.builder(
          controller: controller,
          primary: primary,
          shrinkWrap: shrinkWrap,
          physics: resolvedPhysics,
          padding: resolvedPadding,
          itemCount: items.length,
          itemBuilder: (context, index) => _buildItem(context, items[index]),
        );
        final Widget list = (onRefresh != null)
            ? DraftModeElementRefreshList(list: listView, onRefresh: onRefresh!)
            : listView;
        content = (header != null) ? Column(children: [header!, list]) : list;
      }
    }

    if (!isPending) {
      return content;
    }

    return Stack(
      children: [
        content,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                top: true,
                bottom: false,
                child: SizedBox(
                  width: double.infinity,
                  child: DraftModeUIRow(child: const DraftModePageSpinner()),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, ItemType item) {
    final selected = _isSelected(item);
    final widget = renderItem(item, selected);
    final highlighted = _maybeWrapWithSelectionOverlay(widget, selected);
    final wrapped = _maybeWrapWithDismissible(context, item, highlighted);
    final keyed = KeyedSubtree(key: _itemKey(item), child: wrapped);

    if (onTap == null && onSelected == null) {
      return keyed;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleTap(item, selected),
      child: keyed,
    );
  }

  bool _isSelected(ItemType item) {
    final selected = selectedItem;
    if (selected == null) {
      return false;
    }

    final selectedIdentifier = selected.getId();
    final itemIdentifier = item.getId();
    if (selectedIdentifier != null && itemIdentifier != null) {
      return selectedIdentifier == itemIdentifier;
    }

    return identical(selected, item);
  }

  Widget _maybeWrapWithSelectionOverlay(Widget child, bool isSelected) {
    if (!isSelected) {
      return child;
    }

    return Row(
      children: [
        Expanded(child: child),
        SizedBox(width: DraftModeStylePadding.tertiary),
        Icon(
          PlatformButtons.checked,
          color: DraftModeStyleColorTint.primary.background,
          size: 20,
        ),
      ],
    );
  }

  void _handleTap(ItemType item, bool isSelected) {
    onTap?.call(item);
    if (onSelected != null && !isSelected) {
      onSelected!(item);
    }
  }

  Widget _maybeWrapWithDismissible(
    BuildContext context,
    ItemType item,
    Widget child,
  ) {
    final config = dismissible;
    if (config == null) {
      return child;
    }

    final key = config.keyBuilder?.call(item) ?? _defaultDismissibleKey(item);
    final background = config.backgroundBuilder?.call(context, item);
    final secondaryBackground = config.secondaryBackgroundBuilder?.call(
      context,
      item,
    );
    final confirm = config.confirmDismiss;
    final dismissed = config.onDismissed;

    return Dismissible(
      key: key,
      direction: config.direction,
      background: background,
      secondaryBackground: secondaryBackground,
      confirmDismiss: (confirm == null)
          ? null
          : (direction) => confirm(item, direction),
      onDismissed: (dismissed == null)
          ? null
          : (direction) => dismissed(item, direction),
      child: child,
    );
  }

  Key _defaultDismissibleKey(ItemType item) {
    final id = item.getId();
    if (id == null) {
      return ObjectKey(item);
    }
    return ValueKey(id);
  }

  Key _itemKey(ItemType item) {
    final id = item.getId();
    if (id == null) {
      return ObjectKey(item);
    }
    return ValueKey(id);
  }

  Widget _maybeWrapPlaceholder(BuildContext context, Widget child) {
    if (onRefresh == null) {
      return child;
    }

    final resolvedPadding = padding ?? _defaultPadding(context);
    final physics = _resolvePhysics() ?? const AlwaysScrollableScrollPhysics();
    final list = ListView(
      controller: controller,
      primary: primary,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: resolvedPadding,
      children: [child],
    );

    return DraftModeElementRefreshList(list: list, onRefresh: onRefresh!);
  }

  ScrollPhysics? _resolvePhysics() {
    final basePhysics =
        physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null);

    if (onRefresh == null) {
      return basePhysics;
    }

    if (basePhysics == null) {
      return const AlwaysScrollableScrollPhysics();
    }

    if (basePhysics is NeverScrollableScrollPhysics) {
      return const AlwaysScrollableScrollPhysics();
    }

    return AlwaysScrollableScrollPhysics(parent: basePhysics);
  }

  EdgeInsetsGeometry _defaultPadding(BuildContext context) {
    if (DraftModeSectionScope.isInSection(context)) {
      return EdgeInsets.zero;
    }

    return EdgeInsets.symmetric(
      horizontal: DraftModeStylePadding.primary,
      vertical: DraftModeStylePadding.primary,
    );
  }
}
