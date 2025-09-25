import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/config.dart';

/// Groups related form rows into a platform-adaptive container.
///
/// On iOS this uses [CupertinoFormSection.insetGrouped]; on other platforms it
/// wraps content in a `Card`. The [transparent] flag disables the Cupertino
/// background decoration for sections that should visually blend with their
/// parents.
class DraftModeUISection extends StatelessWidget {
  final String? header;
  final List<Widget> children;
  final bool transparent;

  const DraftModeUISection({
    super.key,
    this.header,
    required this.children,
    this.transparent = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasHeader = header != null;

    return DraftModeSectionScope(
      child: PlatformConfig.isIOS
          ? CupertinoFormSection.insetGrouped(
              decoration: transparent ? BoxDecoration(color: null) : null,
              header: hasHeader
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: PlatformConfig.horizontalContainerPadding,
                      ),
                      child: Text(header ?? ''),
                    )
                  : null,
              children: children,
            )
          : Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasHeader)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 16.0,
                          top: 15.0,
                          left: 10.0,
                        ),
                        child: Text(header ?? ''),
                      ),
                    ...children,
                  ],
                ),
              ),
            ),
    );
  }
}

/// Exposes contextual hints for descendants rendered within a [DraftModeUISection].
///
/// Widgets can call [isInSection] to adjust layout or use [containerPadding] for
/// consistent horizontal padding when emulating section spacing.
class DraftModeSectionScope extends InheritedWidget {
  const DraftModeSectionScope({super.key, required super.child});

  static bool isInSection(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<DraftModeSectionScope>() !=
        null;
  }

  static EdgeInsetsGeometry get containerPadding =>
      const EdgeInsets.symmetric(horizontal: 20);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
