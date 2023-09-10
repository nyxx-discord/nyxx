import 'package:nyxx/src/builders/invite.dart';
import 'package:nyxx/src/builders/permission_overwrite.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/channel/voice_channel.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/invite/invite.dart';
import 'package:nyxx/src/models/invite/invite_metadata.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/webhook.dart';

/// {@template guild_voice_channel}
/// A [VoiceChannel] in a [Guild].
/// {@endtemplate}
class GuildVoiceChannel extends TextChannel implements GuildChannel, VoiceChannel {
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
  ChannelType get type => ChannelType.guildVoice;

  /// {@macro guild_voice_channel}
  GuildVoiceChannel({
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

  @override
  PartialGuild get guild => manager.client.guilds[guildId];

  @override
  PartialMessage? get lastMessage => lastMessageId == null ? null : messages[lastMessageId!];

  @override
  PartialChannel? get parent => parentId == null ? null : manager.client.channels[parentId!];

  @override
  Future<void> deletePermissionOverwrite(Snowflake id) => manager.deletePermissionOverwrite(this.id, id);

  @override
  Future<void> updatePermissionOverwrite(PermissionOverwriteBuilder builder) => manager.updatePermissionOverwrite(id, builder);

  @override
  Future<List<Webhook>> fetchWebhooks() => manager.client.webhooks.fetchChannelWebhooks(id);

  @override
  Future<List<InviteWithMetadata>> listInvites() => manager.listInvites(id);

  @override
  Future<Invite> createInvite(InviteBuilder builder, {String? auditLogReason}) => manager.createInvite(id, builder, auditLogReason: auditLogReason);
}
