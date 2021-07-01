part of nyxx;

class TextGuildChannel extends GuildChannel implements TextChannel, Mentionable {
  /// The channel's topic.
  late final String? topic;

  /// The channel's mention string.
  @override
  String get mention => "<#${this.id}>";

  /// Channel's slow mode rate limit in seconds. This must be between 0 and 120.
  late final int slowModeThreshold;

  /// Returns url to this channel.
  String get url => "https://discordapp.com/channels/${this.guild.id.toString()}"
      "/${this.id.toString()}";

  @override
  late final MessageCache messageCache = MessageCache._new(client._options.messageCacheSize);

  @override
  Future<int> get fileUploadLimit async {
    final guildInstance = await this.guild.getOrDownload();

    return guildInstance.fileUploadLimit;
  }

  // Used to create infinite typing loop
  Timer? _typing;

  TextGuildChannel._new(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super._new(client, raw, guildId) {
    this.topic = raw["topic"] as String?;
    this.slowModeThreshold = raw["rate_limit_per_user"] as int? ?? 0;
  }

  /// Gets all of the webhooks for this channel.
  Stream<Webhook> getWebhooks() =>
      client.httpEndpoints.fetchChannelWebhooks(this.id);

  /// Creates a webhook for channel.
  /// Valid file types for [avatarFile] are jpeg, gif and png.
  ///
  /// ```
  /// final webhook = await channnel.createWebhook("!a Send nudes kek6407");
  /// ```
  Future<Webhook> createWebhook(String name, {File? avatarFile, String? auditReason}) =>
      client.httpEndpoints.createWebhook(this.id, name, avatarFile: avatarFile, auditReason: auditReason);

  /// Returns pinned [Message]s for channel.
  Stream<Message> getPinnedMessages() =>
      client.httpEndpoints.fetchPinnedMessages(this.id);

  /// Edits the channel.
  Future<TextGuildChannel> edit({String? name, String? topic, int? position, int? slowModeThreshold}) =>
      client.httpEndpoints.editTextChannel(this.id, name: name, topic: topic, position: position, slowModeThreshold: slowModeThreshold);

  /// Creates a thread in a channel, that only retrieves a [ThreadPreviewChannel]
  Future<ThreadPreviewChannel> createThread(ThreadBuilder builder) =>
      client.httpEndpoints.createThread(this.id, builder);

  /// Creates a thread in a message
  Future<ThreadChannel> createAndGetThread(ThreadBuilder builder) async {
    final preview = await client.httpEndpoints.createThread(this.id, builder);
    return preview.getThreadChannel().getOrDownload();
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
      client.httpEndpoints.sendMessage(this.id, builder);

  /// Fetches all active threads in this channel
  Future<ThreadListResultWrapper> fetchActiveThreads() =>
      client.httpEndpoints.fetchActiveThreads(this.id);

  /// Fetches joined private and archived thread channels
  Future<ThreadListResultWrapper> fetchJoinedPrivateArchivedThreads({DateTime? before, int? limit}) =>
      client.httpEndpoints.fetchJoinedPrivateArchivedThreads(this.id, before: before, limit: limit);

  /// Fetches private, archived thread channels
  Future<ThreadListResultWrapper> fetchPrivateArchivedThreads({DateTime? before, int? limit}) =>
      client.httpEndpoints.fetchPrivateArchivedThreads(this.id, before: before, limit: limit);

  /// Fetches public, archives thread channels
  Future<ThreadListResultWrapper> fetchPublicArchivedThreads({DateTime? before, int? limit}) =>
      client.httpEndpoints.fetchPublicArchivedThreads(this.id, before: before, limit: limit);
}
