import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/builders/builder.dart';

class ThreadUpdateBuilder extends UpdateBuilder<Thread> {
  final String? name;

  final bool? isArchived;

  final Duration? autoArchiveDuration;

  final bool? isLocked;

  final bool? isInvitable;

  final Duration? rateLimitPerUser;

  final ChannelFlags? flags;

  final List<Snowflake>? appliedTags;

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
