part of nyxx;

/// Given when a thread is created as only partial information is available. If you want the final channel use [getThreadChannel]
class ThreadPreviewChannel extends IChannel implements TextChannel {
  Timer? _typing;
  late final INyxx _client;

  /// Name of the channel
  late final String name;

  /// Approximate message count
  late final int messageCount;

  /// Approximate member count
  late final int memberCount;

  /// Guild where the thread is located
  late final Cacheable<Snowflake, Guild> guild;

  /// The text channel where the thread was made
  late final CacheableTextChannel parentChannel;

  /// Initial author of the thread
  late final Cacheable<Snowflake, Member> owner;

  /// Preview of initial members
  late final List<Cacheable<Snowflake, Member>> memberPreview;

  /// If the thread has been archived
  late final bool archived;

  /// When the thread will be archived
  late final DateTime archivedTime;

  /// How long till the thread is archived
  late final ThreadArchiveTime archivedAfter;

  ThreadPreviewChannel._new(INyxx this._client, RawApiMap raw) : super._new(_client, raw) {
    this.name = raw["name"] as String;
    this.messageCount = raw["message_count"] as int;
    this.memberCount = raw["member_count"] as int;
    this.parentChannel = CacheableTextChannel._new(client, Snowflake(raw["parent_id"]));
    this.guild = CacheUtility.createCacheableGuild(client, Snowflake(raw["guild_id"]));
    this.owner = CacheUtility.createCacheableMember(client, Snowflake(raw["owner_id"]), this.guild);
    this.memberPreview = [];
    if(raw["member_ids_preview"] != null) {
      for(final String id in raw["member_ids_preview"] as List<String>) {
        this.memberPreview.add(CacheUtility.createCacheableMember(client, Snowflake(id), this.guild));
      }
    }
    final metadata = raw["thread_metadata"] as RawApiMap;

    this.archived = metadata["archived"] as bool;
    this.archivedTime = DateTime.parse(metadata["archive_timestamp"] as String);
    this.archivedAfter = ThreadArchiveTime._new(metadata["auto_archive_duration"] as int);
  }

  /// Get the actual thread channel from the preview
  _ChannelCacheable<ThreadChannel> getThreadChannel() => new _ChannelCacheable(_client, this.id);

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
  Future<int> get fileUploadLimit async {
    final guildInstance = await this.guild.getOrDownload();

    return guildInstance.fileUploadLimit;
  }

  @override
  late final MessageCache messageCache = MessageCache._new(0);

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

  @override
  Stream<Message> fetchPinnedMessages() =>
      client.httpEndpoints.fetchPinnedMessages(this.id);
}
