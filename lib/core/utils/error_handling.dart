import 'package:logger/logger.dart';
import 'package:slims/config.dart';
import 'package:slims/core/utils/snackbar.dart';

class ErrorHandlingHelper {
  static Future<void> logAlertHandling(
    Object message,
    StackTrace stackTrace,
    bool showAlert,
  ) async {
    final env = ConfigEnvironments.getEnvironments()['env'];
    if (showAlert) {
      SnackbarUtils.showError(message: message.toString());
    }
    if (env == Environments.LOCAL) {
      Logger().w(message);
      Logger().w(stackTrace);
    }
  }
}
