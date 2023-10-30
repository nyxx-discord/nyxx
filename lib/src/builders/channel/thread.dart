import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/flags.dart';

class ThreadFromMessageBuilder extends CreateBuilder<Thread> {
  /// {@template thread_name}
  /// The name of the thread.
  /// {@endtemplate}
  String name;

  /// {@macro channel_default_auto_archive_duration}
  Duration? autoArchiveDuration;

  /// {@macro channel_rate_limit_per_user}
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

  /// {@macro thread_name}
  String name;

  /// {@macro channel_default_auto_archive_duration}
  Duration? autoArchiveDuration;

  /// {@macro channel_type}
  ChannelType type;

  /// Whether non-moderators can add other non-moderators to a thread; only available on private threads.
  // TODO: Prefix with is*?
  bool? invitable;

  /// {@macro channel_rate_limit_per_user}
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
  /// {@macro thread_name}
  String name;

  /// {@macro channel_default_auto_archive_duration}
  Duration? autoArchiveDuration;

  /// {@macro channel_rate_limit_per_user}
  Duration? rateLimitPerUser;

  /// Contents of the first message in the forum thread.
  MessageBuilder message;

  /// {@template thread_applied_tags}
  /// The IDs of the set of tags that have been applied to a thread in a [ChannelType.guildForum] channel.
  /// {@endtemplate}
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
  /// {@macro thread_name}
  String? name;

  /// Whether the thread is archived.
  bool? isArchived;

  /// {@macro channel_default_auto_archive_duration}
  Duration? autoArchiveDuration;

  /// Whether the thread is locked; only available on private threads.
  bool? isLocked;

  /// Whether non-moderators can add other non-moderators to a thread; only available on private threads.
  bool? isInvitable;

  /// {@macro channel_rate_limit_per_user}
  Duration? rateLimitPerUser;

  /// {@macro channel_flags}
  Flags<ChannelFlags>? flags;

  /// {@macro thread_applied_tags}
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
