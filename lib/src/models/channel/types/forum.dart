import 'package:nyxx/src/builders/channel/thread.dart';
import 'package:nyxx/src/builders/invite.dart';
import 'package:nyxx/src/builders/permission_overwrite.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/channel/thread_aggregate.dart';
import 'package:nyxx/src/models/channel/thread_list.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/invite/invite.dart';
import 'package:nyxx/src/models/invite/invite_metadata.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/webhook.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template forum_channel}
/// A forum channel.
/// {@endtemplate}
class ForumChannel extends Channel implements GuildChannel, ThreadsOnlyChannel {
  /// The default layout in this channel
  final ForumLayout? defaultLayout;

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

  /// {@macro forum_channel}
  /// @nodoc
  ForumChannel({
    required super.id,
    required super.manager,
    required this.defaultLayout,
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
}

/// {@template forum_tag}
/// A tag in a forum channel.
/// {@endtemplate}
class ForumTag with ToStringHelper {
  /// The ID of this tag.
  final Snowflake id;

  /// The name of this tag.
  final String name;

  /// Whether this tag is moderated.
  final bool isModerated;

  /// The ID of the emoji for this tag.
  final Snowflake? emojiId;

  /// The name of the emoji for this tag.
  final String? emojiName;

  /// {@macro forum_tag}
  /// @nodoc
  ForumTag({
    required this.id,
    required this.name,
    required this.isModerated,
    required this.emojiId,
    required this.emojiName,
  });
}

/// {@template default_reaction}
/// A default reaction in a [ForumChannel].
/// {@endtemplate}
class DefaultReaction with ToStringHelper {
  /// The ID of the emoji.
  final Snowflake? emojiId;

  /// The name of the emoji.
  final String? emojiName;

  /// {@macro default_reaction}
  /// @nodoc
  DefaultReaction({required this.emojiId, required this.emojiName});
}

/// The sorting order in a [ForumChannel].
final class ForumSort extends EnumLike<int> {
  static const latestActivity = ForumSort._(0);
  static const creationDate = ForumSort._(1);

  static const values = [latestActivity, creationDate];

  const ForumSort._(super.value);

  factory ForumSort.parse(int value) => parseEnum(values, value);
}

/// The layout in a [ForumChannel].
final class ForumLayout extends EnumLike<int> {
  static const notSet = ForumLayout._(0);
  static const listView = ForumLayout._(1);
  static const galleryView = ForumLayout._(2);

  static const values = [notSet, listView, galleryView];

  const ForumLayout._(super.value);

  factory ForumLayout.parse(int value) => parseEnum(values, value);
}
