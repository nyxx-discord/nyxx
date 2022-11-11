import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/enum.dart';
import 'package:nyxx/src/utils/builders/builder.dart';

class ThreadBuilder extends Builder {
  /// The name for the thread
  String? name;

  /// Whether or not the thread is private
  bool? private;

  /// Whether the thread is archived
  bool? archived;

  /// Whether the thread is locked; when a thread is locked, only users with MANAGE_THREADS can unarchive it
  bool? locked;

  /// Whether non-moderators can add other non-moderators to a thread; only available on private threads
  bool? invitable;

  /// Amount of seconds a user has to wait before sending another message (0-21600);
  /// bots, as well as users with the permission manage_messages, manage_thread, or manage_channel, are unaffected
  int? rateLimitPerUser;

  /// The time after which the thread is automatically archived.
  ThreadArchiveTime? archiveAfter;

  /// Create a public thread
  ThreadBuilder(this.name);

  /// Create a private thread
  ThreadBuilder.private(this.name) {
    private = true;
  }

  @override
  RawApiMap build() => <String, dynamic>{
        if (archiveAfter != null) "auto_archive_duration": archiveAfter!.value,
        if (name != null) "name": name,
        if (private != null) "type": private! ? 12 : 11,
        if (archived != null) "archived": archived!,
        if (invitable != null) "invitable": invitable!,
        if (rateLimitPerUser != null) 'rate_limit_per_user': rateLimitPerUser!,
        if (locked != null) "locked": locked
      };
}

/// Simplifies the process of setting an auto archive time.
class ThreadArchiveTime extends IEnum<int> {
  /// Creates an instance of [ThreadArchiveTime]
  const ThreadArchiveTime(int value) : super(value);

  /// Archive after an hour
  static const ThreadArchiveTime hour = ThreadArchiveTime(60);

  /// Archive after an day
  static const ThreadArchiveTime day = ThreadArchiveTime(1440);

  /// Archive after 3 days
  static const ThreadArchiveTime threeDays = ThreadArchiveTime(4320);

  /// Archive after an week
  static const ThreadArchiveTime week = ThreadArchiveTime(10080);
}
