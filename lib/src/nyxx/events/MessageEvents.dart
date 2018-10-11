part of nyxx;

/// Sent when a new message is received.
class MessageEvent {
  /// The new message.
  Message message;

  MessageEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      this.message = Message._new(json['d'] as Map<String, dynamic>);
      client._events.onMessage.add(this);
      message.channel._onMessage.add(this);
    }
  }
}

/// Sent when a message is deleted.
class MessageDeleteEvent {
  /// The message, if cached.
  Message message;

  /// The ID of the message.
  Snowflake id;

  MessageDeleteEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      if ((client.channels[Snowflake(json['d']['channel_id'] as String)]
      as MessageChannel)
          .messages[Snowflake(json['d']['id'] as String)] !=
          null) {
        this.message =
        (client.channels[Snowflake(json['d']['channel_id'] as String)]
        as MessageChannel)
            .messages[Snowflake(json['d']['id'] as String)];
        this.id = message.id;
        this.message._onDelete.add(this);
        client._events.onMessageDelete.add(this);
      } else {
        this.id = Snowflake((json['d']['id'] as String));
        client._events.onMessageDelete.add(this);
      }
    }
  }
}

/// Emitted when multiple messages are deleted at once.
class MessageDeleteBulkEvent {
  /// List of deleted messages
  List<Snowflake> deletedMessages = List();

  /// Channel on which messages was deleted.
  Channel channel;

  MessageDeleteBulkEvent._new(Map<String, dynamic> json) {
    this.channel =
    client.channels[Snowflake(json['d']['channel_id'] as String)];

    json['d']['ids']
        .forEach((i) => deletedMessages.add(Snowflake(i.toString())));
    client._events.onMessageDeleteBulk.add(this);
  }
}

class MessageReactionEvent {
  /// User who fired event
  User user;

  /// Channel on which event was fired
  MessageChannel channel;

  /// Message to which emoji was added
  Message message;

  /// Emoji object.
  Emoji emoji;

  MessageReactionEvent._new(Map<String, dynamic> json, bool remove) {
    this.user = client.users[Snowflake(json['d']['user_id'] as String)];
    this.channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
    as MessageChannel;

    channel
        .getMessage(Snowflake(json['d']['message_id'] as String))
        .then((msg) {
      message = msg;

      if (json['d']['emoji']['id'] == null)
        emoji = UnicodeEmoji((json['d']['emoji']['name'] as String));
      else
        emoji = GuildEmoji._partial(json['d']['emoji'] as Map<String, dynamic>);

      if (remove) {
        this.message._onReactionRemove.add(this);
        client._events.onMessageReactionRemove.add(this);
      } else {
        this.message._onReactionAdded.add(this);
        client._events.onMessageReactionAdded.add(this);
      }
    });
  }
}

/// Emitted when all reaction are removed
class MessageReactionsRemovedEvent {
  /// Channel where reactions are removed
  MessageChannel channel;

  /// Message on which messages are removed
  Message message;

  /// Guild where event occurs
  Guild guild;

  MessageReactionsRemovedEvent._new(Map<String, dynamic> json) {
    this.channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
    as MessageChannel;

    this.guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];

    channel
        .getMessage(Snowflake(json['d']['message_id'] as String))
        .then((msg) => message = msg);

    client._events.onMessageReactionsRemoved.add(this);
  }
}

/// Sent when a message is updated.
class MessageUpdateEvent {
  /// The old message, if cached.
  Message oldMessage;

  /// Edited message
  Message newMessage;

  MessageUpdateEvent._new(Map<String, dynamic> json) {
    var channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
    as MessageChannel;
    this.oldMessage = channel.messages[Snowflake(json['d']['id'] as String)];
    this.newMessage = Message._new(json['d'] as Map<String, dynamic>);

    if (oldMessage != null) this.oldMessage._onUpdate.add(this);
    client._events.onMessageUpdate.add(this);

    channel.messages._cacheMessage(newMessage);
  }
}

