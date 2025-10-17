import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//
import '../l10n/app_localizations.dart';
import '../platform/buttons.dart';
import '../platform/config.dart';
import '../platform/styles.dart';
import 'navigation/bottom.dart';
import 'navigation/bottom_item.dart';
import 'navigation/top.dart';
import 'navigation/top_item.dart';

/// Encapsulates shared scaffolding behaviour for DraftMode pages.
///
/// Provides platform-aware navigation bars, optional save/back handling, and a
/// bottom navigation container. Business logic should be provided via callbacks
/// and injected widgets to keep this component purely presentational.
class DraftModePage extends StatelessWidget {
  /// Default placeholder used when the caller does not specify a leading widget.
  static const Widget defaultLeading = SizedBox.shrink();

  /// Title displayed in the navigation bar.
  final String? navigationTitle;

  /// Fallback label for the back button on iOS when [topLeading] is not
  /// provided.
  final String? topLeadingText;

  /// Custom leading widget; falls back to a platform back button.
  final Widget? topLeading;

  /// Widgets displayed on the right side of the navigation bar.
  final List<DraftModePageNavigationTopItem>? topTrailing;

  /// Widgets anchored to the left side of the bottom bar.
  final List<DraftModePageNavigationBottomItem>? bottomLeading;

  final DraftModePageNavigationBottomItem? bottomCenter;

  /// Widgets anchored to the right side of the bottom bar.
  final List<DraftModePageNavigationBottomItem>? bottomTrailing;

  /// Main content of the page.
  final Widget body;

  /// Optional callback invoked when the save action is triggered; returning
  /// `true` pops the page with a positive result.
  final Future<bool> Function()? onSavePressed;

  /// Horizontal padding applied around [body].
  final double? horizontalContainerPadding;

  /// Vertical padding applied around [body].
  final double? verticalContainerPadding;

  /// Overrides the default background colour.
  final Color? containerBackgroundColor;

  const DraftModePage({
    super.key,
    required this.body,
    this.navigationTitle,
    this.topLeadingText,
    this.topLeading = defaultLeading,
    this.topTrailing,
    this.bottomLeading,
    this.bottomCenter,
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

    Future<void> handleSavePressed() async {
      final bool? success = await onSavePressed?.call();
      if (success == true) await btnBackPressed(result: true);
    }

    Widget? topLeadingElement;
    if (topLeading == defaultLeading) {
      topLeadingElement = DraftModePageNavigationTopItem(
        text: PlatformConfig.isIOS
            ? (topLeadingText ??
                  DraftModeLocalizations.of(context)?.navigationBtnBack ??
                  'Back')
            : null,
        icon: PlatformButtons.back,
        onTap: btnBackPressed,
      );
    } else {
      topLeadingElement = topLeading;
    }

    final List<Widget> automaticTrailing = onSavePressed != null
        ? [
            DraftModePageNavigationTopItem(
              text: PlatformConfig.isIOS
                  ? (DraftModeLocalizations.of(context)?.navigationBtnSave ??
                        'Ready')
                  : null,
              icon: PlatformConfig.isIOS ? null : PlatformButtons.save,
              onTap: handleSavePressed,
            ),
          ]
        : const [];

    final navigationTop = DraftModePageNavigationTop(
      title: navigationTitle,
      leading: topLeadingElement,
      trailing: topTrailing ?? automaticTrailing,
    );

    final navigationBottom =
        (bottomLeading?.isNotEmpty == true ||
            bottomTrailing?.isNotEmpty == true ||
            bottomCenter != null)
        ? DraftModePageNavigationBottom(
            leading: bottomLeading,
            primary: bottomCenter,
            trailing: bottomTrailing,
          )
        : null;

    final Widget content = (navigationBottom == null)
        ? body
        : Stack(
            children: [
              Positioned.fill(child: body),
              Align(alignment: Alignment.bottomCenter, child: navigationBottom),
            ],
          );

    final Color background =
        containerBackgroundColor ??
        PlatformStyles.containerBackgroundColor(context);

    return PlatformConfig.isIOS
        ? CupertinoPageScaffold(
            backgroundColor: background,
            navigationBar: navigationTop,
            child: SafeArea(top: false, child: content),
          )
        : Scaffold(
            appBar: navigationTop,
            backgroundColor: background,
            body: content,
          );
  }
}
