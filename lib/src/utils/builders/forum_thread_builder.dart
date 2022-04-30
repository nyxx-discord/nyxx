import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/builder.dart';
import 'package:nyxx/src/utils/builders/message_builder.dart';
import 'package:nyxx/src/utils/builders/thread_builder.dart';

class ForumThreadBuilder implements Builder {
  /// The name fo the thread
  String? name;

  /// Amount of seconds a user has to wait before sending another message (0-21600);
  /// bots, as well as users with the permission manage_messages, manage_thread, or manage_channel, are unaffected
  int? rateLimitPerUser;

  /// The time after which the thread is automatically archived.
  ThreadArchiveTime? archiveAfter;

  /// First message in thread
  MessageBuilder? message;

  @override
  RawApiMap build() {
    if (name?.isEmpty ?? true) {
      throw ArgumentError("Name cannot be null or empty");
    }

    if (message == null) {
      throw ArgumentError("Message cannot be null or empty");
    }

    return {
      "name": name,
      "message": message!.build(),
      if (archiveAfter != null) "auto_archive_duration": archiveAfter!.value,
      if (rateLimitPerUser != null) 'rate_limit_per_user': rateLimitPerUser!
    };
  }
}
