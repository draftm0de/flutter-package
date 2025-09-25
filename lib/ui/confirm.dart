import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as m;
import '../l10n/app_localizations.dart';
import '../platform/config.dart';

/// Platform-aware confirmation dialog that falls back to sensible defaults.
class DraftModeUIConfirm extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  const DraftModeUIConfirm({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
  });

  /// Displays the dialog using Cupertino styling on iOS and returns the choice.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool? barrierDismissible,
  }) async {
    return showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible ?? false,
      builder: (_) => DraftModeUIConfirm(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
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

    if (PlatformConfig.isIOS) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(cancelBtn),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
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
        m.TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: m.Text(cancelBtn),
        ),
        m.TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: m.Text(confirmBtn),
        ),
      ],
    );
  }
}
