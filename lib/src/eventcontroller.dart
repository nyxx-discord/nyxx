import 'dart:async';
import '../discord.dart';

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
  }

  Future<Null> destroy() async {
    await this.onReady.close();
    await this.onMessage.close();
    await this.onMessageUpdate.close();
    await this.onMessageDelete.close();
    return null;
  }
}
