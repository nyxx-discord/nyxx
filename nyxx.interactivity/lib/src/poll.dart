part of nyxx.interactivity;

/// Creates new poll, generates options and collects results. Returns `Map<Emoji, int` as result. [timeout] is set by default to 10 minutes
///
/// ```
/// Future<void> examplePoll(CommandContext ctx) async {
///   var results = createPoll(ctx.channel, "This is awesome poll", {UnicodeEmoji(""): "One option", UnicodeEmoji(""): "second option"});
/// }
/// ```
Future<Map<Emoji, int>> createPoll(CachelessTextChannel channel, String title, Map<Emoji, String> options,
    {Duration timeout = const Duration(minutes: 10),
    String? message,
    bool delete = false,
    dynamic Function(Map<Emoji, String> options, String message)? messageFactory}) async {
  var toSend;

  if (messageFactory == null) {
    final buffer = StringBuffer();

    buffer.writeln(title);
    options.forEach((k, v) {
      buffer.writeln("${k.format()} - $v");
    });

    if (message != null) buffer.writeln(message);

    toSend = buffer.toString();
  } else {
    toSend = messageFactory(options, message!);
  }

  Message msg;

  if (toSend is String) {
    msg = await channel.send(content: toSend);
  } else if (toSend is EmbedBuilder) {
    msg = await channel.send(embed: toSend);
  } else {
    return Future.error("Cannot create poll");
  }

  for (final emoji in options.keys) {
    await msg.createReaction(emoji);
  }

  final emojiCollection = <Emoji, int>{};

  return Future<Map<Emoji, int>>(() async {
    await for (final event in channel.client.onMessageReactionAdded.where((evnt) => evnt.message?.id == msg.id)) {
      if (emojiCollection.containsKey(event.emoji)) {
        // TODO: NNBD: weird stuff
        var value = emojiCollection[event.emoji];

        if (value != null) {
          value += 1;
          emojiCollection[event.emoji] = value;
        }
      } else {
        emojiCollection[event.emoji] = 1;
      }
    }

    return emojiCollection;
  }).timeout(timeout, onTimeout: () async {
    if (delete) await msg.delete();

    return emojiCollection;
  });
}
