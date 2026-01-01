import 'package:intl/intl.dart';

bool isReturnLate(String? returnDate, String? dueDate) {
  if (returnDate == null || dueDate == null) return false;
  try {
    final returned = DateTime.parse(returnDate);
    final due = DateTime.parse(dueDate);
    return returned.isAfter(due); // true kalau returnDate > dueDate
  } catch (e) {
    return false; // fallback kalau parsing gagal
  }
}

String formatTanggal(String? rawDate) {
  if (rawDate == null || rawDate.isEmpty) return '-';
  try {
    final date = DateTime.parse(
      rawDate,
    ); // pastikan rawDate format ISO: yyyy-MM-dd
    return DateFormat("d MMM yyyy", "id_ID").format(date);
  } catch (e) {
    return rawDate; // fallback kalau parsing gagal
  }
}

String formatTanggalDateTime(DateTime date) {
  return DateFormat("d MMM yyyy", "id_ID").format(date);
}
