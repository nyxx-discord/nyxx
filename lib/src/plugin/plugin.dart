import 'dart:async';

import 'package:logging/logging.dart';
import 'package:nyxx/nyxx.dart';

abstract class BasePlugin {
  FutureOr<void> onRegister(INyxx nyxx, Logger logger) async {}

  FutureOr<void> onBotStart(INyxx nyxx, Logger logger) async {}
  FutureOr<void> onBotStop(INyxx nyxx, Logger logger) async {}

  FutureOr<void> onConnectionClose(INyxx nyxx, Logger logger, int closeCode, String? closeReason) async {}
  FutureOr<void> onConnectionError(INyxx nyxx, Logger logger, String errorMessage) async {}
}
