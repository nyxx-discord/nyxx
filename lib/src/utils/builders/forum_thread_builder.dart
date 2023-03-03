import 'package:nyxx/src/core/channel/guild/forum/forum_tag.dart';
import 'package:nyxx/src/core/message/emoji.dart';
import 'package:nyxx/src/core/message/guild_emoji.dart';
import 'package:nyxx/src/core/message/unicode_emoji.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/builder.dart';
import 'package:nyxx/src/utils/builders/message_builder.dart';
import 'package:nyxx/src/utils/builders/thread_builder.dart';

class ForumTagBuilder {
  Snowflake id;

  ForumTagBuilder(this.id);

  factory ForumTagBuilder.fromForumTag(ForumTag forumTag) => ForumTagBuilder(forumTag.id);
}

class AvailableTagBuilder implements Builder {
  /// The name of the tag (0-20 characters)
  String name;

  /// Whether this tag can only be added to or removed from threads by a member with the MANAGE_THREADS permission
  bool moderated;

  /// Emoji for tag
  IEmoji? emoji;

  AvailableTagBuilder(this.name, this.moderated);

  @override
  RawApiMap build() => {
        "name": name,
        "moderated": moderated,
        if (emoji is UnicodeEmoji) "emoji_name": emoji!.encodeForAPI(),
        if (emoji is BaseGuildEmoji) "emoji_name": (emoji as BaseGuildEmoji).id
      };
}

class ForumThreadBuilder implements Builder {
  /// The name of the thread
  String name;

  /// First message in thread
  MessageBuilder? message;

  /// Amount of seconds a user has to wait before sending another message (0-21600);
  /// bots, as well as users with the permission manage_messages, manage_thread, or manage_channel, are unaffected
  int? rateLimitPerUser;

  /// The time after which the thread is automatically archived.
  ThreadArchiveTime? archiveAfter;

  /// Set of tags that have been applied to a thread
  Iterable<ForumTagBuilder>? appliedTags;

  ForumThreadBuilder(
    this.name, {
    this.message,
    this.appliedTags,
    this.archiveAfter,
    this.rateLimitPerUser,
  });

  @override
  RawApiMap build() {
    return {
      "name": name,
      if (message != null) "message": message!.build(),
      if (archiveAfter != null) "auto_archive_duration": archiveAfter!.value,
      if (rateLimitPerUser != null) 'rate_limit_per_user': rateLimitPerUser!,
      if (appliedTags != null) 'applied_tags': appliedTags!.map((e) => e.id.toString()).toList()
    };
  }
}
