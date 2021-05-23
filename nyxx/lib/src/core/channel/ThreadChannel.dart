part of nyxx;

class ThreadChannel extends MinimalGuildChannel implements TextChannel {

  Timer? _typing;

  ThreadChannel._new(INyxx client, Map<String, dynamic> raw, [Snowflake? guildId]) : super._new(client, raw) {}

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