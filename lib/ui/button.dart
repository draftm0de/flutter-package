import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;

import '../platform/config.dart';
import '../platform/styles.dart';

/// Platform-aware button that mirrors native styling on iOS and Material.
///
/// Presentation belongs to the UI layer; calling code is responsible for
/// providing any domain behaviour such as form validation. Consumers can pass
/// the semantic sizing and colour roles defined in `DraftModeStyleButton*` to
/// keep CTA treatments consistent across the app.
class DraftModeUIButton extends StatelessWidget {
  final Widget child;
  final Widget? pendingChild;
  final bool isPending;
  final VoidCallback? onPressed;
  final DraftModeStyleButtonSizeRole? styleSize;
  final DraftModeStyleButtonColorRole? styleColor;
  final bool stretched;

  const DraftModeUIButton({
    super.key,
    required this.child,
    this.pendingChild,
    this.isPending = false,
    this.onPressed,
    this.styleSize,
    this.styleColor,
    this.stretched = false,
  });

  CupertinoButtonSize _resolveCupertinoSize() {
    if (styleSize == DraftModeStyleButtonSize.medium) {
      return CupertinoButtonSize.medium;
    }
    if (styleSize == DraftModeStyleButtonSize.small) {
      return CupertinoButtonSize.small;
    }
    return CupertinoButtonSize.large;
  }

  Color _resolveBackgroundColor() {
    return (styleColor != null)
        ? styleColor!.background
        : DraftModeStyleButtonColor.submit.background;
  }

  double _resolveHeight() {
    if (styleSize == DraftModeStyleButtonSize.medium) {
      return DraftModeStyleButtonSize.medium.height;
    }
    if (styleSize == DraftModeStyleButtonSize.small) {
      return DraftModeStyleButtonSize.small.height;
    }
    return DraftModeStyleButtonSize.large.height;
  }

  Widget _buildCupertino() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      sizeStyle: _resolveCupertinoSize(),
      borderRadius: BorderRadius.circular(12),
      color: _resolveBackgroundColor(),
      onPressed: isPending ? null : onPressed,
      child: isPending && pendingChild != null ? pendingChild! : child,
    );
  }

  Widget _buildMaterial(BuildContext context) {
    final height = _resolveHeight();
    final baseStyle = material.FilledButton.styleFrom(
      backgroundColor: _resolveBackgroundColor(),
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
