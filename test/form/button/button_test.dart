import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:draftmode/form.dart';
import 'package:draftmode/platform/config.dart';
import 'package:draftmode/platform/styles.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.ios;
  });

  tearDown(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  testWidgets('invokes onPressed only when form validates', (tester) async {
    final formKey = GlobalKey<FormState>();
    var pressed = 0;
    var isValid = false;
    late StateSetter setState;

    await tester.pumpWidget(
      CupertinoApp(
        home: StatefulBuilder(
          builder: (context, setStateFn) {
            setState = setStateFn;
            return DraftModeForm(
              key: formKey,
              child: Column(
                children: [
                  FormField<bool>(
                    validator: (_) => isValid ? null : 'invalid',
                    builder: (field) => const SizedBox.shrink(),
                  ),
                  DraftModeFormButton(
                    content: const Text('Submit'),
                    formKey: formKey,
                    onPressed: () async => pressed++,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(pressed, 0);

    setState(() => isValid = true);
    await tester.pump();

    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(pressed, 1);
  });

  testWidgets('respects loadWidget result before running onPressed', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    var pressed = 0;

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          key: formKey,
          child: DraftModeFormButton(
            content: const Text('Open'),
            formKey: formKey,
            loadWidget: const _AutoPopPage(result: true),
            onPressed: () async => pressed++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(pressed, 1);

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          key: formKey,
          child: DraftModeFormButton(
            content: const Text('Open'),
            formKey: formKey,
            loadWidget: const _AutoPopPage(result: false),
            onPressed: () async => pressed++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(pressed, 1, reason: 'onPressed should not run when result is false');
  });

  testWidgets('builds Material button when platform forced to Android', (
    tester,
  ) async {
    PlatformConfig.mode = ForcedPlatform.android;

    await tester.pumpWidget(
      MaterialApp(
        home: DraftModeForm(
          child: DraftModeFormButton(
            content: const Text('Submit'),
            styleSize: DraftModeStyleButtonSize.large,
            stretched: true,
          ),
        ),
      ),
    );

    expect(find.byType(FilledButton), findsOneWidget);
    final filled = tester.widget<FilledButton>(find.byType(FilledButton));
    final style = filled.style;
    expect(style?.fixedSize?.resolve({})?.height, 48);
  });

  testWidgets('prints diagnostic when no action provided', (tester) async {
    final logs = <String?>[];
    final prior = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      logs.add(message);
    };

    await tester.pumpWidget(
      const CupertinoApp(home: DraftModeFormButton(content: Text('Noop'))),
    );

    await tester.tap(find.text('Noop'));
    await tester.pump();

    expect(logs.last, contains('no action provided'));
    debugPrint = prior;
  });
}

class _AutoPopPage extends StatefulWidget {
  final bool result;
  const _AutoPopPage({required this.result});

  @override
  State<_AutoPopPage> createState() => _AutoPopPageState();
}

class _AutoPopPageState extends State<_AutoPopPage> {
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      if (!mounted) return;
      Navigator.of(context).pop(widget.result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: SizedBox.shrink(),
    );
  }
}
