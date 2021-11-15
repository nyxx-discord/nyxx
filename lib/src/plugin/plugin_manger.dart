import 'package:nyxx/nyxx.dart';

abstract class IPluginManager {
  Iterable<BasePlugin> get plugins;

  void registerPlugin<T extends BasePlugin>(T pluginInstance);
}
