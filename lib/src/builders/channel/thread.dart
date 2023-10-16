import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/flags.dart';

class ThreadFromMessageBuilder extends CreateBuilder<Thread> {
  String name;

  Duration? autoArchiveDuration;

  Duration? rateLimitPerUser;

  ThreadFromMessageBuilder({required this.name, this.autoArchiveDuration, this.rateLimitPerUser});

  @override
  Map<String, Object?> build() => {
        'name': name,
        if (autoArchiveDuration != null) 'auto_archive_duration': autoArchiveDuration!.inMinutes,
        if (rateLimitPerUser != null) 'rate_limit_per_user': rateLimitPerUser!.inSeconds,
      };
}

class ThreadBuilder extends CreateBuilder<Thread> {
  static const archiveOneHour = Duration(minutes: 60);
  static const archiveOneDay = Duration(minutes: 1440);
  static const archiveThreeDays = Duration(minutes: 4320);
  static const archiveOneWeek = Duration(minutes: 10080);

  String name;

  Duration? autoArchiveDuration;

  ChannelType type;

  bool? invitable;

  Duration? rateLimitPerUser;

  ThreadBuilder({required this.name, this.autoArchiveDuration, required this.type, this.invitable, this.rateLimitPerUser});

  ThreadBuilder.publicThread({required this.name, this.autoArchiveDuration, this.rateLimitPerUser}) : type = ChannelType.publicThread;

  ThreadBuilder.privateThread({required this.name, this.autoArchiveDuration, this.invitable, this.rateLimitPerUser}) : type = ChannelType.privateThread;

  @override
  Map<String, Object?> build() => {
        'name': name,
        if (autoArchiveDuration != null) 'auto_archive_duration': autoArchiveDuration!.inMinutes,
        'type': type.value,
        if (invitable != null) 'invitable': invitable,
        if (rateLimitPerUser != null) 'rate_limit_per_user': rateLimitPerUser!.inSeconds,
      };
}

class ForumThreadBuilder extends CreateBuilder<Thread> {
  String name;

  Duration? autoArchiveDuration;

  Duration? rateLimitPerUser;

  MessageBuilder message;

  List<Snowflake>? appliedTags;

  ForumThreadBuilder({required this.name, this.autoArchiveDuration, this.rateLimitPerUser, required this.message, this.appliedTags});

  @override
  Map<String, Object?> build() => {
        'name': name,
        if (autoArchiveDuration != null) 'auto_archive_duration': autoArchiveDuration!.inMinutes,
        if (rateLimitPerUser != null) 'rate_limit_per_user': rateLimitPerUser!.inSeconds,
        'message': message.build(),
        if (appliedTags != null) 'applied_tags': appliedTags!.map((e) => e.toString()).toList(),
      };
}

class ThreadUpdateBuilder extends UpdateBuilder<Thread> {
  String? name;

  bool? isArchived;

  Duration? autoArchiveDuration;

  bool? isLocked;

  bool? isInvitable;

  Duration? rateLimitPerUser;

  Flags<ChannelFlags>? flags;

  List<Snowflake>? appliedTags;

  ThreadUpdateBuilder({
    this.name,
    this.isArchived,
    this.autoArchiveDuration,
    this.isLocked,
    this.isInvitable,
    this.rateLimitPerUser = sentinelDuration,
    this.flags,
    this.appliedTags,
  });

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (isArchived != null) 'archived': isArchived,
        if (autoArchiveDuration != null) 'auto_archive_duration': autoArchiveDuration!.inMinutes,
        if (isLocked != null) 'locked': isLocked,
        if (isInvitable != null) 'invitable': isInvitable,
        if (!identical(rateLimitPerUser, sentinelDuration)) 'rate_limit_per_user': rateLimitPerUser?.inSeconds,
        if (flags != null) 'flags': flags!.value,
        if (appliedTags != null) 'applied_tags': appliedTags!.map((e) => e.toString()).toList(),
      };
}
