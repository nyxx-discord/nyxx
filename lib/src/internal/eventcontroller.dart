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
    return null;
  }
}
