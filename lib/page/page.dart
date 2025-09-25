import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//
import '../platform/config.dart';
import '../platform/buttons.dart';
import '../l10n/app_localizations.dart';
import 'navigation/top_item.dart';
import 'navigation/top.dart';
import 'navigation/bottom_item.dart';
import 'navigation/bottom.dart';

class DraftModePage extends StatelessWidget {
  static const Widget defaultLeading = SizedBox.shrink();
  final String? navigationTitle;
  final String? topLeadingText;
  final Widget? topLeading;
  final List<DraftModePageNavigationTopItem>? topTrailing;
  final List<DraftModePageNavigationBottomItem>? bottomLeading;
  final List<DraftModePageNavigationBottomItem>? bottomTrailing;
  final Widget body;
  final Future<bool> Function()? onSavePressed;
  final double? horizontalContainerPadding;
  final double? verticalContainerPadding;
  final Color? containerBackgroundColor;

  const DraftModePage({
    super.key,
    required this.body,
    this.navigationTitle,
    this.topLeadingText,
    this.topLeading = defaultLeading,
    this.topTrailing,
    this.bottomLeading,
    this.bottomTrailing,
    this.onSavePressed,
    this.horizontalContainerPadding,
    this.verticalContainerPadding,
    this.containerBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> btnBackPressed({bool? result}) async {
      final nav = Navigator.of(context);
      if (nav.canPop()) {
        nav.pop<bool?>(result);
      }
    }

    Future<void> btnSavePressed() async {
      final success = await onSavePressed?.call();
      if (success == true) {
        await btnBackPressed(result: true);
      }
    }

    Widget? topLeadingElement;
    if (topLeading == defaultLeading) {
      topLeadingElement = DraftModePageNavigationTopItem(
        text: (PlatformConfig.isIOS) ? (topLeadingText ?? DraftModeLocalizations.of(context)?.navigationBtnBack ?? 'Back') : null,
        icon: PlatformButtons.back,
        onTap: btnBackPressed
      );
    } else {
      topLeadingElement = topLeading;
    }
    
    final List<Widget> topTrailingElements = onSavePressed != null ?
      [
        DraftModePageNavigationTopItem(
          text: (PlatformConfig.isIOS) ? (DraftModeLocalizations.of(context)?.navigationBtnSave ?? 'Ready') : null,
          icon: (PlatformConfig.isIOS) ? null : PlatformButtons.save,
          onTap: btnSavePressed,
        )
      ]
      : topTrailing ?? [] ;

    final navigationTop = DraftModePageNavigationTop(
      title: navigationTitle,
      leading: topLeadingElement,
      trailing: topTrailing ?? topTrailingElements
    );

    final navigationBottom = (bottomLeading != null || bottomTrailing != null) ?
        DraftModePageNavigationBottom(
          leading: bottomLeading,
          trailing: bottomTrailing,
        ) : null;

    final Widget pageContent = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalContainerPadding ?? 0,
          vertical: verticalContainerPadding ??  0,
        ),
        child: body
    );

    final Widget content = (navigationBottom == null) ? pageContent : Stack(
      children: [
        Positioned.fill(
          child: pageContent
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: navigationBottom
        )
      ]
    );
    
    return PlatformConfig.isIOS
        ? CupertinoPageScaffold(
      backgroundColor: containerBackgroundColor ?? PlatformConfig.containerBackgroundColor(context),
      navigationBar: navigationTop as ObstructingPreferredSizeWidget?,
      child: SafeArea(
        top: false,
        child: content
      ),
    ) : Scaffold(
        appBar: navigationTop as PreferredSizeWidget?,
        backgroundColor: containerBackgroundColor ?? PlatformConfig.containerBackgroundColor(context),
        body: content
    );
  }
}
