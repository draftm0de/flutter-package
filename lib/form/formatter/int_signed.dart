import 'number.dart';

class DraftModeFormTypeIntSigned extends DraftModeFormTypeNumber<int> {
  DraftModeFormTypeIntSigned()
    : super(
        digits: 0,
        digitDelimiter: null,
        thousandDelimiter: ".",
        signed: true,
      );
}
