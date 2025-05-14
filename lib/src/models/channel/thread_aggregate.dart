import 'package:nyxx/nyxx.dart';

abstract class ThreadsOnlyChannel implements HasThreadsChannel {
  /// The topic of this channel.
  String? get topic;

  /// The rate limit duration of this channel per user.
  ///
  /// Does not apply to threads created in this channel.
  /// See [HasThreadsChannel.defaultThreadRateLimitPerUser] for that.
  Duration? get rateLimitPerUser;

  /// The ID of the last [Thread] created.
  Snowflake? get lastThreadId;

  /// The time at which the last message was pinned.
  DateTime? get lastPinTimestamp;

  /// Any flags applied to this channel.
  ChannelFlags get flags;

  /// A list of tags available in this channel.
  List<ForumTag> get availableTags;

  /// The default reaction for this channel.
  DefaultReaction? get defaultReaction;

  /// The default sort order in this channel
  ForumSort? get defaultSortOrder;

  /// Create a thread in this thread aggregate channel.
  ///
  /// External references:
  /// * [ChannelManager.createForumThread]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#start-thread-in-forum-channel
  Future<Thread> createForumThread(ForumThreadBuilder builder, {String? auditLogReason});
}
