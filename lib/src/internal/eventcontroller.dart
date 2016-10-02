import 'dart:async';
import '../../discord.dart';

/// A controller for all events.
class EventController {
  /// Emitted when the client is ready.
  StreamController<ReadyEvent> onReady;

  /// Emitted when a message is received.
  StreamController<MessageEvent> onMessage;

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

  /// Emitted when a user starts typing.
  StreamController<TypingEvent> onTyping;

  /// Makes a new `EventController`.
  EventController(Client client) {
    this.onReady = new StreamController.broadcast();
    client.onReady = this.onReady.stream;

    this.onMessage = new StreamController.broadcast();
    client.onMessage = this.onMessage.stream;

    this.onMessageUpdate = new StreamController.broadcast();
    client.onMessageUpdate = this.onMessageUpdate.stream;

    this.onMessageDelete = new StreamController.broadcast();
    client.onMessageDelete = this.onMessageDelete.stream;

    this.onChannelCreate = new StreamController.broadcast();
    client.onChannelCreate = this.onChannelCreate.stream;

    this.onChannelUpdate = new StreamController.broadcast();
    client.onChannelUpdate = this.onChannelUpdate.stream;

    this.onChannelDelete = new StreamController.broadcast();
    client.onChannelDelete = this.onChannelDelete.stream;

    this.onGuildBanAdd = new StreamController.broadcast();
    client.onGuildBanAdd = this.onGuildBanAdd.stream;

    this.onGuildBanRemove = new StreamController.broadcast();
    client.onGuildBanRemove = this.onGuildBanRemove.stream;

    this.onGuildCreate = new StreamController.broadcast();
    client.onGuildCreate = this.onGuildCreate.stream;

    this.onGuildUpdate = new StreamController.broadcast();
    client.onGuildUpdate = this.onGuildUpdate.stream;

    this.onGuildDelete = new StreamController.broadcast();
    client.onGuildDelete = this.onGuildDelete.stream;

    this.onGuildUnavailable = new StreamController.broadcast();
    client.onGuildUnavailable = this.onGuildUnavailable.stream;

    this.onGuildMemberAdd = new StreamController.broadcast();
    client.onGuildMemberAdd = this.onGuildMemberAdd.stream;

    this.onGuildMemberUpdate = new StreamController.broadcast();
    client.onGuildMemberUpdate = this.onGuildMemberUpdate.stream;

    this.onGuildMemberRemove = new StreamController.broadcast();
    client.onGuildMemberRemove = this.onGuildMemberRemove.stream;

    this.onTyping = new StreamController.broadcast();
    client.onTyping = this.onTyping.stream;
  }

  /// Closes all streams.
  Future<Null> destroy() async {
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
    await this.onTyping.close();
    return null;
  }
}
