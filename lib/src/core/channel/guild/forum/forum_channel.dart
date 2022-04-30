import 'package:nyxx/src/core/channel/guild/forum/forum_tag.dart';
import 'package:nyxx/src/core/channel/guild/guild_channel.dart';
import 'package:nyxx/src/core/channel/thread_channel.dart';
import 'package:nyxx/src/core/channel/thread_preview_channel.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/internal/interfaces/mentionable.dart';
import 'package:nyxx/src/internal/response_wrapper/thread_list_result_wrapper.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/forum_thread_builder.dart';

abstract class IForumChannel implements IGuildChannel, Mentionable {
  /// Tags available to assign to forum posts
  List<IForumTag> get availableTags;

  /// Creates a thread in a channel, that only retrieves a [ThreadPreviewChannel]
  Future<IThreadChannel> createThread(ForumThreadBuilder builder);

  /// Fetches joined private and archived thread channels
  Future<IThreadListResultWrapper> fetchJoinedPrivateArchivedThreads({DateTime? before, int? limit});

  /// Fetches private, archived thread channels
  Future<IThreadListResultWrapper> fetchPrivateArchivedThreads({DateTime? before, int? limit});

  /// Fetches public, archives thread channels
  Future<IThreadListResultWrapper> fetchPublicArchivedThreads({DateTime? before, int? limit});
}

class ForumChannel extends GuildChannel implements IForumChannel {
  @override
  late final List<IForumTag> availableTags;

  /// Creates an instance of [TextGuildChannel]
  ForumChannel(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super(client, raw, guildId) {
    availableTags = (raw['available_tags'] as List<dynamic>).cast<RawApiMap>().map((e) => ForumTag(e)).toList();
  }

  /// The channel's mention string.
  @override
  String get mention => "<#$id>";

  /// Creates a thread in a channel, that only retrieves a [ThreadPreviewChannel]
  @override
  Future<IThreadChannel> createThread(ForumThreadBuilder builder) => client.httpEndpoints.startForumThread(id, builder);

  /// Fetches joined private and archived thread channels
  @override
  Future<IThreadListResultWrapper> fetchJoinedPrivateArchivedThreads({DateTime? before, int? limit}) =>
      client.httpEndpoints.fetchJoinedPrivateArchivedThreads(id, before: before, limit: limit);

  /// Fetches private, archived thread channels
  @override
  Future<IThreadListResultWrapper> fetchPrivateArchivedThreads({DateTime? before, int? limit}) =>
      client.httpEndpoints.fetchPrivateArchivedThreads(id, before: before, limit: limit);

  /// Fetches public, archives thread channels
  @override
  Future<IThreadListResultWrapper> fetchPublicArchivedThreads({DateTime? before, int? limit}) =>
      client.httpEndpoints.fetchPublicArchivedThreads(id, before: before, limit: limit);
}
