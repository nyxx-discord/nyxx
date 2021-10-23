import 'dart:async';

import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/SnowflakeEntity.dart';
import 'package:nyxx/src/core/channel/CacheableTextChannel.dart';
import 'package:nyxx/src/core/channel/Channel.dart';
import 'package:nyxx/src/core/channel/ITextChannel.dart';
import 'package:nyxx/src/core/channel/ThreadChannel.dart';
import 'package:nyxx/src/core/channel/guild/TextGuildChannel.dart';
import 'package:nyxx/src/core/guild/Guild.dart';
import 'package:nyxx/src/core/message/Message.dart';
import 'package:nyxx/src/core/user/Member.dart';
import 'package:nyxx/src/internal/cache/Cache.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/MessageBuilder.dart';
import 'package:nyxx/src/utils/builders/ThreadBuilder.dart';

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

  /// Creates an instance of [ThreadPreviewChannel]
  ThreadPreviewChannel(INyxx client, RawApiMap raw) : super(client, raw) {
    this.name = raw["name"] as String;
    this.messageCount = raw["message_count"] as int;
    this.memberCount = raw["member_count"] as int;
    this.parentChannel = CacheableTextChannel(client, Snowflake(raw["parent_id"]));
    this.guild = GuildCacheable(client, Snowflake(raw["guild_id"]));
    this.owner = MemberCacheable(client, Snowflake(raw["owner_id"]), this.guild);
    this.memberPreview = [];
    if (raw["member_ids_preview"] != null) {
      for (final id in raw["member_ids_preview"] as List<String>) {
        this.memberPreview.add(MemberCacheable(client, Snowflake(id), this.guild));
      }
    }
    final metadata = raw["thread_metadata"] as RawApiMap;

    this.archived = metadata["archived"] as bool;
    this.archivedTime = DateTime.parse(metadata["archive_timestamp"] as String);
    this.archivedAfter = ThreadArchiveTime(metadata["auto_archive_duration"] as int);
  }

  /// Get the actual thread channel from the preview
  @override
  ChannelCacheable<IThreadChannel> getThreadChannel() => new ChannelCacheable(client, this.id);

  @override
  Future<void> bulkRemoveMessages(Iterable<SnowflakeEntity> messages) => client.httpEndpoints.bulkRemoveMessages(this.id, messages);

  @override
  Stream<IMessage> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before}) =>
      client.httpEndpoints.downloadMessages(this.id, limit: limit, after: after, around: around, before: before);

  @override
  Future<IMessage> fetchMessage(Snowflake messageId) => client.httpEndpoints.fetchMessage(this.id, messageId);

  @override
  IMessage? getMessage(Snowflake id) => this.messageCache[id];

  @override
  Future<IMessage> sendMessage(MessageBuilder builder) => client.httpEndpoints.sendMessage(this.id, builder);

  @override
  Future<int> get fileUploadLimit async {
    final guildInstance = await this.guild.getOrDownload();

    return guildInstance.fileUploadLimit;
  }

  @override
  late final MessageCache messageCache = MessageCache(0);

  @override
  Future<void> startTyping() async => client.httpEndpoints.triggerTyping(this.id);

  @override
  void startTypingLoop() {
    startTyping();
    this._typing = Timer.periodic(const Duration(seconds: 7), (Timer t) => startTyping());
  }

  @override
  void stopTypingLoop() => this._typing?.cancel();

  @override
  Stream<IMessage> fetchPinnedMessages() => client.httpEndpoints.fetchPinnedMessages(this.id);
}
