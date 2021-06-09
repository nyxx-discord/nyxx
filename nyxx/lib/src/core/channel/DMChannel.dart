part of nyxx;

/// Represents private channel with user
class DMChannel extends IChannel implements TextChannel {
  @override
  late final MessageCache messageCache = MessageCache._new(client._options.messageCacheSize);

  @override
  Future<int> get fileUploadLimit async => 8 * 1024 * 1024;

  // Used to create infinite typing loop
  Timer? _typing;

  /// True if channel is group dm
  bool get isGroupDM => this.participants.length > 1;

  /// List of participants in channel. If not group dm channel it will only return other user in chat.
  late final Iterable<User> participants;

  /// Returns other user in chat if channel is not group dm. Will throw [ArgumentError] if channel is group dm.
  User get participant => !this.isGroupDM ? participants.first : throw new ArgumentError("Channel is not direct DM");

  DMChannel._new(INyxx client, Map<String, dynamic> raw): super._new(client, raw) {
    if (raw["recipients"] != null) {
      this.participants = [
        for (final userRaw in raw["recipients"])
          User._new(this.client, userRaw as Map<String, dynamic>)
      ];
    } else {
      this.participants = [
        User._new(client, raw["recipient"] as Map<String, dynamic>)
      ];
    }
  }

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
      client.httpEndpoints.sendMessage(this.id,builder);

}
