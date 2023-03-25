import 'package:nyxx/src/http/managers/channel_manager.dart';
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
  announcementThread._(10),
  publicThread._(11),
  privateThread._(12),
  guildStageVoice._(13),
  guildDirectory._(14),
  guildForum._(15);

  final int value;

  const ChannelType._(this.value);

  factory ChannelType.parse(int value) => ChannelType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown channel type', value),
      );

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
