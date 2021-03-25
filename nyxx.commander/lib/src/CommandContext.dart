part of nyxx_commander;

/// Helper class which describes context in which command is executed
class CommandContext {
  /// Channel from where message come from
  final TextChannel channel;

  /// Author of message
  final IMessageAuthor author;

  /// Message that was sent
  final Message message;

  /// Guild in which message was sent
  final Guild? guild;

  /// Returns author as guild member
  Member? get member => this.message is GuildMessage
      ? (message as GuildMessage).member
      : null;

  /// Reference to client
  Nyxx get client => channel.client as Nyxx;

  /// Shard on which message was sent
  int get shardId => this.guild != null ? this.guild!.shard.id : 0;

  /// Returns shard on which message was sent
  Shard get shard => this.client.shardManager.shards.toList()[shardId];

  /// Substring by which command was matched
  final String commandMatcher;

  CommandContext._new(this.channel, this.author, this.guild, this.message, this.commandMatcher);

  static final _argumentsRegex = RegExp('([A-Z0-9a-z]+)|["\']([^"]*)["\']');
  static final _quotedTextRegex = RegExp('["\']([^"]*)["\']');
  static final _codeBlocksRegex = RegExp(r"```(\w+)?(\s)?(((.+)(\s)?)+)```");

  /// Creates inline reply for message
  Future<Message> reply({
    dynamic content,
    EmbedBuilder? embed,
    List<AttachmentBuilder>? files,
    bool? tts,
    AllowedMentions? allowedMentions,
    MessageBuilder? builder,
    bool mention = false,
  }) async {
    if (mention) {
      if (allowedMentions != null) {
        allowedMentions.allow(reply: true);
      } else {
        allowedMentions = AllowedMentions()..allow(reply: true);
      }
    }

    return channel.sendMessage(content: content, embed: embed, tts: tts, allowedMentions: allowedMentions, builder: builder, replyBuilder: ReplyBuilder.fromMessage(this.message));
  }

  /// Reply to message. It allows to send regular message, Embed or both.
  ///
  /// ```
  /// Future<void> getAv(CommandContext context) async {
  ///   await context.reply(content: context.user.avatarURL());
  /// }
  /// ```
  Future<Message> sendMessage({
    dynamic content,
    EmbedBuilder? embed,
    List<AttachmentBuilder>? files,
    bool? tts,
    AllowedMentions? allowedMentions,
    MessageBuilder? builder,
    ReplyBuilder? replyBuilder,
  }) => channel.sendMessage(
        content: content, embed: embed, tts: tts, files: files, builder: builder, allowedMentions: allowedMentions, replyBuilder: replyBuilder);

  /// Reply to messages, then delete it when [duration] expires.
  ///
  /// ```
  /// Future<void> getAv(CommandContext context) async {
  ///   await context.replyTemp(content: user.avatarURL());
  /// }
  /// ```
  Future<Message> sendMessageTemp(Duration duration, {
    dynamic content,
    EmbedBuilder? embed,
    List<AttachmentBuilder>? files,
    bool? tts,
    AllowedMentions? allowedMentions,
    MessageBuilder? builder,
    ReplyBuilder? replyBuilder
  }) => channel
        .sendMessage(content: content, embed: embed, files: files, tts: tts, builder: builder, allowedMentions: allowedMentions, replyBuilder: replyBuilder)
        .then((msg) {
          Timer(duration, () => msg.delete());
          return msg;
      });

  /// Replies to message after delay specified with [duration]
  /// ```
  /// Future<void> getAv(CommandContext context async {
  ///   await context.replyDelayed(Duration(seconds: 2), content: user.avatarURL());
  /// }
  /// ```
  Future<Message> sendMessageDelayed(Duration duration,
      {dynamic content,
        EmbedBuilder? embed,
        List<AttachmentBuilder>? files,
        bool? tts,
        AllowedMentions? allowedMentions,
        MessageBuilder? builder,
        ReplyBuilder? replyBuilder
      }) =>  Future.delayed(
        duration,
        () => channel.sendMessage(
            content: content,
            embed: embed,
            files: files,
            tts: tts,
            builder: builder,
            allowedMentions: allowedMentions,
            replyBuilder: replyBuilder));

