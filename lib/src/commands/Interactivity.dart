part of nyxx.commands;

class Interactivity {
  /// Paginates a list of Strings - each String is different page.
  static Future<Message> paginate(TextChannel channel, List<String> data, {Duration timeout: const Duration(seconds: 30)}) async {
    var nextEmoji = EmojisUnicode.arrow_forward;
    var backEmoji = EmojisUnicode.arrow_backward;

    var msg = await channel.send(content: data[0]);
    await msg.createReaction(backEmoji);
    await msg.createReaction(nextEmoji);

    new Future(() async {
      var currPage = 0;
      var group = Util.merge([channel.client.onMessageReactionAdded, channel.client.onMessageReactionRemove]);

      await for(var event in group) {
        if(msg.id != event.message.id) continue;
        if(event.user.bot) continue;

        var emoji = event.emoji as UnicodeEmoji;
        if(emoji.code == nextEmoji.encode()) {
          if(currPage <= data.length - 2) {
            ++currPage;
            await msg.edit(content: data[currPage]);
          }
        } else if (emoji.code == backEmoji.encode()) {
          if(currPage >= 1) {
            --currPage;
            await msg.edit(content: data[currPage]);
          }
        }

        print(currPage);
      }
    }).timeout(timeout);

    return msg;
  }

  /// Creates new poll, generates options and collects results. Returns `Map<Emoji, int` as result. [timeout] is set by default to 10 minutes
  static Future<Map<Emoji, int>> createPoll(TextChannel channel, String title, Map<Emoji, String> options, {Duration timeout: const Duration(minutes: 10), String message: null, bool delete: false}) async {
    StringBuffer buffer = new StringBuffer();

    buffer.writeln(title);
    options.forEach((k, v) {
      buffer.writeln("${k.format()} - $v");
    });

    if(message != null)
      buffer.writeln(message);

    var msg = await channel.send(content: buffer.toString());
    for (var emoji in options.keys)
      await msg.createReaction(emoji);

    // Clean memory. Or just null it. Maybe GC will clean this.
    buffer = null;

    var m = new Map<Emoji, int>();
    return new Future<Map<Emoji, int>>(() async {
      await for (var r in msg.onReactionAdded) {
        if(m.containsKey(r.emoji))
          m[r.emoji] = m[r.emoji] += 1;
        else
          m[r.emoji] = 1;
      }
    }).timeout(timeout, onTimeout: () async {
      if(delete)
        await msg.delete();

      return m;
    });
  }
}