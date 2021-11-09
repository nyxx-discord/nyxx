import 'dart:async';

import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/channel/cacheable_text_channel.dart';
import 'package:nyxx/src/core/channel/channel.dart';
import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/channel/thread_channel.dart';
import 'package:nyxx/src/core/channel/guild/text_guild_channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/internal/cache/cache.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/message_builder.dart';
import 'package:nyxx/src/utils/builders/thread_builder.dart';

abstract class IThreadPreviewChannel implements IChannel, ITextChannel {
  /// Name of the channel
  String get name;

  /// Approximate message count
  int get messageCount;

  /// Approximate member count
  int get memberCount;

  /// Guild where the thread is located
  Cacheable<Snowflake, IGuild> get guild;

  /// The text channel where the thread was made
  CacheableTextChannel<ITextGuildChannel> get parentChannel;

  /// Initial author of the thread
  Cacheable<Snowflake, IMember> get owner;

  /// Preview of initial members
  List<Cacheable<Snowflake, IMember>> get memberPreview;

  /// If the thread has been archived
  bool get archived;

  /// When the thread will be archived
  DateTime get archivedTime;

  /// How long till the thread is archived
  ThreadArchiveTime get archivedAfter;

  /// Get the actual thread channel from the preview
  ChannelCacheable<IThreadChannel> getThreadChannel();
}

/// Given when a thread is created as only partial information is available. If you want the final channel use [getThreadChannel]
class ThreadPreviewChannel extends Channel implements IThreadPreviewChannel {
  Timer? _typing;

  /// Name of the channel
  @override
  late final String name;

  /// Approximate message count
  @override
  late final int messageCount;

  /// Approximate member count
  @override
  late final int memberCount;

  /// Guild where the thread is located
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// The text channel where the thread was made
  @override
  late final CacheableTextChannel<ITextGuildChannel> parentChannel;

  /// Initial author of the thread
  @override
  late final Cacheable<Snowflake, IMember> owner;

  /// Preview of initial members
  @override
  late final List<Cacheable<Snowflake, IMember>> memberPreview;

  /// If the thread has been archived
  @override
  late final bool archived;

  /// When the thread will be archived
  @override
  late final DateTime archivedTime;

  /// How long till the thread is archived
  @override
  late final ThreadArchiveTime archivedAfter;

  @override
  late final SnowflakeCache<IMessage> messageCache = SnowflakeCache<IMessage>(0);

  /// Creates an instance of [ThreadPreviewChannel]
  ThreadPreviewChannel(INyxx client, RawApiMap raw) : super(client, raw) {
    name = raw["name"] as String;
    messageCount = raw["message_count"] as int;
    memberCount = raw["member_count"] as int;
    parentChannel = CacheableTextChannel(client, Snowflake(raw["parent_id"]));
    guild = GuildCacheable(client, Snowflake(raw["guild_id"]));
    owner = MemberCacheable(client, Snowflake(raw["owner_id"]), guild);
    memberPreview = [];
    if (raw["member_ids_preview"] != null) {
      for (final id in raw["member_ids_preview"] as List<String>) {
        memberPreview.add(MemberCacheable(client, Snowflake(id), guild));
      }
    }
    final metadata = raw["thread_metadata"] as RawApiMap;

    archived = metadata["archived"] as bool;
    archivedTime = DateTime.parse(metadata["archive_timestamp"] as String);
    archivedAfter = ThreadArchiveTime(metadata["auto_archive_duration"] as int);
  }

  /// Get the actual thread channel from the preview
  @override
  ChannelCacheable<IThreadChannel> getThreadChannel() => ChannelCacheable(client, id);

  @override
  Future<void> bulkRemoveMessages(Iterable<SnowflakeEntity> messages) => client.httpEndpoints.bulkRemoveMessages(id, messages);

  @override
  Stream<IMessage> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before}) =>
      client.httpEndpoints.downloadMessages(id, limit: limit, after: after, around: around, before: before);

  @override
  Future<IMessage> fetchMessage(Snowflake messageId) => client.httpEndpoints.fetchMessage(id, messageId);

  @override
  IMessage? getMessage(Snowflake id) => messageCache[id];

  @override
  Future<IMessage> sendMessage(MessageBuilder builder) => client.httpEndpoints.sendMessage(id, builder);

  @override
  Future<int> get fileUploadLimit async {
    final guildInstance = await guild.getOrDownload();

    return guildInstance.fileUploadLimit;
  }

  @override
  Future<void> startTyping() async => client.httpEndpoints.triggerTyping(id);

  @override
  void startTypingLoop() {
    startTyping();
    _typing = Timer.periodic(const Duration(seconds: 7), (Timer t) => startTyping());
  }

  @override
  void stopTypingLoop() => _typing?.cancel();

  @override
  Stream<IMessage> fetchPinnedMessages() => client.httpEndpoints.fetchPinnedMessages(id);
}
