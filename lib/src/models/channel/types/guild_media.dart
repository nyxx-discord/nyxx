import 'package:nyxx/src/builders/channel/thread.dart';
import 'package:nyxx/src/builders/invite.dart';
import 'package:nyxx/src/builders/permission_overwrite.dart';
import 'package:nyxx/src/builders/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/channel/thread_aggregate.dart';
import 'package:nyxx/src/models/channel/thread_list.dart';
import 'package:nyxx/src/models/channel/types/forum.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/invite/invite.dart';
import 'package:nyxx/src/models/invite/invite_metadata.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/webhook.dart';

/// {@template guild_media_channel}
/// A channel in a guild in which threads can be posted, similarly to a [ForumChannel].
/// {@endtemplate}
class GuildMediaChannel extends Channel implements GuildChannel, ThreadsOnlyChannel {
  @override
  final String? topic;

  @override
  final Duration? rateLimitPerUser;

  @override
  final Snowflake? lastThreadId;

  @override
  final DateTime? lastPinTimestamp;

  @override
  final ChannelFlags flags;

  @override
  final List<ForumTag> availableTags;

  @override
  final DefaultReaction? defaultReaction;

  @override
  final ForumSort? defaultSortOrder;

  @override
  final Duration defaultAutoArchiveDuration;

  @override
  final Duration? defaultThreadRateLimitPerUser;

  @override
  final Snowflake guildId;

  @override
  final bool isNsfw;

  @override
  final String name;

  @override
  final Snowflake? parentId;

  @override
  final List<PermissionOverwrite> permissionOverwrites;

  @override
  final int position;

  @override
  ChannelType get type => ChannelType.guildForum;

  /// {@macro guild_media_channel}
  /// @nodoc
  GuildMediaChannel({
    required super.id,
    required super.manager,
    required this.topic,
    required this.rateLimitPerUser,
    required this.lastThreadId,
    required this.lastPinTimestamp,
    required this.flags,
    required this.availableTags,
    required this.defaultReaction,
    required this.defaultSortOrder,
    required this.defaultAutoArchiveDuration,
    required this.defaultThreadRateLimitPerUser,
    required this.guildId,
    required this.isNsfw,
    required this.name,
    required this.parentId,
    required this.permissionOverwrites,
    required this.position,
  });

  @override
  PartialGuild get guild => manager.client.guilds[guildId];

  @override
  PartialChannel? get parent => parentId == null ? null : manager.client.channels[parentId!];

  @override
  Future<Thread> createForumThread(ForumThreadBuilder builder) => manager.createForumThread(id, builder);

  @override
  Future<Thread> createThread(ThreadBuilder builder) => throw UnsupportedError('Cannot create a non forum thread in a forum channel');

  @override
  Future<Thread> createThreadFromMessage(Snowflake messageId, ThreadFromMessageBuilder builder) =>
      throw UnsupportedError('Cannot create a non forum thread in a forum channel');

  @override
  Future<void> deletePermissionOverwrite(Snowflake id) => manager.deletePermissionOverwrite(this.id, id);

  @override
  Future<ThreadList> listPrivateArchivedThreads({DateTime? before, int? limit}) => manager.listPrivateArchivedThreads(id, before: before, limit: limit);

  @override
  Future<ThreadList> listPublicArchivedThreads({DateTime? before, int? limit}) => manager.listPublicArchivedThreads(id, before: before, limit: limit);

  @override
  Future<ThreadList> listJoinedPrivateArchivedThreads({DateTime? before, int? limit}) =>
      manager.listJoinedPrivateArchivedThreads(id, before: before, limit: limit);

  @override
  Future<void> updatePermissionOverwrite(PermissionOverwriteBuilder builder) => manager.updatePermissionOverwrite(id, builder);

  @override
  Future<List<Webhook>> fetchWebhooks() => manager.client.webhooks.fetchChannelWebhooks(id);

  @override
  Future<List<InviteWithMetadata>> listInvites() => manager.listInvites(id);

  @override
  Future<Invite> createInvite(InviteBuilder builder, {String? auditLogReason}) => manager.createInvite(id, builder, auditLogReason: auditLogReason);

  @override
  GuildChannelBuilder<GuildMediaChannel> toBuilder() => GuildChannelBuilder(
      name: name,
      type: type,
      permissionOverwrites: permissionOverwrites.map((e) => PermissionOverwriteBuilder(id: e.id, type: e.type, allow: e.allow, deny: e.deny)).toList(),
      position: position);
}
