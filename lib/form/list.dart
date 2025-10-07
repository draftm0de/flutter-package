import 'package:draftmode/ui.dart';
import 'package:flutter/widgets.dart';

import '../entity/interface.dart';
import '../platform/styles.dart';

/// Signature for widgets rendered by [DraftModeFormList]. Implementations must
/// expose the underlying list [item] and whether it is currently selected so
/// parent widgets can remain stateless.
typedef DraftModeFormListItemWidgetBuilder<
  ItemType extends DraftModeListItem<dynamic>
> =
    DraftModeFormListItemWidget<ItemType> Function(
      BuildContext context,
      ItemType item,
      bool isSelected,
    );

/// Base widget that renders an individual item within [DraftModeFormList].
///
/// Consumers should extend this class so the constructor requires both the
/// [item] and [isSelected] flag.
abstract class DraftModeFormListItemWidget<
  ItemType extends DraftModeListItem<dynamic>
>
    extends StatelessWidget {
  final ItemType item;
  final bool isSelected;

  const DraftModeFormListItemWidget({
    super.key,
    required this.item,
    required this.isSelected,
  });
}

/// Adaptive list view that renders Draftmode entities within form layouts.
///
/// By default the list renders with [shrinkWrap] so callers can embed it within
/// another scroll view. Provide a controller or disable [shrinkWrap] to let it
/// scroll independently.
class DraftModeFormList<
  ItemType extends DraftModeListItem<Identifier>,
  Identifier
>
    extends StatelessWidget {
  final List<ItemType> items;
  final DraftModeFormListItemWidgetBuilder<ItemType> itemBuilder;
  final Identifier? selectedId;
  final ValueChanged<ItemType>? onTap;
  final ValueChanged<ItemType>? onSelected;
  final String? emptyPlaceholder;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool? primary;
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  const DraftModeFormList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.selectedId,
    this.onTap,
    this.onSelected,
    this.emptyPlaceholder,
    this.padding,
    this.shrinkWrap = true,
    this.physics,
    this.controller,
    this.primary,
    this.separatorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return (emptyPlaceholder == null)
          ? const SizedBox.shrink()
          : DraftModeUIRow(child: Text(emptyPlaceholder!));
    }

    final resolvedPadding = padding ?? _defaultPadding(context);
    final resolvedPhysics =
        physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null);

    if (separatorBuilder != null) {
      return ListView.separated(
        controller: controller,
        primary: primary,
        shrinkWrap: shrinkWrap,
        physics: resolvedPhysics,
        padding: resolvedPadding,
        itemBuilder: (context, index) => _buildItem(context, items[index]),
        separatorBuilder: (context, index) => separatorBuilder!(context, index),
        itemCount: items.length,
      );
    }

    return ListView.builder(
      controller: controller,
      primary: primary,
      shrinkWrap: shrinkWrap,
      physics: resolvedPhysics,
      padding: resolvedPadding,
      itemCount: items.length,
      itemBuilder: (context, index) => _buildItem(context, items[index]),
    );
  }

  Widget _buildItem(BuildContext context, ItemType item) {
    final selected = selectedId != null && item.getId() == selectedId;
    final widget = itemBuilder(context, item, selected);
    final keyed = KeyedSubtree(key: ValueKey(item.getId()), child: widget);

    if (onTap == null && onSelected == null) {
      return keyed;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleTap(item, selected),
      child: keyed,
    );
  }

  void _handleTap(ItemType item, bool isSelected) {
    onTap?.call(item);
    if (onSelected != null && !isSelected) {
      onSelected!(item);
    }
  }

  EdgeInsetsGeometry _defaultPadding(BuildContext context) {
    if (DraftModeSectionScope.isInSection(context)) {
      return EdgeInsets.zero;
    }

    return EdgeInsets.symmetric(
      horizontal: PlatformStyles.horizontalContainerPadding,
      vertical: PlatformStyles.verticalContainerPadding,
    );
  }
}
