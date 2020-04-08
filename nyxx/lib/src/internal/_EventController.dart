part of nyxx;

/// A controller for all events.
class _EventController implements Disposable {
  /// Emitted when a raw packet is received from the websocket connection.
  late final StreamController<RawEvent> onRaw;

  /// Emitted when a shard is disconnected from the websocket.
  late final StreamController<DisconnectEvent> onDisconnect;

  /// Emitted before all HTTP requests are sent. (You can edit them)
  ///
  /// **WARNING:** Once you listen to this stream, all requests
  /// will be halted until you call `request.send()`
  late final StreamController<BeforeHttpRequestSendEvent> beforeHttpRequestSend;

  /// Emitted when a successful HTTP response is received.
  late final StreamController<HttpResponseEvent> onHttpResponse;

  /// Emitted when a HTTP request failed.
  late final StreamController<HttpErrorEvent> onHttpError;

  /// Sent when the client is ratelimited, either by the ratelimit handler itself,
  /// or when a 429 is received.
  late final StreamController<RatelimitEvent> onRatelimited;

  /// Emitted when the client is ready.
  late final StreamController<ReadyEvent> onReady;

  /// Emitted when a message is received.
  late final StreamController<MessageReceivedEvent> onMessageReceived;

  /// Emitted when channel's pins are updated.
  late final StreamController<ChannelPinsUpdateEvent> onChannelPinsUpdate;

  /// Emitted when guild's emojis are changed.
  late final StreamController<GuildEmojisUpdateEvent> onGuildEmojisUpdate;

  /// Emitted when a message is edited.
  late final StreamController<MessageUpdateEvent> onMessageUpdate;

  /// Emitted when a message is edited.
  late final StreamController<MessageDeleteEvent> onMessageDelete;

  /// Emitted when a channel is created.
  late final StreamController<ChannelCreateEvent> onChannelCreate;

  /// Emitted when a channel is updated.
  late final StreamController<ChannelUpdateEvent> onChannelUpdate;

  /// Emitted when a channel is deleted.
  late final StreamController<ChannelDeleteEvent> onChannelDelete;

  /// Emitted when a member is banned.
  late final StreamController<GuildBanAddEvent> onGuildBanAdd;

  /// Emitted when a user is unbanned.
  late final StreamController<GuildBanRemoveEvent> onGuildBanRemove;

  /// Emitted when the client joins a guild.
  late final StreamController<GuildCreateEvent> onGuildCreate;

  /// Emitted when a guild is updated..
  late final StreamController<GuildUpdateEvent> onGuildUpdate;

  /// Emitted when the client leaves a guild.
  late final StreamController<GuildDeleteEvent> onGuildDelete;

  /// Emitted when a guild becomes unavailable.
  late final StreamController<GuildUnavailableEvent> onGuildUnavailable;

  /// Emitted when a member joins a guild.
  late final StreamController<GuildMemberAddEvent> onGuildMemberAdd;

  /// Emitted when a member is updated.
  late final StreamController<GuildMemberUpdateEvent> onGuildMemberUpdate;

  /// Emitted when a user leaves a guild.
  late final StreamController<GuildMemberRemoveEvent> onGuildMemberRemove;

  /// Emitted when a member's presence is updated.
  late final StreamController<PresenceUpdateEvent> onPresenceUpdate;

  /// Emitted when a user starts typing.
  late final StreamController<TypingEvent> onTyping;

  /// Emitted when a role is updated.
  late final StreamController<RoleCreateEvent> onRoleCreate;

  /// Emitted when a role is created.
  late final StreamController<RoleUpdateEvent> onRoleUpdate;

  /// Emitted when a role is deleted.
  late final StreamController<RoleDeleteEvent> onRoleDelete;

  /// Emitted when many messages are deleted at once
  late final StreamController<MessageDeleteBulkEvent> onMessageDeleteBulk;

  /// Emitted when a user adds a reaction to a message.
  late final StreamController<MessageReactionEvent> onMessageReactionAdded;

  /// Emitted when a user deletes a reaction to a message.
  late final StreamController<MessageReactionEvent> onMessageReactionRemove;

  /// Emitted when a user explicitly removes all reactions from a message.
  late final StreamController<MessageReactionsRemovedEvent> onMessageReactionsRemoved;

  /// Emitted when someone joins/leaves/moves voice channels.
  late final StreamController<VoiceStateUpdateEvent> onVoiceStateUpdate;

  /// Emitted when a guild's voice server is updated. This is sent when initially connecting to voice, and when the current voice instance fails over to a new server.
  late final StreamController<VoiceServerUpdateEvent> onVoiceServerUpdate;

  /// Emitted when user was updated
  late final StreamController<UserUpdateEvent> onUserUpdate;

  /// Emitted on any message related event
  late final StreamController<MessageEvent> onMessage;

  /// Emitted when invite is creating
  late final StreamController<InviteCreatedEvent> onInviteCreated;

  /// Emitted when invite is deleted
  late final StreamController<InviteDeletedEvent> onInviteDelete;

  /// Emitted when a bot removes all instances of a given emoji from the reactions of a message
  late final StreamController<MessageReactionRemoveEmojiEvent> onMessageReactionRemoveEmoji;

  /// Makes a new `EventController`.
  _EventController(Nyxx _client) {
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

    this.onMessageReceived = StreamController.broadcast();
    _client.onMessageReceived = this.onMessageReceived.stream;

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

    this.onUserUpdate = StreamController.broadcast();
    _client.onUserUpdate = this.onUserUpdate.stream;

    this.onMessage = StreamController.broadcast();
    _client.onMessage = this.onMessage.stream;

    this.onInviteCreated = StreamController.broadcast();
    _client.onInviteCreated = this.onInviteCreated.stream;

    this.onInviteDelete = StreamController.broadcast();
    _client.onInviteDeleted = this.onInviteDelete.stream;

    this.onMessageReactionRemoveEmoji = StreamController.broadcast();
    _client.onMessageReactionRemoveEmoji = this.onMessageReactionRemoveEmoji.stream;
  }

  @override
  Future<void> dispose() async {
    this.onRaw.close();
    this.onDisconnect.close();
    this.beforeHttpRequestSend.close();
    this.onHttpResponse.close();
    this.onHttpError.close();
    this.onRatelimited.close();
    this.onGuildUpdate.close();
    this.onReady.close();
    this.onMessageReceived.close();
    this.onMessageUpdate.close();
    this.onMessageDelete.close();
    this.onChannelCreate.close();
    this.onChannelUpdate.close();
    this.onChannelDelete.close();
    this.onGuildBanAdd.close();
    this.onGuildBanRemove.close();
    this.onGuildCreate.close();
    this.onGuildUpdate.close();
    this.onGuildDelete.close();
    this.onGuildUnavailable.close();
    this.onGuildMemberAdd.close();
    this.onGuildMemberUpdate.close();
    this.onGuildMemberRemove.close();
    this.onPresenceUpdate.close();
    this.onTyping.close();
    this.onRoleCreate.close();
    this.onRoleUpdate.close();
    this.onRoleDelete.close();

    this.onChannelPinsUpdate.close();
    this.onGuildEmojisUpdate.close();

    this.onMessageDeleteBulk.close();
    this.onMessageReactionAdded.close();
    this.onMessageReactionRemove.close();
    this.onMessageReactionsRemoved.close();
    this.onVoiceStateUpdate.close();
    this.onVoiceServerUpdate.close();
    this.onMessageReactionRemoveEmoji.close();

    this.onInviteCreated.close();
    this.onInviteDelete.close();

    this.onUserUpdate.close();
  }
}
