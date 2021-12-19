import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/plugin/plugin.dart';

class CliIntegration extends BasePlugin {
  @override
  FutureOr<void> onRegister(INyxx nyxx, Logger logger) {
    if (!Platform.isWindows) {
      ProcessSignal.sigterm.watch().forEach((event) async {
        await nyxx.dispose();
      });
    }

    ProcessSignal.sigint.watch().forEach((event) async {
      await nyxx.dispose();
    });

    logger.info("Starting bot with pid: $pid. To stop the bot gracefully send SIGTERM or SIGKILL");
  }
}
