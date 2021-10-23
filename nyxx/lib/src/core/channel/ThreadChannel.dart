part of nyxx;

/// Member of [ThreadChannel]
class ThreadMember extends SnowflakeEntity {
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
  Cacheable<Snowflake, IUser> get user => UserCacheable(this.client, this.id);

  /// [Cacheable] of [Member]
  @override
  Cacheable<Snowflake, IMember> get member => MemberCacheable(this.client, this.id, this.guild);

  /// Creates an instance of [ThreadMember]
  ThreadMember(this.client, RawApiMap raw, this.guild): super(Snowflake(raw["user_id"])) {
    this.thread = CacheableTextChannel(client, Snowflake(raw["id"]));
    this.joinTimestamp = DateTime.parse(raw["join_timestamp"] as String);
    this.flags = raw["flags"] as int;
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

  /// Leaves this thread channel
  Future<void> leaveThread();

  /// Removes [user] from [ThreadChannel]
  Future<void> removeThreadMember(SnowflakeEntity user);

  /// Adds [user] to [ThreadChannel]
  Future<void> addThreadMember(SnowflakeEntity user);
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
    final guildInstance = await this.guild.getOrDownload();
    return guildInstance.fileUploadLimit;
  }

  @override
  late final MessageCache messageCache = MessageCache(client.options.messageCacheSize);

  /// Creates an instance of [ThreadChannel]
  ThreadChannel(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super(client, raw) {
    this.owner = MemberCacheable(client, Snowflake(raw["owner_id"]), this.guild);

    this.messageCount = raw["message_count"] as int;
    this.memberCount = raw["member_count"] as int;

    final meta = raw["thread_metadata"];
    this.archived = meta["archived"] as bool;
    this.archiveAt = DateTime.parse(meta["archive_timestamp"] as String);
    this.archiveAfter = ThreadArchiveTime(meta["auto_archive_duration"] as int);
    this.invitable = raw["invitable"] as bool;
  }

  /// Fetches from API current list of member that has access to that thread
  @override
  Stream<IThreadMember> fetchMembers() =>
      client.httpEndpoints.getThreadMembers(this.id, this.guild.id);

  @override
  Future<void> bulkRemoveMessages(Iterable<SnowflakeEntity> messages) =>
      client.httpEndpoints.bulkRemoveMessages(this.id, messages);

  @override
  Stream<IMessage> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before}) =>
      client.httpEndpoints.downloadMessages(this.id, limit: limit, after: after, around: around, before: before);

  @override
  Future<IMessage> fetchMessage(Snowflake messageId) async {
    final message = await client.httpEndpoints.fetchMessage(this.id, messageId);

    if(client.cacheOptions.messageCachePolicyLocation.http && client.cacheOptions.messageCachePolicy.canCache(message)) {
      this.messageCache.put(message);
    }

    return message;
  }
  @override
  IMessage? getMessage(Snowflake id) => this.messageCache[id];

  @override
  Future<IMessage> sendMessage(MessageBuilder builder) =>
      client.httpEndpoints.sendMessage(this.id, builder);

  @override
  Future<void> startTyping() async =>
      client.httpEndpoints.triggerTyping(this.id);

  @override
  void startTypingLoop() {
    startTyping();
    this._typing = Timer.periodic(const Duration(seconds: 7), (Timer t) => startTyping());
  }

  @override
  void stopTypingLoop() => this._typing?.cancel();

  /// Leaves this thread channel
  @override
  Future<void> leaveThread() => client.httpEndpoints.leaveGuild(this.id);

  /// Removes [user] from [ThreadChannel]
  @override
  Future<void> removeThreadMember(SnowflakeEntity user) =>
      client.httpEndpoints.removeThreadMember(this.id, user.id);

  /// Adds [user] to [ThreadChannel]
  @override
  Future<void> addThreadMember(SnowflakeEntity user) =>
      client.httpEndpoints.addThreadMember(this.id, user.id);

  @override
  Stream<IMessage> fetchPinnedMessages() =>
      client.httpEndpoints.fetchPinnedMessages(this.id);
}
