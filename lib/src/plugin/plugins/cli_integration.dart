import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/plugin/plugin.dart';

class CliIntegration extends BasePlugin {
  @override
  String get name => 'CliIntegration';

  StreamSubscription<ProcessSignal>? _sigtermSubscription;
  StreamSubscription<ProcessSignal>? _sigintSubscription;

  @override
  void onRegister(INyxx nyxx, Logger logger) {
    if (!Platform.isWindows) {
      _sigtermSubscription = ProcessSignal.sigterm.watch().listen((event) => nyxx.dispose());
    }

    _sigintSubscription = ProcessSignal.sigint.watch().listen((event) => nyxx.dispose());

    logger.info("Starting bot with pid: $pid. To stop the bot gracefully send SIGTERM or SIGKILL");
  }

  @override
  void onBotStop(INyxx nyxx, Logger logger) {
    _sigintSubscription?.cancel();
    _sigtermSubscription?.cancel();
  }
}
