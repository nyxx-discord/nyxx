part of nyxx.commander;

/// Helper class which describes context in which command is executed
class CommandContext {
  /// Channel from where message come from
  MessageChannel channel;

  /// Author of message
  IMessageAuthor? author;

  /// Message that was sent
  Message message;

  /// Guild in which message was sent
  Guild? guild;

  /// Returns author as guild member
  Member? get member => guild?.members[author!.id];

  CommandContext._new(this.channel, this.author, this.guild, this.message);
}