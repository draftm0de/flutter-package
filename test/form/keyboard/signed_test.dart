import 'package:draftmode/form/keyboard/signed.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DraftModeFormKeyBoardSigned', () {
    late FocusNode focusNode;
    late int toggleCount;

    setUp(() {
      focusNode = FocusNode();
      toggleCount = 0;
    });

    tearDown(() {
      focusNode.dispose();
    });

    Future<void> pumpKeyboard(WidgetTester tester, MediaQueryData media) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: MediaQuery(
            data: media,
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => DraftModeFormKeyBoardSigned(
                    focusNode: focusNode,
                    onToggleSign: () => toggleCount++,
                    child: CupertinoTextField(focusNode: focusNode),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('shows accessory bar when keyboard is visible', (tester) async {
      await pumpKeyboard(
        tester,
        const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 200)),
      );
      expect(find.text('±'), findsNothing);

      await tester.showKeyboard(find.byType(CupertinoTextField));
      await tester.pump();

      expect(find.text('±'), findsOneWidget);

      await tester.tap(find.text('±'));
      await tester.pump();
      expect(toggleCount, 1);

      await tester.tap(find.text('Done'));
      await tester.pump();
      expect(focusNode.hasFocus, isFalse);
      expect(find.text('±'), findsNothing);
    });

    testWidgets('does not render accessory when keyboard height is zero', (
      tester,
    ) async {
      await pumpKeyboard(tester, const MediaQueryData());

      await tester.showKeyboard(find.byType(CupertinoTextField));
      await tester.pump();

      expect(find.text('±'), findsNothing);
      expect(toggleCount, 0);
    });
  });
}
