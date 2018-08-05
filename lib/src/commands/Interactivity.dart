part of nyxx.commands;

/// Creates new poll, generates options and collects results. Returns `Map<Emoji, int` as result. [timeout] is set by default to 10 minutes
Future<Map<Emoji, int>> createPoll(
    TextChannel channel, String title, Map<Emoji, String> options,
    {Duration timeout: const Duration(minutes: 10),
    String message: null,
    bool delete: false}) async {
  StringBuffer buffer = new StringBuffer();

  buffer.writeln(title);
  options.forEach((k, v) {
    buffer.writeln("${k.format()} - $v");
  });

  if (message != null) buffer.writeln(message);

  var msg = await channel.send(content: buffer.toString());
  for (var emoji in options.keys) await msg.createReaction(emoji);

  // Clean memory. Or just null it. Maybe GC will clean this.
  buffer = null;

  var m = new Map<Emoji, int>();
  return new Future<Map<Emoji, int>>(() async {
    await for (var r in msg.onReactionAdded) {
      if (m.containsKey(r.emoji))
        m[r.emoji] = m[r.emoji] += 1;
      else
        m[r.emoji] = 1;
    }
  }).timeout(timeout, onTimeout: () async {
    if (delete) await msg.delete();

    return m;
  });
}

/// Handles pagination interactivity
class Pagination {
  List<String> pages;

  MessageChannel channel;

  /// Generates pagination from String. It divides String into 250 char long pages.
  Pagination.fromString(String str, this.channel) {
    this.pages = util.split(str, 250).toList();
  }

  /// Generates pagination from String but with user specified size of single page.
  Pagination.fromStringLen(String str, int len, this.channel) {
    this.pages = util.split(str, len).toList();
  }

  /// Generates pagination from String but with user specified number of pages.
  Pagination.fromStringEq(String str, int pieces, this.channel) {
    this.pages = util.splitEqually(str, pieces).toList();
  }

  /*
  /// Generates pagination based on given page size but don't split in middle of word
  Pagination.fromStringSmart(String str, int len, this.channel) {
    this.pages = util.split300iq(str, len).toList();
  }
  */

  /// Generates new pagination from List of Strings. Each list element is single page.
  Pagination.fromList(this.pages, this.channel);

  /// Paginates a list of Strings - each String is different page.
  Future<Message> paginate(
      {Duration timeout: const Duration(seconds: 30)}) async {
    var nextEmoji = EmojisUnicode.arrow_forward;
    var backEmoji = EmojisUnicode.arrow_backward;
    var firstEmoji = EmojisUnicode.track_previous;
    var lastEmoji = EmojisUnicode.track_next;

    var msg = await channel.send(content: pages[0]);
    await msg.createReaction(firstEmoji);
    await msg.createReaction(backEmoji);
    await msg.createReaction(nextEmoji);
    await msg.createReaction(lastEmoji);

    new Future(() async {
      var currPage = 0;
      var group = util.merge([
        channel.client.onMessageReactionAdded,
        channel.client.onMessageReactionRemove
      ]);

      await for (var event in group) {
        if (msg.id != event.message.id) continue;
        if (event.user.bot) continue;

        var emoji = event.emoji as UnicodeEmoji;
        if (emoji.code == nextEmoji.encode()) {
          if (currPage <= pages.length - 2) {
            ++currPage;
            await msg.edit(content: pages[currPage]);
          }
        } else if (emoji.code == backEmoji.encode()) {
          if (currPage >= 1) {
            --currPage;
            await msg.edit(content: pages[currPage]);
          }
        } else if (emoji.code == firstEmoji.encode()) {
          await msg.edit(content: pages.first);
          currPage = 0;
        } else if (emoji.code == lastEmoji.encode()) {
          await msg.edit(content: pages.last);
          currPage = pages.length;
        }
      }
    }).timeout(timeout);

    return msg;
  }
}
