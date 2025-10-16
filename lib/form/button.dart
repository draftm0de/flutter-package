import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform/config.dart';
import '../ui/button.dart';
import '../ui/diagnostics.dart';
import 'button_spinner.dart';

/// Available button sizes exposed by [DraftModeFormButton]. The medium variant
/// mirrors the default `CupertinoButton` height while the large variant offers
/// more comfortable tap targets for primary actions.
typedef DraftModeFormButtonSize = DraftModeUIButtonSize;

/// Optional palette used by [DraftModeFormButton] to render contextual
/// variations (e.g. neutral time pickers vs. primary submit buttons).
typedef DraftModeFormButtonColor = DraftModeUIButtonColor;

/// Adaptive form button that understands Draftmode validation semantics. When
/// provided with a [formKey] it validates and saves before invoking
/// [onPressed]. Alternatively a modal [loadWidget] can be supplied to gather
/// additional input before triggering the action.
class DraftModeFormButton extends StatefulWidget {
  final Widget content;
  final Widget? loadWidget;
  final Future<void> Function()? onPressed;

  final GlobalKey<FormState>? formKey;
  final DraftModeFormButtonSize? styleSize;
  final DraftModeFormButtonColor? styleColor;
  final bool stretched;

  const DraftModeFormButton({
    super.key,
    required this.content,
    this.loadWidget,
    this.onPressed,
    this.formKey,
    this.styleSize,
    this.styleColor,
    this.stretched = false,
  });

  @override
  State<DraftModeFormButton> createState() => _DraftModeFormButtonState();
}

class _DraftModeFormButtonState extends State<DraftModeFormButton> {
  bool _isPending = false;

  DraftModeFormButtonColor get _color =>
      widget.styleColor ?? DraftModeFormButtonColor.submit;

  DraftModeFormButtonSize get _size =>
      widget.styleSize ?? DraftModeFormButtonSize.medium;

  Future<void> _handlePressed(BuildContext context) async {
    if (_isPending) return;

    setState(() => _isPending = true);

    try {
      if (widget.loadWidget != null) {
        final result = await Navigator.of(context).push<bool>(
          PlatformConfig.isIOS
              ? CupertinoPageRoute(builder: (_) => widget.loadWidget!)
              : MaterialPageRoute(builder: (_) => widget.loadWidget!),
        );
        if (result == true && widget.onPressed != null) {
          await widget.onPressed!();
        }
        return;
      }

      if (widget.onPressed == null) {
        DraftModeUIDiagnostics.debug('DraftModeFormButton: no action provided');
        return;
      }

      final isValid = widget.formKey?.currentState?.validate() ?? true;
      if (!isValid) return;

      widget.formKey?.currentState?.save();
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => _isPending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraftModeUIButton(
      child: widget.content,
      pendingChild: const DraftModeFormButtonSpinner(
        color: CupertinoColors.white,
      ),
      isPending: _isPending,
      onPressed: () => _handlePressed(context),
      size: _size,
      color: _color,
      stretched: widget.stretched,
    );
  }
}
