import 'dart:async';

import 'package:draftmode/page/spinner.dart';
import 'package:draftmode/ui.dart';
import 'package:flutter/material.dart'
    show MaterialLocalizations, RefreshIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalMaterialLocalizations, GlobalWidgetsLocalizations;

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
  final bool isPending;
  final List<ItemType> items;
  final DraftModeFormListItemWidgetBuilder<ItemType> itemBuilder;
  final Identifier? selectedId;
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
  final Future<void> Function()? onReload;

  const DraftModeFormList({
    super.key,
    this.isPending = false,
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
    this.header,
    this.separator,
    this.onReload,
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
        Widget list = ListView.separated(
          controller: controller,
          primary: primary,
          shrinkWrap: shrinkWrap,
          physics: resolvedPhysics,
          padding: resolvedPadding,
          itemBuilder: (context, index) => _buildItem(context, items[index]),
          separatorBuilder: (context, index) => separator!,
          itemCount: items.length,
        );
        list = _wrapWithRefreshIndicator(context, list);
        content = (header != null)
            ? Column(children: [header!, separator!, list])
            : list;
      } else {
        Widget list = ListView.builder(
          controller: controller,
          primary: primary,
          shrinkWrap: shrinkWrap,
          physics: resolvedPhysics,
          padding: resolvedPadding,
          itemCount: items.length,
          itemBuilder: (context, index) => _buildItem(context, items[index]),
        );
        list = _wrapWithRefreshIndicator(context, list);
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

  Widget _maybeWrapPlaceholder(BuildContext context, Widget child) {
    if (onReload == null) {
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

    return _wrapWithRefreshIndicator(context, list);
  }

  ScrollPhysics? _resolvePhysics() {
    final basePhysics =
        physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null);

    if (onReload == null) {
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

  Widget _wrapWithRefreshIndicator(BuildContext context, Widget child) {
    if (onReload == null) {
      return child;
    }

    Widget indicator = RefreshIndicator.adaptive(
      onRefresh: () => Future.sync(onReload!),
      child: child,
    );

    if (Localizations.of<MaterialLocalizations>(
          context,
          MaterialLocalizations,
        ) !=
        null) {
      return indicator;
    }

    return Localizations.override(
      context: context,
      delegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      child: indicator,
    );
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
