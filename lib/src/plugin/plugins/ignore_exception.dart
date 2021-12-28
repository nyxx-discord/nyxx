import 'dart:async';
import 'dart:isolate';

import 'package:logging/logging.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/plugin/plugin.dart';

class IgnoreExceptions extends BasePlugin {
  @override
  FutureOr<void> onRegister(INyxx nyxx, Logger logger) {
    Isolate.current.setErrorsFatal(false);

    final errorsPort = ReceivePort();
    errorsPort.listen((err) {
      final stackTrace = err[1] != null ? ". Stacktrace: \n${err[1]}" : "";

      logger.shout("Got Error: Message: [${err[0]}]$stackTrace");

      if (err[0].startsWith('UnrecoverableNyxxError') as bool) {
        Isolate.current.kill();
      }
    });

    Isolate.current.addErrorListener(errorsPort.sendPort);
  }
}
