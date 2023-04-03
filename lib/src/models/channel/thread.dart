import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/flags.dart';

abstract class Thread implements TextChannel, GuildChannel {
  Snowflake get ownerId;

  int get messageCount;

  int get approximateMemberCount;

  bool get isArchived;

  Duration get autoArchiveDuration;

  DateTime get archiveTimestamp;

  bool get isLocked;

  DateTime get createdAt;

  int get totalMessagesSent;

  List<Snowflake>? get appliedTags;

  ChannelFlags? get flags;
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
