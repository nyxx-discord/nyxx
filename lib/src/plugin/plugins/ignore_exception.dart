import 'dart:isolate';

import 'package:logging/logging.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/plugin/plugin.dart';

class IgnoreExceptions extends BasePlugin {
  late final ReceivePort _errorsPort;

  @override
  void onRegister(INyxx nyxx, Logger logger) {
    _errorsPort = _getErrorPort(logger);

    Isolate.current.setErrorsFatal(false);
    Isolate.current.addErrorListener(_errorsPort.sendPort);
  }

  @override
  void onBotStop(INyxx nyxx, Logger logger) => _stop();

  ReceivePort _getErrorPort(Logger logger) {
    final errorsPort = ReceivePort();
    errorsPort.listen((err) {
      final stackTrace = err[1] != null ? ". Stacktrace: \n${err[1]}" : "";

      logger.shout("Got Error: Message: [${err[0]}]$stackTrace");

      if (err[0].startsWith('UnrecoverableNyxxError') as bool) {
        _stop();

        throw err[0] as String;
      }
    });

    return errorsPort;
  }

  void _stop() {
    Isolate.current.removeErrorListener(_errorsPort.sendPort);
    Isolate.current.setErrorsFatal(true);

    _errorsPort.close();
  }
}
