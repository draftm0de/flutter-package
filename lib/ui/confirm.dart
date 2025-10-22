import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as m;
import '../l10n/app_localizations.dart';
import '../platform/config.dart';

enum DraftModeUIConfirmStyle { confirm, error }

/// Platform-aware confirmation dialog that falls back to sensible defaults.
///
/// The widget itself is stateless; prefer the static [show] helper to present
/// it and await the result. When custom labels are omitted the component uses
/// strings from [DraftModeLocalizations].
class DraftModeUIConfirm extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final DraftModeUIConfirmStyle mode;
  const DraftModeUIConfirm({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.mode = DraftModeUIConfirmStyle.confirm,
  });

  /// Displays the dialog using Cupertino styling on iOS and returns the choice.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool? barrierDismissible,
    DraftModeUIConfirmStyle mode = DraftModeUIConfirmStyle.confirm,
  }) async {
    final bool dismissible =
        barrierDismissible ?? (PlatformConfig.isIOS ? false : true);

    if (PlatformConfig.isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        barrierDismissible: dismissible,
        builder: (_) => DraftModeUIConfirm(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          mode: mode,
        ),
      );
    }

    return m.showDialog<bool>(
      context: context,
      barrierDismissible: dismissible,
      builder: (_) => DraftModeUIConfirm(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        mode: mode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String confirmBtn =
        confirmLabel ??
        DraftModeLocalizations.of(context)?.dialogBtnConfirm ??
        'OK';
    final String cancelBtn =
        cancelLabel ??
        DraftModeLocalizations.of(context)?.dialogBtnCancel ??
        'Cancel';
    final bool isError = mode == DraftModeUIConfirmStyle.error;
    final bool showCancelButton = !isError;

    if (PlatformConfig.isIOS) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          if (showCancelButton)
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(cancelBtn),
            ),
          CupertinoDialogAction(
            isDefaultAction: !isError,
            isDestructiveAction: isError,
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(confirmBtn),
          ),
        ],
      );
    }

    return m.AlertDialog(
      title: m.Text(title),
      content: m.Text(message),
      actions: [
        if (showCancelButton)
          m.TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: m.Text(cancelBtn),
          ),
        m.TextButton(
          style: isError
              ? m.TextButton.styleFrom(
                  foregroundColor: m.Theme.of(context).colorScheme.error,
                )
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: m.Text(confirmBtn),
        ),
      ],
    );
  }
}
