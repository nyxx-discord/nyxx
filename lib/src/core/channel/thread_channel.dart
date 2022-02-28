import 'dart:async';

import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/channel/cacheable_text_channel.dart';
import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/channel/guild/guild_channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/internal/cache/cache.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/message_builder.dart';
import 'package:nyxx/src/utils/builders/thread_builder.dart';

abstract class IThreadMember implements SnowflakeEntity {
  /// Reference to client
  INyxx get client;

  /// Reference to [ThreadChannel]
  ICacheableTextChannel<IThreadChannel> get thread;

  /// When member joined thread
  DateTime get joinTimestamp;

  /// Any user-thread settings, currently only used for notifications
  int get flags;

  /// [ThreadMember]s [IGuild]
  Cacheable<Snowflake, IGuild> get guild;

  /// [Cacheable] of [IUser]
  Cacheable<Snowflake, IUser> get user;

  /// [Cacheable] of [IMember]
  Cacheable<Snowflake, IMember> get member;
}

/// Member of [ThreadChannel]
class ThreadMember extends SnowflakeEntity implements IThreadMember {
  /// Reference to client
  @override
  final INyxx client;

  /// Reference to [ThreadChannel]
  @override
  late final ICacheableTextChannel<IThreadChannel> thread;

  /// When member joined thread
  @override
  late final DateTime joinTimestamp;

  /// Any user-thread settings, currently only used for notifications
  @override
  late final int flags;

  /// [ThreadMember]s [Guild]
  @override
  final Cacheable<Snowflake, IGuild> guild;

  /// [Cacheable] of [User]
  @override
  Cacheable<Snowflake, IUser> get user => UserCacheable(client, id);

  /// [Cacheable] of [Member]
  @override
  Cacheable<Snowflake, IMember> get member => MemberCacheable(client, id, guild);

  /// Creates an instance of [ThreadMember]
  ThreadMember(this.client, RawApiMap raw, this.guild) : super(Snowflake(raw["user_id"])) {
    thread = CacheableTextChannel(client, Snowflake(raw["id"]));
    joinTimestamp = DateTime.parse(raw["join_timestamp"] as String);
    flags = raw["flags"] as int;
  }
}

abstract class IThreadChannel implements MinimalGuildChannel, ITextChannel {
  /// Owner of the thread
  Cacheable<Snowflake, IMember> get owner;

  /// Approximate message count
  int get messageCount;

  /// Approximate member count
  int get memberCount;

  /// True if thread is archived
  bool get archived;

  /// Date when thread was archived
  DateTime get archiveAt;

  /// Time after what thread will be archived
  ThreadArchiveTime get archiveAfter;

  /// Whether non-moderators can add other non-moderators to a thread; only available on private threads
  bool get invitable;

  /// Fetches from API current list of member that has access to that thread
  Stream<IThreadMember> fetchMembers();

  /// Fetches thread member from the API
  Future<IThreadMember> fetchMember(Snowflake memberId);

  /// Leaves this thread channel
  Future<void> leaveThread();

  /// Removes [user] from [ThreadChannel]
  Future<void> removeThreadMember(SnowflakeEntity user);

  /// Adds [user] to [ThreadChannel]
  Future<void> addThreadMember(SnowflakeEntity user);

  /// Edits this [ThreadChannel] and returns the edited [ThreadChannel]
  Future<ThreadChannel> edit(ThreadBuilder builder);
}

class ThreadChannel extends MinimalGuildChannel implements IThreadChannel {
  Timer? _typing;

  /// Owner of the thread
  @override
  late final Cacheable<Snowflake, IMember> owner;

  /// Approximate message count
  @override
  late final int messageCount;

  /// Approximate member count
  @override
  late final int memberCount;

  /// True if thread is archived
  @override
  late final bool archived;

  /// Date when thread was archived
  @override
  late final DateTime archiveAt;

  /// Time after what thread will be archived
  @override
  late final ThreadArchiveTime archiveAfter;

  /// Whether non-moderators can add other non-moderators to a thread; only available on private threads
  @override
  late final bool invitable;

  @override
  Future<int> get fileUploadLimit async {
    final guildInstance = await guild.getOrDownload();
    return guildInstance.fileUploadLimit;
  }

  @override
  late final SnowflakeCache<IMessage> messageCache = SnowflakeCache<IMessage>(client.options.messageCacheSize);

  /// Creates an instance of [ThreadChannel]
  ThreadChannel(INyxx client, RawApiMap raw) : super(client, raw) {
    owner = MemberCacheable(client, Snowflake(raw["owner_id"]), guild);

    messageCount = raw["message_count"] as int;
    memberCount = raw["member_count"] as int;

    final meta = raw["thread_metadata"];
    archived = meta["archived"] as bool;
    archiveAt = DateTime.parse(meta["archive_timestamp"] as String);
    archiveAfter = ThreadArchiveTime(meta["auto_archive_duration"] as int);
    invitable = raw["invitable"] as bool? ?? false;
  }

  /// Fetches from API current list of member that has access to that thread
  @override
  Stream<IThreadMember> fetchMembers() => client.httpEndpoints.fetchThreadMembers(id, guild.id);

  @override
  Future<IThreadMember> fetchMember(Snowflake memberId) => client.httpEndpoints.fetchThreadMember(id, guild.id, memberId);

  @override
  Future<void> bulkRemoveMessages(Iterable<SnowflakeEntity> messages) => client.httpEndpoints.bulkRemoveMessages(id, messages);

  @override
  Stream<IMessage> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before}) =>
      client.httpEndpoints.downloadMessages(id, limit: limit, after: after, around: around, before: before);

  @override
  Future<IMessage> fetchMessage(Snowflake messageId) async {
    final message = await client.httpEndpoints.fetchMessage(id, messageId);

    if (client.cacheOptions.messageCachePolicyLocation.http && client.cacheOptions.messageCachePolicy.canCache(message)) {
      messageCache[messageId] = message;
    }

    return message;
  }

  @override
  IMessage? getMessage(Snowflake id) => messageCache[id];

  @override
  Future<IMessage> sendMessage(MessageBuilder builder) => client.httpEndpoints.sendMessage(id, builder);

  @override
  Future<void> startTyping() async => client.httpEndpoints.triggerTyping(id);

  @override
  void startTypingLoop() {
    startTyping();
    _typing = Timer.periodic(const Duration(seconds: 7), (Timer t) => startTyping());
  }

  @override
  void stopTypingLoop() => _typing?.cancel();

  /// Leaves this thread channel
  @override
  Future<void> leaveThread() => client.httpEndpoints.leaveGuild(id);

  /// Removes [user] from [ThreadChannel]
  @override
  Future<void> removeThreadMember(SnowflakeEntity user) => client.httpEndpoints.removeThreadMember(id, user.id);

  /// Adds [user] to [ThreadChannel]
  @override
  Future<void> addThreadMember(SnowflakeEntity user) => client.httpEndpoints.addThreadMember(id, user.id);

  @override
  Stream<IMessage> fetchPinnedMessages() => client.httpEndpoints.fetchPinnedMessages(id);

  @override
  Future<ThreadChannel> edit(ThreadBuilder builder) => client.httpEndpoints.editThreadChannel(id, builder);
}
