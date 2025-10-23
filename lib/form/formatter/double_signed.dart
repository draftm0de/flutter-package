import 'number.dart';

class DraftModeFormTypeDoubleSigned extends DraftModeFormTypeNumber<double> {
  DraftModeFormTypeDoubleSigned()
    : super(
        digits: 2,
        digitDelimiter: ",",
        thousandDelimiter: ".",
        signed: true,
      );
}
