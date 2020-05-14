part of nyxx.interactivity;

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
    return Pagination(_Utils.split(str, 250).toList(), channel);
  }

  /// Generates pagination from String but with user specified size of single page.
  factory Pagination.fromStringLen(
      String str, int len, MessageChannel channel) {
    return Pagination(_Utils.split(str, len).toList(), channel);
  }

  /// Generates pagination from String but with user specified number of pages.
  factory Pagination.fromStringEq(
      String str, int pieces, MessageChannel channel) {
    return Pagination(_Utils.splitEqually(str, pieces).toList(), channel);
  }

  /// Paginates a list of Strings - each String is a different page.
  Future<Message> paginate(Nyxx client,
      {Duration timeout = const Duration(minutes: 2)}) async {
    var nextEmoji = EmojiUtils.getEmoji('arrow_forward')!;
    var backEmoji = EmojiUtils.getEmoji('arrow_backward')!;
    var firstEmoji = EmojiUtils.getEmoji('track_previous')!;
    var lastEmoji = EmojiUtils.getEmoji('track_next')!;

    var msg = await channel.send(content: pages[0]);
    await msg.createReaction(firstEmoji);
    await msg.createReaction(backEmoji);
    await msg.createReaction(nextEmoji);
    await msg.createReaction(lastEmoji);

    Future(() async {
      var currPage = 0;
      Stream<MessageReactionEvent> group = _Utils.merge(
          [client.onMessageReactionAdded, client.onMessageReactionsRemoved as Stream<MessageReactionEvent>]);

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
