import 'package:nyxx/src/models/channel/channel.dart';

class DirectoryChannel extends Channel {
  @override
  ChannelType get type => ChannelType.guildDirectory;

  DirectoryChannel({required super.id, required super.manager});
}
