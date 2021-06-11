part of nyxx_lavalink;

/// Base event class which all events must inherit
class BaseEvent {
  /// A reference to the current client
  Nyxx client;

  /// Creates a new base event instance
  BaseEvent(this.client);
}