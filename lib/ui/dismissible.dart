import 'package:flutter/material.dart';

import '../entity/interface.dart';
import '../form/list.dart';
import '../l10n/app_localizations.dart';
import '../platform/styles.dart';

/// Preset dismissible configuration that shows a destructive action background
/// and invokes [onDelete] when the user swipes the item from end-to-start.
///
/// Callers only need to provide the delete callback – the visual treatment and
/// interaction wiring are handled internally so feature code can stay focused
/// on business logic instead of UI plumbing.
class DraftModeUIDismissibleDelete<
  ItemType extends DraftModeEntityInterface<dynamic>
>
    extends DraftModeFormListDismissible<ItemType> {
  /// [onDelete] should return `true` when the swipe can complete. Returning
  /// `false` restores the item without triggering the dismissal animation.
  DraftModeUIDismissibleDelete({
    required Future<bool> Function(ItemType item) onDelete,
    Key Function(ItemType item)? keyBuilder,
    String? label,
    IconData icon = Icons.delete,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    double spacing = 8,
  }) : super(
         direction: DismissDirection.endToStart,
         keyBuilder: keyBuilder,
         backgroundBuilder: (_, __) => const SizedBox.shrink(),
         secondaryBackgroundBuilder: (context, _) =>
             _DraftModeUIDismissibleDeleteBackground(
               icon: icon,
               label:
                   label ??
                   DraftModeLocalizations.of(context)?.dialogBtnDelete ??
                   'Delete',
               backgroundColor: backgroundColor,
               foregroundColor: foregroundColor,
               padding:
                   padding ??
                   EdgeInsets.symmetric(
                     horizontal: DraftModeStylePadding.primary,
                   ),
               spacing: spacing,
             ),
         confirmDismiss: (item, direction) {
           if (direction != DismissDirection.endToStart) {
             return Future.value(false);
           }
           return onDelete(item);
         },
       );
}

class _DraftModeUIDismissibleDeleteBackground extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const _DraftModeUIDismissibleDeleteBackground({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.padding,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        backgroundColor ?? DraftModeStyleColorTint.secondary.background;
    final fgColor = foregroundColor ?? DraftModeStyleColorTint.secondary.text;

    return Container(
      alignment: Alignment.centerRight,
      padding: padding,
      color: bgColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fgColor),
          SizedBox(width: spacing),
          Text(
            label,
            style: TextStyle(color: fgColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
