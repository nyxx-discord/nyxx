import 'package:nyxx/src/core/channel/guild/forum/forum_channel_tags.dart';
import 'package:nyxx/src/core/channel/guild/forum/forum_tag.dart';
import 'package:nyxx/src/core/channel/guild/guild_channel.dart';
import 'package:nyxx/src/core/channel/thread_channel.dart';
import 'package:nyxx/src/core/channel/thread_preview_channel.dart';
import 'package:nyxx/src/core/message/emoji.dart';
import 'package:nyxx/src/core/message/guild_emoji.dart';
import 'package:nyxx/src/core/message/unicode_emoji.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/internal/exceptions/unknown_enum_value.dart';
import 'package:nyxx/src/internal/interfaces/mentionable.dart';
import 'package:nyxx/src/internal/response_wrapper/thread_list_result_wrapper.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/forum_thread_builder.dart';

enum ForumSortOrder {
  /// Sort forum posts by activity
  latestActivity(0),

  /// Sort forum posts by creation time (from most recent to oldest)
  creationDate(1);

  final int value;
  const ForumSortOrder(this.value);

  static ForumSortOrder _fromValue(int value) => values.firstWhere((v) => v.value == value, orElse: () => throw UnknownEnumValueError(value));

  @override
  String toString() => 'ForumSortOrder[$value]';
}

enum ForumLayout {
  notSet(0),
  listView(1),
  galleryView(2);

  final int value;
  const ForumLayout(this.value);

  static ForumLayout _fromValue(int value) => values.firstWhere((v) => v.value == value, orElse: () => throw UnknownEnumValueError(value));

  @override
  String toString() => 'ForumLayout[$value]';
}

abstract class IForumChannel implements IGuildChannel, Mentionable {
  /// Tags available to assign to forum posts
  List<IForumTag> get availableTags;

  /// Channel flags
  IForumChannelTags get forumChannelFlags;

  /// The default sort order type used to order posts in GUILD_FORUM channels.
  /// Defaults to null, which indicates a preferred sort order hasn't been set by a channel admin
  ForumSortOrder? get defaultSortOrder;

  /// The default forum layout view used to display posts in GUILD_FORUM channels.
  /// Defaults to 0, which indicates a layout view has not been set by a channel admin
  ForumLayout get defaultForumLayout;

  /// The emoji to show in the add reaction button on a thread in a GUILD_FORUM channel
  IEmoji? get defaultReactionEmoji;

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

  @override
  late final IForumChannelTags forumChannelFlags;

  @override
  late final ForumSortOrder? defaultSortOrder;

  @override
  late final ForumLayout defaultForumLayout;

  @override
  late final IEmoji? defaultReactionEmoji;

  /// Creates an instance of [TextGuildChannel]
  ForumChannel(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super(client, raw, guildId) {
    availableTags = (raw['available_tags'] as List<dynamic>? ?? []).cast<RawApiMap>().map((e) => ForumTag(e)).toList();
    forumChannelFlags = ForumChannelTags(raw['flags'] as int);
    defaultSortOrder = raw['default_sort_order'] == null ? null : ForumSortOrder._fromValue(raw['default_sort_order'] as int);
    defaultForumLayout = raw['default_sort_order'] == null ? ForumLayout.notSet : ForumLayout._fromValue(raw['default_sort_order'] as int);

    if (raw['default_reaction_emoji'] != null) {
      final rawDefaultEmoji = raw['default_reaction_emoji'] as RawApiMap;

      if (rawDefaultEmoji['emoji_id'] != null) {
        defaultReactionEmoji = GuildEmojiPartial({'id': rawDefaultEmoji['emoji_id']});
      } else {
        defaultReactionEmoji = UnicodeEmoji(rawDefaultEmoji['emoji_name'] as String);
      }
    } else {
      defaultReactionEmoji = null;
    }
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
