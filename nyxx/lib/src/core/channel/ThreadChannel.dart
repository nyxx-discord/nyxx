part of nyxx;

class ThreadChannel extends MinimalGuildChannel implements TextChannel {

  Timer? _typing;

  late final _MemberCacheable owner;

  /// Approximate message count
  late final int messageCount;

  /// Approximate member count
  late final int memberCount;

  /// Is null until [updateMembers] is called, then it contains a list of all members in the thread.
  late final List<_MemberCacheable> members;

  late final bool archived;

  late final DateTime archiveAt;

  late final ThreadArchiveTime archiveAfter;

  // TODO add more features

  ThreadChannel._new(INyxx client, Map<String, dynamic> raw, [Snowflake? guildId]) : super._new(client, raw) {
    this.owner = new _MemberCacheable(client, Snowflake(raw["owner_id"]), this.guild);

    this.messageCount = raw["message_count"] as int;
    this.memberCount = raw["member_count"] as int;

    final meta = raw["thread_metadata"];
    this.archived = meta["archived"] as bool;
    this.archiveAt = DateTime.parse(meta["archive_timestamp"] as String);
    this.archiveAfter = ThreadArchiveTime._new(meta["auto_archive_duration"] as int);
  }

  /// Update [members] with the latest information from the API
  Future<void> updateMembers() async => this.members = await client._httpEndpoints.getThreadMembers(this.id, this.guild.id);

  @override
  Future<void> bulkRemoveMessages(Iterable<SnowflakeEntity> messages) =>
      client._httpEndpoints.bulkRemoveMessages(this.id, messages);

  @override
  Stream<Message> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before}) =>
      client._httpEndpoints.downloadMessages(this.id, limit: limit, after: after, around: around, before: before);

  @override
  Future<Message> fetchMessage(Snowflake messageId) =>
      client._httpEndpoints.fetchMessage(this.id, messageId);

  @override
  Message? getMessage(Snowflake id) => this.messageCache[id];

  @override
  Future<Message> sendMessage(MessageBuilder builder) =>
      client._httpEndpoints.sendMessage(this.id, builder);

  @override
  Future<int> get fileUploadLimit async {
    final guildInstance = await this.guild.getOrDownload();

    return guildInstance.fileUploadLimit;
  }

  @override
  late final MessageCache messageCache = MessageCache._new(client._options.messageCacheSize);

  @override
  Future<void> startTyping() async =>
      client._httpEndpoints.triggerTyping(this.id);

  @override
  void startTypingLoop() {
    startTyping();
    this._typing = Timer.periodic(const Duration(seconds: 7), (Timer t) => startTyping());
  }

  @override
  void stopTypingLoop() => this._typing?.cancel();
}
