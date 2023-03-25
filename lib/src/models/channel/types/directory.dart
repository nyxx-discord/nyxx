import 'package:nyxx/src/models/channel/channel.dart';

class PartialDirectoryChannel extends PartialChannel {
  PartialDirectoryChannel({required super.id, required super.manager});
}

class DirectoryChannel extends PartialDirectoryChannel implements Channel {
  @override
  ChannelType get type => ChannelType.guildDirectory;

  DirectoryChannel({required super.id, required super.manager});
}
