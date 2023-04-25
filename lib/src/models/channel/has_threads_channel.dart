import 'package:nyxx/src/builders/channel/thread.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/channel/thread_list.dart';
import 'package:nyxx/src/models/snowflake.dart';

/// A channel which can have threads.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/topics/threads
abstract class HasThreadsChannel implements GuildChannel {
  /// The default [Thread.autoArchiveDuration] for [Thread]s created in this channel.
  ///
  /// External references:
  /// * [ThreadBuilder.archiveOneHour], [ThreadBuilder.archiveOneDay], [ThreadBuilder.archiveThreeDays] and [ThreadBuilder.archiveOneWeek], the values this
  /// field can take.
  Duration get defaultAutoArchiveDuration;

  /// The default [Thread.rateLimitPerUser] for [Thread]s created in this channel.
  Duration? get defaultThreadRateLimitPerUser;

  /// Create a [Thread] from a [Message] in this channel.
  ///
  /// Cannot be used in [ForumChannel]s.
  ///
  /// External references:
  /// * [ChannelManager.createThreadFromMessage]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#start-thread-from-message
  Future<Thread> createThreadFromMessage(Snowflake messageId, ThreadFromMessageBuilder builder);

  /// Create a [Thread] in this channel.
  ///
  /// Cannot be used in [ForumChannel]s.
  ///
  /// External references:
  /// * [ChannelManager.createThread]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#start-thread-without-message
  Future<Thread> createThread(ThreadBuilder builder);

  /// List the public archived [Thread]s in this channel.
  ///
  /// External references:
  /// * [ChannelManager.listPublicArchivedThreads]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#list-public-archived-threads
  Future<ThreadList> listPublicArchivedThreads({DateTime? before, int? limit});

  /// List the private archived [Thread]s in this channel.
  ///
  /// External references:
  /// * [ChannelManager.listPrivateArchivedThreads]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#list-private-archived-threads
  Future<ThreadList> listPrivateArchivedThreads({DateTime? before, int? limit});

  /// List the private archived [Thread]s in this channel which the current user has joined.
  ///
  /// External references:
  /// * [ChannelManager.listJoinedPrivateArchivedThreads]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#list-joined-private-archived-threads
  Future<ThreadList> listJoinedPrivateArchivedThreads({DateTime? before, int? limit});
}
