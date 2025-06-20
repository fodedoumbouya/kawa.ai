import 'package:logger/logger.dart';
import 'dart:developer';

/// A Logger For Flutter Apps
/// Usage:
/// 1) AppLog.i("Info Message");
/// 2) AppLog.i("Home Page", tag: "User Logging");
///
///

class DeveloperConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    final StringBuffer buffer = StringBuffer();
    event.lines.forEach(buffer.writeln);
    log(buffer.toString());
  }
}

class AppLog {
  static const String _DEFAULT_TAG_PREFIX = "Kawa";
  static final _logger = Logger(
    output: MultiOutput([
      // I have a file output here
      // if (Platform.isIOS)
      DeveloperConsoleOutput(),
    ]),
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      // colors: !Platform.isIOS, // Colors not working on iOS

      printEmojis: true,
      printTime: true,
    ),
  );

  static e(String msg) {
    _logger.e("$_DEFAULT_TAG_PREFIX: $msg");
  }

  /// Log a message at level [Level.info].
  static i(String msg) {
    _logger.i("$_DEFAULT_TAG_PREFIX: $msg");
  }

  /// Log a message at level [Level.debug].
  static d(String msg) {
    _logger.d("$_DEFAULT_TAG_PREFIX: $msg");
  }

  /// Log a message at level [Level.verbose].
  static v(String msg) {
    _logger.v("$_DEFAULT_TAG_PREFIX: $msg");
  }

  /// Log a message at level [Level.warning].
  static w(String msg) {
    _logger.w("$_DEFAULT_TAG_PREFIX: $msg");
  }

  /// Log a message at level [Level.wtf].
  static wtf(String msg) {
    _logger.wtf("$_DEFAULT_TAG_PREFIX: $msg");
  }

  /// Log a message at level [Level.fatal].
  static f(String msg) {
    _logger.f("$_DEFAULT_TAG_PREFIX: $msg");
  }

  /// Log a message at level [Level.trace].
  static t(String msg) {
    _logger.t("$_DEFAULT_TAG_PREFIX: $msg");
  }
}
