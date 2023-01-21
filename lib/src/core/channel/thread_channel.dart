import 'dart:async';

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
import 'package:nyxx/src/nyxx.dart';
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

abstract class IThreadMemberWithMember extends IThreadMember {
  /// Fetched member from API
  Member get fetchedMember;
}

class ThreadMemberWithMember extends ThreadMember implements IThreadMember {
  late final Member fetchedMember;

  ThreadMemberWithMember(INyxx client, RawApiMap raw, Cacheable<Snowflake, IGuild> guild) : super(client, raw, guild) {
    fetchedMember = Member(client, raw['member'] as RawApiMap, guild.id);

    if (client.cacheOptions.memberCachePolicyLocation.http && client.cacheOptions.memberCachePolicy.canCache(fetchedMember)) {
      fetchedMember.guild.getFromCache()?.members[member.id] = fetchedMember;
    }
  }
}

abstract class IThreadChannel implements MinimalGuildChannel, ITextChannel {
  /// Owner of the thread
  Cacheable<Snowflake, IMember> get owner;

  /// Approximate message count
  int get messageCount;

  /// Approximate member count
  int get memberCount;

  /// Number of messages ever sent in a thread.
  /// It's similar to message_count on message creation, but will not decrement the number when a message is deleted
  int get totalMessagesSent;

  /// The IDs of the set of tags that have been applied to a thread in a GUILD_FORUM channel
  List<Snowflake> get appliedTags;

  /// True if thread is archived
  bool get archived;

  /// Date when thread was archived
  DateTime get archiveAt;

  /// Time after what thread will be archived
  ThreadArchiveTime get archiveAfter;

  /// Whether non-moderators can add other non-moderators to a thread; only available on private threads
  bool get invitable;

  /// Fetches from API current list of member that has access to that thread
  /// Returns [IThreadMemberWithMember] when [withMembers] set to true
  Stream<IThreadMember> fetchMembers({bool withMembers = false, Snowflake? after, int limit = 100});

  /// Fetches thread member from the API
  /// Returns [IThreadMemberWithMember] when [withMembers] set to true
  Future<IThreadMember> fetchMember(Snowflake memberId, {bool withMembers = false});

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

  @override
  late final Cacheable<Snowflake, IMember> owner;

  @override
  late final int messageCount;

  @override
  late final int memberCount;

  @override
  late final bool archived;

  @override
  late final DateTime archiveAt;

  @override
  late final ThreadArchiveTime archiveAfter;

  @override
  late final bool invitable;

  @override
  late final int totalMessagesSent;

  @override
  late final List<Snowflake> appliedTags;

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

    totalMessagesSent = raw['total_message_sent'] as int? ?? 0;
    appliedTags = (raw['applied_tags'] as List<dynamic>? ?? []).map((e) => Snowflake(e)).toList();
  }

  /// Fetches from API current list of member that has access to that thread
  @override
  Stream<IThreadMember> fetchMembers({bool withMembers = false, Snowflake? after, int limit = 100}) =>
      client.httpEndpoints.fetchThreadMembers(id, guild.id, withMembers: withMembers, after: after, limit: limit);

  @override
  Future<IThreadMember> fetchMember(Snowflake memberId, {bool withMembers = false}) =>
      client.httpEndpoints.fetchThreadMember(id, guild.id, memberId, withMembers: withMembers);

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
