import 'dart:async';

import 'package:logging/logging.dart';
import 'package:nyxx/nyxx.dart';

abstract class BasePlugin {
  FutureOr<void> onRegister(INyxx nyxx, Logger logger) async {}

  FutureOr<void> onBotStart(INyxx nyxx, Logger logger) async {}
  FutureOr<void> onBotStop(INyxx nyxx, Logger logger) async {}
}
