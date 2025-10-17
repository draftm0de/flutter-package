import 'package:draftmode/utils/logger.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DraftModeLogger', () {
    test('emits messages when debugMode is true', () {
      String? captured;
      final original = foundation.debugPrint;

      foundation.debugPrint = (String? message, {int? wrapWidth}) {
        captured = message;
      };

      const logger = DraftModeLogger(debugMode: true);

      logger.debug('hello', {'id': 42});

      expect(captured, 'hello: {id: 42}');

      foundation.debugPrint = original;
    });

    test('suppresses messages when debugMode is false', () {
      String? captured;
      final original = foundation.debugPrint;

      foundation.debugPrint = (String? message, {int? wrapWidth}) {
        captured = message;
      };

      const logger = DraftModeLogger(debugMode: false);

      logger.debug('ignored', 'payload');

      expect(captured, isNull);

      foundation.debugPrint = original;
    });

    test('prints payload when message is empty', () {
      String? captured;
      final original = foundation.debugPrint;

      foundation.debugPrint = (String? message, {int? wrapWidth}) {
        captured = message;
      };

      const logger = DraftModeLogger(debugMode: true);

      logger.debug('', 'only payload');

      expect(captured, 'only payload');

      foundation.debugPrint = original;
    });
  });
}
