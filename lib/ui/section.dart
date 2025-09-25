import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/config.dart';

class DraftModeUISection extends StatelessWidget {
  final String? header;
  final List<Widget> children;
  final bool transparent;

  const DraftModeUISection({
    super.key,
    this.header,
    required this.children,
    this.transparent = false
  });

  @override
  Widget build(BuildContext context) {
    final bool hasHeader = header != null;

    return DraftModeUISectionContext(
      child: PlatformConfig.isIOS
          ? CupertinoFormSection.insetGrouped(
              decoration: transparent ? BoxDecoration(
                color: null
              ) : null,
              header: hasHeader ? Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: PlatformConfig.horizontalContainerPadding
                  ),
                  child: Text(header ?? '')
              ) : null,
              children: children,
            )
          : Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
              //elevation: 4.0,
              child: Padding(
                padding: EdgeInsets.zero, // Inset padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasHeader) Padding(
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

class DraftModeUISectionContext extends InheritedWidget {
  const DraftModeUISectionContext({super.key, required super.child});

  static bool isInSection(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DraftModeUISectionContext>() !=
        null;
  }

  static EdgeInsetsGeometry get containerPadding =>
      EdgeInsets.symmetric(horizontal: 20);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
