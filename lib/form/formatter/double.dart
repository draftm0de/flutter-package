import 'number.dart';

class DraftModeFormTypeDouble extends DraftModeFormTypeNumber<double> {
  DraftModeFormTypeDouble()
    : super(
        digits: 2,
        digitDelimiter: ",",
        thousandDelimiter: ".",
        signed: false,
      );
}
