import 'package:nyxx/src/builders/channel/thread.dart';
import 'package:nyxx/src/builders/permission_overwrite.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/has_threads_channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/channel/thread_list.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class ForumChannel extends Channel implements GuildChannel, HasThreadsChannel {
  final String? topic;

  final Snowflake? lastThreadId;

  final DateTime? lastPinTimestamp;

  final ChannelFlags flags;

  final List<ForumTag> availableTags;

  final DefaultReaction? defaultReaction;

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

  ForumChannel({
    required super.id,
    required super.manager,
    required this.topic,
    required this.lastThreadId,
    required this.lastPinTimestamp,
    required this.flags,
    required this.availableTags,
    required this.defaultReaction,
    required this.defaultAutoArchiveDuration,
    required this.defaultThreadRateLimitPerUser,
    required this.guildId,
    required this.isNsfw,
    required this.name,
    required this.parentId,
    required this.permissionOverwrites,
    required this.position,
  });

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
  Future<void> updatePermissionOverwrite(PermissionOverwriteBuilder builder) => manager.updatePermissionOverwrite(id, builder);
}

class ForumTag with ToStringHelper {
  final Snowflake id;

  final String name;

  final bool isModerated;

  final Snowflake? emojiId;

  final String? emojiName;

  ForumTag({
    required this.id,
    required this.name,
    required this.isModerated,
    required this.emojiId,
    required this.emojiName,
  });
}

class DefaultReaction with ToStringHelper {
  final Snowflake? emojiId;

  final String? emojiName;

  DefaultReaction({required this.emojiId, required this.emojiName});
}

enum ForumSort {
  latestActivity._(0),
  creationDate._(1);

  final int value;

  const ForumSort._(this.value);

  @override
  String toString() => 'ForumSort($value)';
}

enum ForumLayout {
  notSet._(0),
  listView._(1),
  galleryView._(2);

  final int value;

  const ForumLayout._(this.value);

  @override
  String toString() => 'ForumLayout($value)';
}
