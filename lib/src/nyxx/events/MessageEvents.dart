part of nyxx;

/// Generic message event
abstract class MessageEvent {
  /// Message object associated with event
  Message message;
}

/// Sent when a new message is received.
class MessageReceivedEvent extends MessageEvent {
  /// The new message.
  @override
  Message message;

  MessageReceivedEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.message = Message._new(json['d'] as Map<String, dynamic>, client);
    message.channel.messages.put(this.message);
  }
}

/// Sent when a message is deleted.
class MessageDeleteEvent extends MessageEvent {
  @override

  /// The message, if cached.
  Message message;

  /// The ID of the message.
  Snowflake id;

  MessageDeleteEvent._new(Map<String, dynamic> json, Nyxx client) {

    if ((client.channels[Snowflake(json['d']['channel_id'] as String)] as MessageChannel)
        .messages[Snowflake(json['d']['id'] as String)] !=
        null) {
      this.message = (client.channels[Snowflake(json['d']['channel_id'] as String)]
      as MessageChannel)
          .messages[Snowflake(json['d']['id'] as String)];
      this.id = message.id;
    } else {
      this.id = Snowflake((json['d']['id'] as String));
    }

    message?.channel?.messages?.remove(this.id);
  }
}

class MessageReactionEvent extends MessageEvent {
  /// User who fired event
  User user;

  /// Channel on which event was fired
  MessageChannel channel;

  @override

  /// Message to which emoji was added
  Message message;

  /// Emoji object.
  Emoji emoji;

  MessageReactionEvent._new(
      Map<String, dynamic> json, Nyxx client, bool added) {
    this.user = client.users[Snowflake(json['d']['user_id'] as String)];
    this.channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
        as MessageChannel;

    channel.getMessage(Snowflake(json['d']['message_id'] as String)).then((msg) {
      if (msg == null)
        return;

      this.message = msg;

      if (json['d']['emoji']['id'] == null)
        emoji = UnicodeEmoji((json['d']['emoji']['name'] as String));
      else
        emoji = GuildEmoji._partial(json['d']['emoji'] as Map<String, dynamic>);

      if (added) {
        var r = message.reactions.indexWhere((r) => r.emoji == emoji);

        if (r == -1) {
          var reaction = Reaction._event(emoji, user == client.self);
          message.reactions.add(reaction);
        } else
          message.reactions[r].count++;

        if (this.message != null) {
          client._events.onMessageReactionAdded.add(this);
          client._events.onMessage.add(this);
          message._onReactionAdded.add(this);
        }
      } else {
        var r = message.reactions.indexWhere((r) => r.emoji == emoji);

        if (r != -1) {
          if (message.reactions[r].count == 1)
            message.reactions.removeAt(r);
          else
            message.reactions[r].count--;
        }

        if (this.message != null) {
          client._events.onMessageReactionRemove.add(this);
          client._events.onMessage.add(this);
          message._onReactionRemove.add(this);
        }
      }
    });
  }
}

/// Emitted when all reaction are removed
class MessageReactionsRemovedEvent extends MessageEvent {
  /// Channel where reactions are removed
  MessageChannel channel;

  @override

  /// Message on which messages are removed
  Message message;

  /// Guild where event occurs
  Guild guild;

  MessageReactionsRemovedEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
        as MessageChannel;

    this.guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];

    channel
        .getMessage(Snowflake(json['d']['message_id'] as String))
        .then((msg) => message = msg);
  }
}

/// Emitted when multiple messages are deleted at once.
class MessageDeleteBulkEvent {
  /// List of deleted messages
  List<Snowflake> deletedMessages = List();

  /// Channel on which messages was deleted.
  Channel channel;

  MessageDeleteBulkEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.channel =
        client.channels[Snowflake(json['d']['channel_id'] as String)];

    json['d']['ids']
        .forEach((i) => deletedMessages.add(Snowflake(i.toString())));
    client._events.onMessageDeleteBulk.add(this);
  }
}

// TODO: Complete
/// Sent when a message is updated.
class MessageUpdateEvent {
  /// The old message, if cached.
  Message oldMessage;

  /// Edited message
  Message newMessage;

  MessageUpdateEvent._new(Map<String, dynamic> json, Nyxx client) {
    var channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
        as MessageChannel;

    this.oldMessage = channel.messages[Snowflake(json['d']['id'] as String)];
    this.newMessage = Message._new(json['d'] as Map<String, dynamic>, client);

    channel.messages._cacheMessage(newMessage);
  }
}
