part of nyxx;

/// A controller for all events.
class _EventController {
  /// Emitted when a raw packet is received from the websocket connection.
  StreamController<RawEvent> onRaw;

  /// Emitted when a shard is disconnected from the websocket.
  StreamController<DisconnectEvent> onDisconnect;

  /// Emitted before all HTTP requests are sent. (You can edit them)
  ///
  /// **WARNING:** Once you listen to this stream, all requests
  /// will be halted until you call `request.send()`
  StreamController<BeforeHttpRequestSendEvent> beforeHttpRequestSend;

  /// Emitted when a successful HTTP response is received.
  StreamController<HttpResponseEvent> onHttpResponse;

  /// Emitted when a HTTP request failed.
  StreamController<HttpErrorEvent> onHttpError;

  /// Sent when the client is ratelimited, either by the ratelimit handler itself,
  /// or when a 429 is received.
  StreamController<RatelimitEvent> onRatelimited;

  /// Emitted when the client is ready.
  StreamController<ReadyEvent> onReady;

  /// Emitted when a message is received.
  StreamController<MessageEvent> onMessage;

  /// Emitted when channel's pins are updated.
  StreamController<ChannelPinsUpdateEvent> onChannelPinsUpdate;

  /// Emitted when guild's emojis are changed.
  StreamController<GuildEmojisUpdateEvent> onGuildEmojisUpdate;

  /// Emitted when a message is edited.
  StreamController<MessageUpdateEvent> onMessageUpdate;

  /// Emitted when a message is edited.
  StreamController<MessageDeleteEvent> onMessageDelete;

  /// Emitted when a channel is created.
  StreamController<ChannelCreateEvent> onChannelCreate;

  /// Emitted when a channel is updated.
  StreamController<ChannelUpdateEvent> onChannelUpdate;

  /// Emitted when a channel is deleted.
  StreamController<ChannelDeleteEvent> onChannelDelete;

  /// Emitted when a member is banned.
  StreamController<GuildBanAddEvent> onGuildBanAdd;

  /// Emitted when a user is unbanned.
  StreamController<GuildBanRemoveEvent> onGuildBanRemove;

  /// Emitted when the client joins a guild.
  StreamController<GuildCreateEvent> onGuildCreate;

  /// Emitted when a guild is updated..
  StreamController<GuildUpdateEvent> onGuildUpdate;

  /// Emitted when the client leaves a guild.
  StreamController<GuildDeleteEvent> onGuildDelete;

  /// Emitted when a guild becomes unavailable.
  StreamController<GuildUnavailableEvent> onGuildUnavailable;

  /// Emitted when a member joins a guild.
  StreamController<GuildMemberAddEvent> onGuildMemberAdd;

  /// Emitted when a member is updated.
  StreamController<GuildMemberUpdateEvent> onGuildMemberUpdate;

  /// Emitted when a user leaves a guild.
  StreamController<GuildMemberRemoveEvent> onGuildMemberRemove;

  /// Emitted when a member's presence is updated.
  StreamController<PresenceUpdateEvent> onPresenceUpdate;

  /// Emitted when a user starts typing.
  StreamController<TypingEvent> onTyping;

  /// Emitted when a role is updated.
  StreamController<RoleCreateEvent> onRoleCreate;

  /// Emitted when a role is created.
  StreamController<RoleUpdateEvent> onRoleUpdate;

  /// Emitted when a role is deleted.
  StreamController<RoleDeleteEvent> onRoleDelete;

  /// Emitted when many messages are deleted at once
  StreamController<MessageDeleteBulkEvent> onMessageDeleteBulk;

  /// Emitted when a user adds a reaction to a message.
  StreamController<MessageReactionEvent> onMessageReactionAdded;

  /// Emitted when a user deletes a reaction to a message.
  StreamController<MessageReactionEvent> onMessageReactionRemove;

  /// Emitted when a user explicitly removes all reactions from a message.
  StreamController<MessageReactionsRemovedEvent> onMessageReactionsRemoved;

  /// Emitted when someone joins/leaves/moves voice channels.
  StreamController<VoiceStateUpdateEvent> onVoiceStateUpdate;

  /// Emitted when a guild's voice server is updated. This is sent when initially connecting to voice, and when the current voice instance fails over to a new server.
  StreamController<VoiceServerUpdateEvent> onVoiceServerUpdate;

  /// Emitted when a guild channel's webhook is created, updated, or deleted.
  StreamController<WebhookUpdateEvent> onWebhookUpdate;

