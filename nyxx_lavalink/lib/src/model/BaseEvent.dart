part of nyxx_lavalink;

/// Base event class which all events must inherit
class BaseEvent {
  /// A reference to the current client
  final Nyxx client;

  /// A reference to the node this event belongs to
  final Node node;

  /// Creates a new base event instance
  BaseEvent(this.client, this.node);
}