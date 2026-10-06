import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );

  static void i(String message) {
    if (kDebugMode) _logger.i(message);
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void d(String message) {
    if (kDebugMode) _logger.d(message);
  }

  static void w(String message) {
    if (kDebugMode) _logger.w(message);
  }
}
