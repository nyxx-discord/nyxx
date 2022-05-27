import 'package:logging/logging.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/plugin/plugin.dart';

class Logging extends BasePlugin {
  @override
  void onRegister(INyxx nyxx, Logger logger) {
    Logger.root.onRecord.listen((LogRecord rec) {
      print("[${rec.time}] [${rec.level.name}] [${rec.loggerName}] ${rec.message}");
    });
  }
}
