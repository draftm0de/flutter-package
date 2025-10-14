import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show MaterialLocalizations, RefreshIndicator, RefreshIndicatorTriggerMode;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalMaterialLocalizations, GlobalWidgetsLocalizations;

import '../platform/config.dart';

class DraftModeElementRefreshList extends StatelessWidget {
  const DraftModeElementRefreshList({
    super.key,
    required this.list,
    required this.onRefresh,
  });

  final ScrollView list;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (PlatformConfig.isIOS && list is ListView) {
      final listView = list as ListView;
      final ScrollPhysics physics = BouncingScrollPhysics(
        parent: listView.physics ?? const AlwaysScrollableScrollPhysics(),
      );

      Widget sliver = SliverList(delegate: listView.childrenDelegate);

      final EdgeInsetsGeometry? padding = listView.padding;
      if (padding != null) {
        sliver = SliverPadding(padding: padding, sliver: sliver);
      }

      return CustomScrollView(
        scrollDirection: listView.scrollDirection,
        reverse: listView.reverse,
        controller: listView.controller,
        primary: listView.primary,
        physics: physics,
        shrinkWrap: listView.shrinkWrap,
        cacheExtent: listView.cacheExtent,
        semanticChildCount: listView.semanticChildCount,
        dragStartBehavior: listView.dragStartBehavior,
        keyboardDismissBehavior: listView.keyboardDismissBehavior,
        restorationId: listView.restorationId,
        clipBehavior: listView.clipBehavior,
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: onRefresh),
          sliver,
        ],
      );
    }

    final indicator = RefreshIndicator.adaptive(
      onRefresh: () => Future.sync(onRefresh),
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      child: list,
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
}
