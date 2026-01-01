import 'package:intl/intl.dart';

final NumberFormat _idrFormatter = NumberFormat.decimalPattern('id_ID');

String formatIdr(num value) {
  return _idrFormatter.format(value.round());
}
