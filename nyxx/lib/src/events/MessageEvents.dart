part of nyxx;

/// Generic message event
abstract class MessageEvent {
  /// Message object associated with event
  late final Message? message;
}

/// Sent when a new message is received.
class MessageReceivedEvent extends MessageEvent {
  /// The new message.
  @override
  late final Message? message;

  MessageReceivedEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.message = Message._new(json['d'] as Map<String, dynamic>, client);
    message!.channel.messages.put(this.message!);}
}

/// Sent when a message is deleted.
class MessageDeleteEvent extends MessageEvent {
  @override

  /// The message, if cached.
  late final Message? message;

  /// The ID of the message.
  late final Snowflake? id;

  MessageDeleteEvent._new(Map<String, dynamic> json, Nyxx client) {
    if ((client.channels[Snowflake(json['d']['channel_id'] as String)]
                as MessageChannel)
            .messages[Snowflake(json['d']['id'] as String)] !=
        null) {

      /// TODO: NNBD - To consider
      this.message = (client.channels[Snowflake(json['d']['channel_id'] as String)] as MessageChannel).messages[Snowflake(json['d']['id'] as String)];

      this.id = message?.id;
    } else {
      this.id = Snowflake((json['d']['id'] as String));
    }

    if(this.id != null) {
      message?.channel.messages.remove(this.id!);
    }
  }
}

class MessageReactionEvent extends MessageEvent {
  /// User who fired event
  User? user;

  /// Channel on which event was fired
  late MessageChannel channel;

  @override

  /// Message to which emoji was added
  late final Message? message;

  /// Emoji object.
  late final Emoji? emoji;

  MessageReactionEvent._new(
      Map<String, dynamic> json, Nyxx client, bool added) {
    this.user = client.users[Snowflake(json['d']['user_id'] as String)];
    this.channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
        as MessageChannel;

    var msg = channel.messages[Snowflake(json['d']['message_id'] as String)];
    if (msg == null) return;

    this.message = msg;

    if (json['d']['emoji']['id'] == null)
      emoji = UnicodeEmoji((json['d']['emoji']['name'] as String));
    else
      emoji = GuildEmoji._partial(json['d']['emoji'] as Map<String, dynamic>);

    if (added) {
      var r = message!.reactions.indexWhere((r) => r.emoji == emoji);

      if (r == -1) {
        var reaction = Reaction._event(emoji!, user == client.self);
        message!.reactions.add(reaction);
      } else
        message!.reactions[r].count++;

      if (this.message != null) {
        client._events.onMessageReactionAdded.add(this);
        client._events.onMessage.add(this);
      }
    } else {
      var r = message!.reactions.indexWhere((r) => r.emoji == emoji);

      if (r != -1) {
        if (message!.reactions[r].count == 1)
          message!.reactions.removeAt(r);
        else
          message!.reactions[r].count--;
      }

      if (this.message != null) {
        client._events.onMessageReactionRemove.add(this);
        client._events.onMessage.add(this);
      }
    }
  }
}

/// Emitted when all reaction are removed
class MessageReactionsRemovedEvent extends MessageEvent {
  /// Channel where reactions are removed
  late final MessageChannel? channel;

  @override

  /// Message on which messages are removed
  late final Message? message;

  /// Guild where event occurs
  late final Guild? guild;

  MessageReactionsRemovedEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
        as MessageChannel;
    this.guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];
    this.message = channel?.messages[Snowflake(json['d']['message_id'] as String)];
  }
}

class MessageReactionRemoveEmojiEvent extends MessageEvent {
  /// Channel where reactions are removed
  late final MessageChannel? channel;

  @override

  /// Message on which messages are removed
  late final Message? message;

  /// Guild where event occurs
  late final Guild? guild;

  /// The emoji that was removed
  late final Emoji? emoji;

  MessageReactionRemoveEmojiEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.channel = client.channels[Snowflake(json['d']['channel_id'])] as MessageChannel?;
    this.message = channel?.messages[Snowflake(json['d']['message_id'])];

    if(json['d']['guild_id'] != null) {
      this.guild = client.guilds[Snowflake(json['d']['guild_id'])];

      this.emoji = this.guild?.emojis[Snowflake(json['d']['emoji']['id'])];
    }
  }
}

/// Emitted when multiple messages are deleted at once.
class MessageDeleteBulkEvent {
  /// List of deleted messages
  List<Snowflake> deletedMessages = List();

  /// Channel on which messages was deleted.
  Channel? channel;

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
  Message? oldMessage;

  /// Edited message
  late final Message newMessage;

  MessageUpdateEvent._new(Map<String, dynamic> json, Nyxx client) {
    var channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
        as MessageChannel;

    this.oldMessage = channel.messages[Snowflake(json['d']['id'] as String)];
    this.newMessage = Message._new(json['d'] as Map<String, dynamic>, client);

    if (oldMessage != newMessage) {
      channel.messages._cacheMessage(newMessage);
      client._events.onMessageUpdate.add(this);
    }
  }
}
