import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform/config.dart';
import 'button_spinner.dart';

/// Available button sizes exposed by [DraftModeFormButton]. The medium variant
/// mirrors the default `CupertinoButton` height while the large variant offers
/// more comfortable tap targets for primary actions.
enum DraftModeFormButtonSize { medium, large }

/// Optional palette used by [DraftModeFormButton] to render contextual
/// variations (e.g. neutral time pickers vs. primary submit buttons).
enum DraftModeFormButtonColor { dateTime, submit }

/// Legacy alias maintained for backwards compatibility. Prefer
/// [DraftModeFormButtonSize].
@Deprecated('Use DraftModeFormButtonSize instead')
typedef DraftModeFromButtonSize = DraftModeFormButtonSize;

/// Legacy alias maintained for backwards compatibility. Prefer
/// [DraftModeFormButtonColor].
@Deprecated('Use DraftModeFormButtonColor instead')
typedef DraftModeFromButtonColor = DraftModeFormButtonColor;

/// Adaptive form button that understands Draftmode validation semantics. When
/// provided with a [formKey] it validates and saves before invoking
/// [onPressed]. Alternatively a modal [loadWidget] can be supplied to gather
/// additional input before triggering the action.
class DraftModeFormButton extends StatefulWidget {
  final Widget content;
  final Widget? loadWidget;
  final Future<void> Function()? onPressed;

  /// Retained for backwards compatibility; no longer used.
  @Deprecated('No longer has any effect')
  final bool extendIcon;

  final GlobalKey<FormState>? formKey;
  final DraftModeFormButtonSize? styleSize;
  final DraftModeFormButtonColor? styleColor;
  final bool stretched;

  const DraftModeFormButton({
    super.key,
    required this.content,
    this.loadWidget,
    this.onPressed,
    this.extendIcon = false,
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
        debugPrint('DraftModeFormButton: no action provided');
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

  CupertinoButtonSize _resolveCupertinoSize() {
    switch (_size) {
      case DraftModeFormButtonSize.large:
        return CupertinoButtonSize.large;
      case DraftModeFormButtonSize.medium:
        return CupertinoButtonSize.medium;
    }
  }

  double _resolveMaterialHeight() {
    switch (_size) {
      case DraftModeFormButtonSize.large:
        return 48;
      case DraftModeFormButtonSize.medium:
        return 40;
    }
  }

  Color _resolveCupertinoColor() {
    switch (_color) {
      case DraftModeFormButtonColor.dateTime:
        return CupertinoColors.systemGrey5;
      case DraftModeFormButtonColor.submit:
        return CupertinoColors.activeBlue;
    }
  }

  Widget _buildCupertinoButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      sizeStyle: _resolveCupertinoSize(),
      borderRadius: BorderRadius.circular(12),
      color: _resolveCupertinoColor(),
      onPressed: () => _isPending ? null : _handlePressed(context),
      child: _isPending
          ? const DraftModeFormButtonSpinner(color: CupertinoColors.white)
          : widget.content,
    );
  }

  Widget _buildMaterialButton() {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        fixedSize: Size.fromHeight(_resolveMaterialHeight()),
      ),
      onPressed: () => _isPending ? null : _handlePressed(context),
      child: _isPending
          ? const DraftModeFormButtonSpinner(color: CupertinoColors.white)
          : widget.content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final button = PlatformConfig.isIOS
        ? _buildCupertinoButton()
        : _buildMaterialButton();
    if (!widget.stretched) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
