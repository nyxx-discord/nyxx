part of nyxx.commands;

/// Execution context of command.
class CommandContext {
  /// Channel from where message come from
  MessageChannel channel;

  /// Author of message
  User author;

  /// Message that was sent
  Message message;

  /// Guild in which message was sent
  Guild guild;

  CommandContext._new(this.channel, this.author, this.message, this.guild);
}
