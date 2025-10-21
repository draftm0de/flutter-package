import 'package:flutter/cupertino.dart';

/// Displays a single-action Cupertino error dialog and resolves when dismissed.
Future<void> DraftModeUIErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
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
