import 'package:draftmode/form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders three animated dots', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: DraftModeFormButtonSpinner(color: Colors.white)),
        ),
      ),
    );

    final containers = find.descendant(
      of: find.byType(DraftModeFormButtonSpinner),
      matching: find.byType(Container),
    );
    expect(containers.evaluate().length, 3);
  });
}
