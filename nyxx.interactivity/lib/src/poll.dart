part of nyxx.interactivity;

/// Creates new poll, generates options and collects results. Returns `Map<Emoji, int` as result. [timeout] is set by default to 10 minutes
///
/// ```
/// Future<void> examplePoll(CommandContext ctx) async {
///   var results = createPoll(ctx.channel, "This is awesome poll", {UnicodeEmoji(""): "One option", UnicodeEmoji(""): "second option"});
/// }
/// ```
Future<Map<Emoji, int>> createPoll(
    TextChannel channel, String title, Map<Emoji, String> options,
    {Duration timeout = const Duration(minutes: 10),
      String? message,
      bool delete = false,
      dynamic messageFactory(Map<Emoji, String> options, String message)?}) async {
  var toSend;

  if (messageFactory == null) {
    StringBuffer buffer = StringBuffer();

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
  if (toSend is String)
    msg = await channel.send(content: toSend);
  else if (toSend is EmbedBuilder)
    msg = await channel.send(embed: toSend);
  else
    return Future.error("Cannot create poll");

  for (var emoji in options.keys) await msg.createReaction(emoji);

  var m = Map<Emoji, int>();
  return Future<Map<Emoji, int>>(() async {
    await for (MessageReactionEvent r in channel.client.onMessageReactionAdded.where((evnt) => evnt.message?.id == msg.id)) {
      if (m.containsKey(r.emoji))
        m[r.emoji] += 1;
      else
        m[r.emoji] = 1;
    }

    return m;
  }).timeout(timeout, onTimeout: () async {
    if (delete) await msg.delete();

    return m;
  });
}
