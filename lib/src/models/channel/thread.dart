import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/flags.dart';

class PartialThread extends PartialTextChannel implements PartialGuildChannel {
  PartialThread({required super.id, required super.manager});
}

abstract class Thread extends PartialThread implements TextChannel, GuildChannel {
  final Snowflake ownerId;

  final int messageCount;

  final int approximateMemberCount;

  final bool isArchived;

  final Duration autoArchiveDuration;

  final DateTime archiveTimestamp;

  final bool isLocked;

  final DateTime createdAt;

  final int totalMessagesSent;

  final List<Snowflake>? appliedTags;

  Thread({
    required super.id,
    required super.manager,
    required this.ownerId,
    required this.messageCount,
    required this.approximateMemberCount,
    required this.isArchived,
    required this.autoArchiveDuration,
    required this.archiveTimestamp,
    required this.isLocked,
    required this.createdAt,
    required this.totalMessagesSent,
    required this.appliedTags,
  });
}

class PartialThreadMember {
  final DateTime joinTimestamp;

  final Flags<Never> flags;

  PartialThreadMember({required this.joinTimestamp, required this.flags});
}

class ThreadMember extends PartialThreadMember {
  final Snowflake threadId;

  final Snowflake userId;

  // TODO
  // final Member? member;

  ThreadMember({
    required super.joinTimestamp,
    required super.flags,
    required this.threadId,
    required this.userId,
  });
}
