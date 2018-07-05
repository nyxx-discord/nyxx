part of nyxx;

/// Emitted when a user adds a reaction to a message.
class MessageReactionAddedEvent {
  /// User who fired event
  User user;

  /// Channel on which event was fired
  Channel channel;

  /// Message to which emojis was added
  Message message;

  /// Emoji ebject
  Emoji emoji;
}