import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/config.dart';
import 'button_spinner.dart';

enum DraftModeFromButtonSize { medium, large }

enum DraftModeFromButtonColor { dateTime, submit }

class DraftModeFormButton extends StatefulWidget {
  final Widget content;
  final StatefulWidget? loadWidget;
  final Future<void> Function()? onPressed;
  final bool extendIcon;
  final GlobalKey<FormState>? formKey;
  final DraftModeFromButtonSize? styleSize;
  final DraftModeFromButtonColor? styleColor;
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

  Future<void> _handlePressed(BuildContext context) async {
    if (_isPending) return;

    setState(() {
      _isPending = true;
    });

    try {
      if (widget.loadWidget != null) {
        final result = await Navigator.of(context).push<bool>(
          PlatformConfig.isIOS
              ? CupertinoPageRoute(builder: (_) => widget.loadWidget!)
              : MaterialPageRoute(builder: (_) => widget.loadWidget!),
        );
        // onTap callback for true
        if (result == true && widget.onPressed != null) {
          await widget.onPressed!();
        }
      } else if (widget.onPressed != null) {
        final isValid = widget.formKey?.currentState?.validate() ?? true;
        if (isValid) {
          widget.formKey?.currentState?.save();
          await widget.onPressed!();
        }
      } else {
        debugPrint('FormPageBuilder: no action provided');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPending = false;
        });
      }
    }
  }

  Widget iosButton() {
    CupertinoButtonSize styleSize;
    BorderRadius borderRadius;

    switch (widget.styleSize ?? DraftModeFromButtonSize.medium) {
      case DraftModeFromButtonSize.medium:
        styleSize = CupertinoButtonSize.medium;
        borderRadius = BorderRadius.circular(12);

      case DraftModeFromButtonSize.large:
        styleSize = CupertinoButtonSize.large;
        borderRadius = BorderRadius.circular(12);
    }

    Color color;
    switch (widget.styleColor ?? DraftModeFromButtonColor.submit) {
      case DraftModeFromButtonColor.dateTime:
        color = CupertinoColors.systemGrey5;

      case DraftModeFromButtonColor.submit:
        color = CupertinoColors.activeBlue;
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      sizeStyle: styleSize,
      borderRadius: borderRadius,
      color: color,
      onPressed: () => _isPending ? null : _handlePressed(context),
      child: _isPending
          ? DraftModeFormButtonSpinner(color: CupertinoColors.white)
          : widget.content,
    );
  }

  Widget materialButton() {
    double buttonSize;
    BorderRadius borderRadius;
    switch (widget.styleSize ?? DraftModeFromButtonSize.medium) {
      case DraftModeFromButtonSize.medium:
        buttonSize = 40;
        borderRadius = BorderRadius.circular(12);

      case DraftModeFromButtonSize.large:
        buttonSize = 48;
        borderRadius = BorderRadius.circular(12);
    }

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        fixedSize: Size.fromHeight(buttonSize),
      ),
      onPressed: () => _isPending ? null : _handlePressed(context),
      child: _isPending
          ? DraftModeFormButtonSpinner(color: CupertinoColors.white)
          : widget.content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget button = PlatformConfig.isIOS ? iosButton() : materialButton();
    late Widget content;
    if (widget.stretched) {
      content = SizedBox(width: double.infinity, child: button);
    } else {
      content = button;
    }
    return content;
  }
}