  /// Awaits for emoji under given [msg]
  Future<IEmoji> awaitEmoji(Message msg) async =>
      (await this.client.onMessageReactionAdded.where((event) => event.message == msg).first).emoji;

  /// Collects emojis within given [duration]. Returns empty map if no reaction received
  ///
  /// ```
  /// Future<void> getAv(CommandContext context) async {
  ///   final msg = await context.replyDelayed(content: context.user.avatarURL());
  ///   final emojis = await context.awaitEmojis(msg, Duration(seconds: 15));
  ///
  /// }
  /// ```
  Future<Map<IEmoji, int>> awaitEmojis(Message msg, Duration duration){
    final collectedEmoji = <IEmoji, int>{};
    return Future<Map<IEmoji, int>>(() async {
      await for (final event in (msg.client as Nyxx).onMessageReactionAdded.where((evnt) => evnt.message != null && evnt.message!.id == msg.id)) {
        if (collectedEmoji.containsKey(event.emoji)) {
          // TODO: NNBD: weird stuff
          var value = collectedEmoji[event.emoji];

          if (value != null) {
            value += 1;
            collectedEmoji[event.emoji] = value;
          }
        } else {
          collectedEmoji[event.emoji] = 1;
        }
      }

      return collectedEmoji;
    }).timeout(duration, onTimeout: () => collectedEmoji);
  }


  /// Waits for first [TypingEvent] and returns it. If timed out returns null.
  /// Can listen to specific user by specifying [user]
  Future<TypingEvent?> waitForTyping(User user, {Duration timeout = const Duration(seconds: 30)}) =>
      Future<TypingEvent?>(() => (user.client as Nyxx).onTyping.firstWhere((e) => e.user == user && e.channel == this.channel)).timeout(timeout, onTimeout: () => null);

  /// Gets all context channel messages that satisfies [predicate].
  ///
  /// ```
  /// Future<void> getAv(CommandContext context) async {
  ///   final messages = await context.nextMessagesWhere((msg) => msg.content.startsWith("fuck"));
  /// }
  /// ```
  Stream<MessageReceivedEvent> nextMessagesWhere(bool Function(MessageReceivedEvent msg) predicate, {int limit = 1}) =>
    client.onMessageReceived.where((event) => event.message.channel.id == channel.id).where(predicate).take(limit);

  /// Gets next [num] number of any messages sent within one context (same channel).
  ///
  /// ```
  /// Future<void> getAv(CommandContext context) async {
  ///   // gets next 10 messages
  ///   final messages = await context.nextMessages(10);
  /// }
  /// ```
  Stream<MessageReceivedEvent> nextMessages(int num) =>
      client.onMessageReceived.where((event) => event.message.channel.id == channel.id).take(num);

  /// Starts typing loop and ends when [callback] resolves.
  Future<T> enterTypingState<T>(Future<T> Function() callback) async {
    this.channel.startTypingLoop();
    final result = await callback();
    this.channel.stopTypingLoop();

    return result;
  }

  /// Returns list of words separated with space and/or text surrounded by quotes
  /// Text: `hi this is "example stuff" which 'can be parsed'` will return
  /// `List<String> [hi, this, is, example stuff, which, can be parsed]`
  Iterable<String> getArguments() sync* {
    final matches = _argumentsRegex.allMatches(this.message.content.replaceFirst(commandMatcher, ""));

    for(final match in matches) {
      final group1 = match.group(1);

      yield group1 ?? match.group(2)!;
    }
  }

  /// Returns list which content of quotes.
  /// Text: `hi this is "example stuff" which 'can be parsed'` will return
  /// `List<String> [example stuff, can be parsed]`
  Iterable<String> getQuotedText() sync* {
    final matches = _quotedTextRegex.allMatches(this.message.content.replaceFirst(commandMatcher, ""));
    for(final match in matches) {
      yield match.group(1)!;
    }
  }

  /// Returns list of all code blocks in message
  /// Language string `dart, java` will be ignored and not included
  /// """
  /// n> eval ```(dart)?
  ///   await reply(content: 'no to elo');
  /// ```
  /// """
  Iterable<String> getCodeBlocks() sync* {
    final matches = _codeBlocksRegex.allMatches(message.content);
    for (final match in matches) {
      final matchedText = match.group(3);

      if (matchedText != null) {
        yield matchedText;
      }
    }
  }
}
