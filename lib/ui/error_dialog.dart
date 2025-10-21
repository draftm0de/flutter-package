import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as m;

import '../platform/config.dart';

/// Displays a single-action error dialog with platform-specific styling.
Future<void> DraftModeUIErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  if (PlatformConfig.isIOS) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        ],
      ),
    );
  }

  return m.showDialog<void>(
    context: context,
    builder: (_) => m.AlertDialog(
      title: m.Text(title),
      content: m.Text(message),
      actions: [
        m.TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
