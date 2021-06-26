part of nyxx;

/// Member of [ThreadChannel]
class ThreadMember extends SnowflakeEntity {
  /// Reference to client
  INyxx client;

  /// Reference to [ThreadChannel]
  late final CacheableTextChannel<ThreadChannel> thread;

  /// When member joined thread
  late final DateTime joinTimestamp;

  /// Any user-thread settings, currently only used for notifications
  late final int flags;

  /// [ThreadMember]s [Guild]
  final Cacheable<Snowflake, Guild> guild;

  /// [Cacheable] of [User]
  Cacheable<Snowflake, User> get user => _UserCacheable(this.client, this.id);

  /// [Cacheable] of [Member]
  Cacheable<Snowflake, Member> get member => _MemberCacheable(this.client, this.id, this.guild);

  ThreadMember._new(this.client, RawApiMap raw, this.guild): super(Snowflake(raw["user_id"])) {
    this.thread = CacheableTextChannel._new(client, Snowflake(raw["id"]));
    this.joinTimestamp = DateTime.parse(raw["join_timestamp"] as String);
    this.flags = raw["flags"] as int;
  }
}

class ThreadChannel extends MinimalGuildChannel implements TextChannel {
  Timer? _typing;

  /// Owner of the thread
  late final Cacheable<Snowflake, Member> owner;

  /// Approximate message count
  late final int messageCount;

  /// Approximate member count
  late final int memberCount;

  /// True if thread is archived
  late final bool archived;

  /// Date when thread was archived
  late final DateTime archiveAt;

  /// Time after what thread will be archived
  late final ThreadArchiveTime archiveAfter;

  @override
  Future<int> get fileUploadLimit async {
    final guildInstance = await this.guild.getOrDownload();
    return guildInstance.fileUploadLimit;
  }

  @override
  late final MessageCache messageCache = MessageCache._new(client._options.messageCacheSize);

  ThreadChannel._new(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super._new(client, raw) {
    this.owner = new _MemberCacheable(client, Snowflake(raw["owner_id"]), this.guild);

    this.messageCount = raw["message_count"] as int;
    this.memberCount = raw["member_count"] as int;

    final meta = raw["thread_metadata"];
    this.archived = meta["archived"] as bool;
    this.archiveAt = DateTime.parse(meta["archive_timestamp"] as String);
    this.archiveAfter = ThreadArchiveTime._new(meta["auto_archive_duration"] as int);
  }

  /// Fetches from API current list of member that has access to that thread
  Stream<ThreadMember> fetchMembers() =>
      client.httpEndpoints.getThreadMembers(this.id, this.guild.id);

  @override
  Future<void> bulkRemoveMessages(Iterable<SnowflakeEntity> messages) =>
      client.httpEndpoints.bulkRemoveMessages(this.id, messages);

  @override
  Stream<Message> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before}) =>
      client.httpEndpoints.downloadMessages(this.id, limit: limit, after: after, around: around, before: before);

  @override
  Future<Message> fetchMessage(Snowflake messageId) =>
      client.httpEndpoints.fetchMessage(this.id, messageId);

  @override
  Message? getMessage(Snowflake id) => this.messageCache[id];

  @override
  Future<Message> sendMessage(MessageBuilder builder) =>
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
  Future<void> leaveThread() => client.httpEndpoints.leaveGuild(this.id);

  /// Removes [user] from [ThreadChannel]
  Future<void> removeThreadMember(SnowflakeEntity user) =>
      client.httpEndpoints.removeThreadMember(this.id, user.id);

  /// Adds [user] to [ThreadChannel]
  Future<void> addThreadMember(SnowflakeEntity user) =>
      client.httpEndpoints.addThreadMember(this.id, user.id);
}
