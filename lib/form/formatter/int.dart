import 'number.dart';

class DraftModeFormTypeInt extends DraftModeFormTypeNumber<int> {
  DraftModeFormTypeInt()
    : super(
        digits: 0,
        digitDelimiter: null,
        thousandDelimiter: null,
        signed: false,
      );
}
