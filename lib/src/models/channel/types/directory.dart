import 'package:nyxx/src/models/channel/channel.dart';

/// {@template directory_channel}
/// A directory channel.
/// {@endtemplate}
class DirectoryChannel extends Channel {
  @override
  ChannelType get type => ChannelType.guildDirectory;

  /// {@macro directory_channel}
  DirectoryChannel({required super.id, required super.manager});
}
