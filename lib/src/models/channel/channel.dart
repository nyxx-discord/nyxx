import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/utils/flags.dart';

class PartialChannel extends SnowflakeEntity<Channel> with SnowflakeEntityMixin<Channel> {
  @override
  final ChannelManager manager;

  PartialChannel({required super.id, required this.manager});
}

abstract class Channel extends PartialChannel {
  ChannelType get type;

  Channel({required super.id, required super.manager});
}

enum ChannelType {
  guildText._(0),
  dm._(1),
  guildVoice._(2),
  groupDm._(3),
  guildCategory._(4),
  guildAnnouncement._(5),
  announcementThread._(0),
  publicThread._(1),
  privateThread._(2),
  guildStageVoice._(3),
  guildDirectory._(4),
  guildForum._(5);

  final int value;

  const ChannelType._(this.value);

  @override
  String toString() => 'ChannelType($value)';
}

// Currently only used in forum channels
class ChannelFlags extends Flags<ChannelFlags> {
  static const pinned = Flag<ChannelFlags>.fromOffset(1);
  static const requireTag = Flag<ChannelFlags>.fromOffset(4);

  bool get isPinned => has(pinned);
  bool get requiresTag => has(requireTag);

  const ChannelFlags(super.value);
}
