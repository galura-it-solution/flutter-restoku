import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class DateHelper {
  static bool _initialized = false;

  static void init() {
    if (!_initialized) {
      tz.initializeTimeZones();
      _initialized = true;
    }
  }

  static String formatToWibIso(DateTime date) {
    init();
    final jakarta = tz.getLocation('Asia/Jakarta');
    final wibTime = tz.TZDateTime.from(date, jakarta);
    return wibTime.toIso8601String();
  }
}
