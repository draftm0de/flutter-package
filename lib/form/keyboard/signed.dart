import 'package:draftmode/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

class DraftModeFormKeyBoardSigned extends StatefulWidget {
  const DraftModeFormKeyBoardSigned({
    super.key,
    required this.focusNode,
    required this.child,
    required this.onToggleSign,
  });

  final FocusNode focusNode;
  final Widget child;
  final VoidCallback onToggleSign;

  @override
  State<DraftModeFormKeyBoardSigned> createState() =>
      _DraftModeFormKeyBoardSignedState();
}

class _DraftModeFormKeyBoardSignedState
    extends State<DraftModeFormKeyBoardSigned>
    with WidgetsBindingObserver {
  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    WidgetsBinding.instance.removeObserver(this);
    _remove();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _markNeedsBuild();
  }

  void _handleFocusChange() {
    if (widget.focusNode.hasFocus) {
      _insert();
    } else {
      _remove();
    }
  }

  void _insert() {
    if (_entry != null) return;
    final overlay = Overlay.of(context);

    _entry = OverlayEntry(
      builder: (ctx) {
        final rootCtx = overlay.context;
        final insets = MediaQuery.of(
          rootCtx,
        ).viewInsets.bottom; // keyboard height
        if (insets == 0) return const SizedBox.shrink();

        return Positioned(
          left: 0,
          right: 0,
          bottom: insets,
          child: SafeArea(
            top: false,
            child: _AccessoryBar(
              onToggleSign: widget.onToggleSign,
              onDone: () => widget.focusNode.unfocus(),
            ),
          ),
        );
      },
    );

    overlay.insert(_entry!);
  }

  void _remove() {
    _entry?.remove();
    _entry = null;
  }

  void _markNeedsBuild() {
    // Rebuild overlay when keyboard height changes
    _entry?.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _AccessoryBar extends StatelessWidget {
  const _AccessoryBar({required this.onToggleSign, required this.onDone});

  final VoidCallback onToggleSign;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        border: const Border(
          top: BorderSide(color: CupertinoColors.separator, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            onPressed: onToggleSign,
            child: const Text('±'),
          ),
          const Spacer(),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            onPressed: onDone,
            child: Text(
              DraftModeLocalizations.of(context)?.navigationBtnSave ?? 'Done',
            ),
          ),
        ],
      ),
    );
  }
}
