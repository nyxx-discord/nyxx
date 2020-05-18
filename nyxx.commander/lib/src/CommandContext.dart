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

  /// Reply to message. It allows to send regular message, Embed or both.
  ///
  /// ```
  /// /// Class body
  /// @Command()
  /// Future<void> getAv(CommandContext context, String message) async {
  ///   await context.reply(content: uset.avatarURL());
  /// }
  /// ```
  Future<Message> reply(
      {dynamic content,
      List<AttachmentBuilder>? files,
      EmbedBuilder? embed,
      bool? tts,
      AllowedMentions? allowedMentions,
      MessageBuilder? builder}) => channel.send(
        content: content, embed: embed, tts: tts, files: files, builder: builder, allowedMentions: allowedMentions);

  /// Reply to messages, then delete it when [duration] expires.
  ///
  /// ```
  /// @Command()
  /// Future<void> getAv(CommandContext context, String message) async {
  ///   await context.replyTemp(content: user.avatarURL());
  /// }
  /// ```
  Future<Message> replyTemp(Duration duration,
      {dynamic content, List<AttachmentBuilder>? files, EmbedBuilder? embed, bool? tts, AllowedMentions? allowedMentions, MessageBuilder? builder}) =>
      channel
        .send(content: content, embed: embed, files: files, tts: tts, builder: builder, allowedMentions: allowedMentions)
        .then((msg) {
          Timer(duration, () => msg.delete());
          return msg;
      });

  /// Replies to message after delay specified with [duration]
  /// ```
  /// @Command()
  /// Future<void> getAv(CommandContext context, String message) async {
  ///   await context.replyDelayed(Duration(seconds: 2), content: user.avatarURL());
  /// }
  /// ```
  Future<Message> replyDelayed(Duration duration,
      {dynamic content,
      List<AttachmentBuilder>? files,
      EmbedBuilder? embed,
      bool? tts,
      AllowedMentions? allowedMentions,
      MessageBuilder? builder}) => Future.delayed(
        duration,
        () => channel.send(
            content: content,
            embed: embed,
            files: files,
            tts: tts,
            builder: builder,
            allowedMentions: allowedMentions));

  /// Gather emojis of message in given time
  ///
  /// ```
  /// Future<void> getAv(CommandContext context, String message) async {
  ///   var msg = await context.replyDelayed(content: context.user.avatarURL());
  ///   var emojis = await context.collectEmojis(msg, Duration(seconds: 15));
  ///
  ///   ...
  /// }
  /// ```
  Future<Map<Emoji, int>?> collectEmojis(Message msg, Duration duration) => Future<Map<Emoji, int>?>(() async {
      final collectedEmoji = <Emoji, int>{};
      await for (final event in msg.client.onMessageReactionAdded.where((evnt) => evnt.message != null && evnt.message!.id == msg.id)) {
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
    }).timeout(duration, onTimeout: () => null);

  /// Waits for first [TypingEvent] and returns it. If timed out returns null.
  /// Can listen to specific user by specifying [user]
  Future<TypingEvent?> waitForTyping(User user, {Duration timeout = const Duration(seconds: 30)}) => Future<TypingEvent?>(() => user.client.onTyping.firstWhere((e) => e.user == user && e.channel == this.channel)).timeout(timeout, onTimeout: () => null);

  /// Gets all context channel messages that satisfies [predicate].
  ///
  /// ```
  /// @Command()
  /// Future<void> getAv(CommandContext context, String message) async {
  ///   var messages = await context.nextMessagesWhere((msg) => msg.content.startsWith("fuck"));
  /// }
  /// ```
  Stream<MessageReceivedEvent> nextMessagesWhere(bool Function(MessageReceivedEvent msg) predicate, {int limit = 100}) => channel.onMessage.where(predicate).take(limit);

  /// Gets next [num] number of any messages sent within one context (same channel).
  ///
  /// ```
  /// @Command()
  /// Future<void> getAv(CommandContext context, String message) async {
  ///   // gets next 10 messages
  ///   var messages = await context.nextMessages(10);
  /// }
  /// ```
  Stream<MessageReceivedEvent> nextMessages(int num) => channel.onMessage.take(num);

  /// Returns stream of all code blocks in message
  /// Language string `dart, java` will be ignored and not included
  /// """
  /// n> eval ```(dart)?
  ///   await reply(content: 'no to elo');
  /// ```
  /// """
  Iterable<String> getCodeBlocks() sync* {
    final regex = RegExp(r"```(\w+)?(\s)?(((.+)(\s)?)+)```");

    final matches = regex.allMatches(message.content);
    for (final match in matches) {
      final matchedText = match.group(3);

      if (matchedText != null) {
        yield matchedText;
      }
    }
  }
}
