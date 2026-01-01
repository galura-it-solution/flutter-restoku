import 'package:flutter/widgets.dart';

class Initializer {
  static Future<void> init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
    } catch (err) {
      rethrow;
    }
  }
}
