import 'dart:async';

import 'package:nyxx/nyxx.dart';
import 'EmojisUnicode.dart' as util;
import 'Util.dart' as util;

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
    String message,
    bool delete = false,
    dynamic messageFactory(Map<Emoji, String> options, String message)}) async {
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
    toSend = messageFactory(options, message);
  }

  Message msg;
  if (toSend is String)
    msg = await channel.send(content: toSend);
  else if (toSend is EmbedBuilder)
    msg = await channel.send(embed: toSend);
  else
    return Future.error(Exception("Cannot create poll"));

  for (var emoji in options.keys) await msg.createReaction(emoji);

  var m = Map<Emoji, int>();
  return Future<Map<Emoji, int>>(() async {
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

/// Handles pagination interactivity. Allows to create paginated messages from List<String>
/// Factory constructors allows to create message from String directly.
///
/// Pagination is sent by [paginate] method. And returns [Message] instance of sent message.
///
/// ```
/// var pagination = new Pagination(["This is simple paginated", "data. Use it if you", "want to partition text by yourself"], ctx,channel);
/// // It generated 2 equal (possibly) pages.
/// var paginatedMessage = new Pagination.fromStringEq("This is text for pagination", 2);
/// ```
class Pagination {
  /// Pages of paginated message
  List<String> pages;

  /// Channel where message will be sent
  MessageChannel channel;

  /// Generates new pagination from List of Strings. Each list element is single page.
  Pagination(this.pages, this.channel);

  /// Generates pagination from String. It divides String into 250 char long pages.
  factory Pagination.fromString(String str, MessageChannel channel) {
    return Pagination(util.split(str, 250).toList(), channel);
  }

  /// Generates pagination from String but with user specified size of single page.
  factory Pagination.fromStringLen(
      String str, int len, MessageChannel channel) {
    return Pagination(util.split(str, len).toList(), channel);
  }

  /// Generates pagination from String but with user specified number of pages.
  factory Pagination.fromStringEq(
      String str, int pieces, MessageChannel channel) {
    return Pagination(util.splitEqually(str, pieces).toList(), channel);
  }

  /// Paginates a list of Strings - each String is different page.
  Future<Message> paginate(Nyxx client,
      {Duration timeout = const Duration(minutes: 2)}) async {
    var nextEmoji = util.getEmoji('arrow_forward');
    var backEmoji = util.getEmoji('arrow_backward');
    var firstEmoji = util.getEmoji('track_previous');
    var lastEmoji = util.getEmoji('track_next');

    var msg = await channel.send(content: pages[0]);
    await msg.createReaction(firstEmoji);
    await msg.createReaction(backEmoji);
    await msg.createReaction(nextEmoji);
    await msg.createReaction(lastEmoji);

    Future(() async {
      var currPage = 0;
      var group = util.merge(
          [client.onMessageReactionAdded, client.onMessageReactionsRemoved]);

      await for (var event in group) {
        var emoji = (event as dynamic).emoji as UnicodeEmoji;

        if (emoji == nextEmoji) {
          if (currPage <= pages.length - 2) {
            ++currPage;
            await msg.edit(content: pages[currPage]);
          }
        } else if (emoji == backEmoji) {
          if (currPage >= 1) {
            --currPage;
            await msg.edit(content: pages[currPage]);
          }
        } else if (emoji == firstEmoji) {
          await msg.edit(content: pages.first);
          currPage = 0;
        } else if (emoji == lastEmoji) {
          await msg.edit(content: pages.last);
          currPage = pages.length;
        }
      }
    }).timeout(timeout);

    return msg;
  }
}
