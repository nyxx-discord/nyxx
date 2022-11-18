import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/plugin/plugin.dart';

class Logging extends BasePlugin {
  final Level stderrLevel;
  final Level stackTraceLevel;
  final Level logLevel;

  final int? truncateLogsAt;

  @override
  String get name => 'Logging';

  Logging({
    this.stderrLevel = Level.WARNING,
    this.stackTraceLevel = Level.SEVERE,
    this.logLevel = Level.INFO,
    this.truncateLogsAt = 1000,
  });

  Level? _oldStacktraceLevel;
  Level? _oldLogLevel;
  StreamSubscription<void>? _subscription;

  @override
  void onRegister(INyxx nyxx, Logger logger) {
    _oldStacktraceLevel = recordStackTraceAtLevel;
    _oldLogLevel = Logger.root.level;

    recordStackTraceAtLevel = stackTraceLevel;
    Logger.root.level = logLevel;

    _subscription = Logger.root.onRecord.listen((LogRecord rec) {
      final message = StringBuffer();

      var customMessage = rec.message;
      if (truncateLogsAt != null && customMessage.length > truncateLogsAt!) {
        customMessage = '${customMessage.substring(0, truncateLogsAt! - 3)}...';
      }

      message.writeln('[${rec.time}] [${rec.level.name}] [${rec.loggerName}] $customMessage');

      final error = rec.error;
      if (error != null) {
        // Indent error
        final errorMessage = 'Error: $error'.replaceAll('\n', '\n  ');
        message.writeln(errorMessage);

        if (errorMessage.contains('\n')) {
          // Add newline for extra readability if error message contains newlines
          message.writeln();
        }
      }

      final stackTrace = (error is Error ? error.stackTrace : null) ?? rec.stackTrace;
      if (stackTrace != null) {
        // Indent stack trace
        message.writeln('Stack trace:\n$stackTrace'.replaceAll('\n', '\n  '));
        message.writeln();
      }

      final outSink = rec.level > stderrLevel ? stderr : stdout;
      outSink.write(message.toString());
    });
  }

  @override
  void onBotStop(INyxx nyxx, Logger logger) {
    recordStackTraceAtLevel = _oldStacktraceLevel!;
    Logger.root.level = _oldLogLevel!;
    _subscription!.cancel();
  }
}