  /// Makes a new `EventController`.
  _EventController() {
    this.onRaw = StreamController.broadcast();
    _client.onRaw = this.onRaw.stream;

    this.onDisconnect = StreamController.broadcast();
    _client.onDisconnect = this.onDisconnect.stream;

    this.beforeHttpRequestSend = StreamController();
    _client.beforeHttpRequestSend = this.beforeHttpRequestSend.stream;

    this.onHttpResponse = StreamController.broadcast();
    _client.onHttpResponse = this.onHttpResponse.stream;

    this.onHttpError = StreamController.broadcast();
    _client.onHttpError = this.onHttpError.stream;

    this.onRatelimited = StreamController.broadcast();
    _client.onRatelimited = this.onRatelimited.stream;

    this.onReady = StreamController.broadcast();
    _client.onReady = this.onReady.stream;

    this.onMessage = StreamController.broadcast();
    _client.onMessage = this.onMessage.stream;

    this.onMessageUpdate = StreamController.broadcast();
    _client.onMessageUpdate = this.onMessageUpdate.stream;

    this.onMessageDelete = StreamController.broadcast();
    _client.onMessageDelete = this.onMessageDelete.stream;

    this.onChannelCreate = StreamController.broadcast();
    _client.onChannelCreate = this.onChannelCreate.stream;

    this.onChannelUpdate = StreamController.broadcast();
    _client.onChannelUpdate = this.onChannelUpdate.stream;

    this.onChannelDelete = StreamController.broadcast();
    _client.onChannelDelete = this.onChannelDelete.stream;

    this.onGuildBanAdd = StreamController.broadcast();
    _client.onGuildBanAdd = this.onGuildBanAdd.stream;

    this.onGuildBanRemove = StreamController.broadcast();
    _client.onGuildBanRemove = this.onGuildBanRemove.stream;

    this.onGuildCreate = StreamController.broadcast();
    _client.onGuildCreate = this.onGuildCreate.stream;

    this.onGuildUpdate = StreamController.broadcast();
    _client.onGuildUpdate = this.onGuildUpdate.stream;

    this.onGuildDelete = StreamController.broadcast();
    _client.onGuildDelete = this.onGuildDelete.stream;

    this.onGuildUnavailable = StreamController.broadcast();
    _client.onGuildUnavailable = this.onGuildUnavailable.stream;

    this.onGuildMemberAdd = StreamController.broadcast();
    _client.onGuildMemberAdd = this.onGuildMemberAdd.stream;

    this.onGuildMemberUpdate = StreamController.broadcast();
    _client.onGuildMemberUpdate = this.onGuildMemberUpdate.stream;

    this.onGuildMemberRemove = StreamController.broadcast();
    _client.onGuildMemberRemove = this.onGuildMemberRemove.stream;

    this.onPresenceUpdate = StreamController.broadcast();
    _client.onPresenceUpdate = this.onPresenceUpdate.stream;

    this.onTyping = StreamController.broadcast();
    _client.onTyping = this.onTyping.stream;

    this.onRoleCreate = StreamController.broadcast();
    _client.onRoleCreate = this.onRoleCreate.stream;

    this.onRoleUpdate = StreamController.broadcast();
    _client.onRoleUpdate = this.onRoleUpdate.stream;

    this.onRoleDelete = StreamController.broadcast();
    _client.onRoleDelete = this.onRoleDelete.stream;

    this.onChannelPinsUpdate = StreamController.broadcast();
    _client.onChannelPinsUpdate = this.onChannelPinsUpdate.stream;

    this.onGuildEmojisUpdate = StreamController.broadcast();
    _client.onGuildEmojisUpdate = this.onGuildEmojisUpdate.stream;

    this.onMessageDeleteBulk = StreamController.broadcast();
    _client.onMessageDeleteBulk = this.onMessageDeleteBulk.stream;

    this.onMessageReactionAdded = StreamController.broadcast();
    _client.onMessageReactionAdded = this.onMessageReactionAdded.stream;

    this.onMessageReactionRemove = StreamController.broadcast();
    _client.onMessageReactionRemove = this.onMessageReactionRemove.stream;

    this.onMessageReactionsRemoved = StreamController.broadcast();
    _client.onMessageReactionsRemoved = this.onMessageReactionsRemoved.stream;

    this.onVoiceStateUpdate = StreamController.broadcast();
    _client.onVoiceStateUpdate = this.onVoiceStateUpdate.stream;

    this.onVoiceServerUpdate = StreamController.broadcast();
    _client.onVoiceServerUpdate = this.onVoiceServerUpdate.stream;

    this.onWebhookUpdate = StreamController.broadcast();
    _client.onWebhookUpdate = this.onWebhookUpdate.stream;
  }

  /// Closes all streams.
  Future<Null> destroy() async {
    await this.onRaw.close();
    await this.onDisconnect.close();
    await this.beforeHttpRequestSend.close();
    await this.onHttpResponse.close();
    await this.onHttpError.close();
    await this.onRatelimited.close();
    await this.onGuildUpdate.close();
    await this.onReady.close();
    await this.onMessage.close();
    await this.onMessageUpdate.close();
    await this.onMessageDelete.close();
    await this.onChannelCreate.close();
    await this.onChannelUpdate.close();
    await this.onChannelDelete.close();
    await this.onGuildBanAdd.close();
    await this.onGuildBanRemove.close();
    await this.onGuildCreate.close();
    await this.onGuildUpdate.close();
    await this.onGuildDelete.close();
    await this.onGuildUnavailable.close();
    await this.onGuildMemberAdd.close();
    await this.onGuildMemberUpdate.close();
    await this.onGuildMemberRemove.close();
    await this.onPresenceUpdate.close();
    await this.onTyping.close();
    await this.onRoleCreate.close();
    await this.onRoleUpdate.close();
    await this.onRoleDelete.close();

    await this.onChannelPinsUpdate.close();
    await this.onGuildEmojisUpdate.close();

    await this.onMessageDeleteBulk.close();
    await this.onMessageReactionAdded.close();
    await this.onMessageReactionRemove.close();
    await this.onMessageReactionsRemoved.close();
    await this.onVoiceStateUpdate.close();
    await this.onVoiceServerUpdate.close();
    await this.onWebhookUpdate.close();

    return null;
  }
}
