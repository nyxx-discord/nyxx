import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/channel/voice_channel.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';

class PartialGuildStageChannel extends PartialTextChannel implements PartialVoiceChannel, PartialGuildChannel {
  PartialGuildStageChannel({required super.id, required super.manager});
}

class GuildStageChannel extends PartialGuildStageChannel implements TextChannel, VoiceChannel, GuildChannel {
  @override
  final int bitrate;

  @override
  final Snowflake guildId;

  @override
  final bool isNsfw;

  @override
  final Snowflake? lastMessageId;

  @override
  final DateTime? lastPinTimestamp;

  @override
  final String name;

  @override
  final Snowflake? parentId;

  @override
  final List<PermissionOverwrite> permissionOverwrites;

  @override
  final int position;

  @override
  final Duration? rateLimitPerUser;

  @override
  final String? rtcRegion;

  @override
  final int? userLimit;

  @override
  final VideoQualityMode videoQualityMode;

  @override
  ChannelType get type => ChannelType.guildStageVoice;

  GuildStageChannel({
    required super.id,
    required super.manager,
    required this.bitrate,
    required this.guildId,
    required this.isNsfw,
    required this.lastMessageId,
    required this.lastPinTimestamp,
    required this.name,
    required this.parentId,
    required this.permissionOverwrites,
    required this.position,
    required this.rateLimitPerUser,
    required this.rtcRegion,
    required this.userLimit,
    required this.videoQualityMode,
  });
}
