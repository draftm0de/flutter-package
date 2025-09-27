import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;

import '../platform/config.dart';

/// Shared button sizing used by [DraftModeUIButton].
enum DraftModeUIButtonSize { medium, large }

/// Semantic palette applied to [DraftModeUIButton] variants.
enum DraftModeUIButtonColor { dateTime, submit }

/// Platform-aware button that mirrors native styling on iOS and Material.
///
/// Presentation belongs to the UI layer; calling code is responsible for
/// providing any domain behaviour such as form validation.
class DraftModeUIButton extends StatelessWidget {
  final Widget child;
  final Widget? pendingChild;
  final bool isPending;
  final VoidCallback? onPressed;
  final DraftModeUIButtonSize size;
  final DraftModeUIButtonColor color;
  final bool stretched;

  const DraftModeUIButton({
    super.key,
    required this.child,
    this.pendingChild,
    this.isPending = false,
    this.onPressed,
    this.size = DraftModeUIButtonSize.medium,
    this.color = DraftModeUIButtonColor.submit,
    this.stretched = false,
  });

  CupertinoButtonSize _resolveCupertinoSize() {
    switch (size) {
      case DraftModeUIButtonSize.large:
        return CupertinoButtonSize.large;
      case DraftModeUIButtonSize.medium:
        return CupertinoButtonSize.medium;
    }
  }

  double _resolveMaterialHeight() {
    switch (size) {
      case DraftModeUIButtonSize.large:
        return 48;
      case DraftModeUIButtonSize.medium:
        return 40;
    }
  }

  Color _resolveCupertinoColor() {
    switch (color) {
      case DraftModeUIButtonColor.dateTime:
        return CupertinoColors.systemGrey5;
      case DraftModeUIButtonColor.submit:
        return CupertinoColors.activeBlue;
    }
  }

  Widget _buildCupertino() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      sizeStyle: _resolveCupertinoSize(),
      borderRadius: BorderRadius.circular(12),
      color: _resolveCupertinoColor(),
      onPressed: isPending ? null : onPressed,
      child: isPending && pendingChild != null ? pendingChild! : child,
    );
  }

  Color _materialBackground(BuildContext context) {
    final scheme = material.Theme.of(context).colorScheme;
    switch (color) {
      case DraftModeUIButtonColor.dateTime:
        return scheme.surfaceContainerHighest;
      case DraftModeUIButtonColor.submit:
        return scheme.primary;
    }
  }

  Color _materialForeground(BuildContext context) {
    final scheme = material.Theme.of(context).colorScheme;
    switch (color) {
      case DraftModeUIButtonColor.dateTime:
        return scheme.onSurface;
      case DraftModeUIButtonColor.submit:
        return material.Colors.white;
    }
  }

  Widget _buildMaterial(BuildContext context) {
    final height = _resolveMaterialHeight();
    final baseStyle = material.FilledButton.styleFrom(
      backgroundColor: _materialBackground(context),
      foregroundColor: _materialForeground(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: Size(0, height),
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
    final style = stretched
        ? baseStyle.copyWith(
            fixedSize: WidgetStatePropertyAll(Size.fromHeight(height)),
          )
        : baseStyle;
    return material.FilledButton(
      style: style,
      onPressed: isPending ? null : onPressed,
      child: isPending && pendingChild != null ? pendingChild! : child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final button = PlatformConfig.isIOS
        ? _buildCupertino()
        : _buildMaterial(context);
    if (!stretched) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
