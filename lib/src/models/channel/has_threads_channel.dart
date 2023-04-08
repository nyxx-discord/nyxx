import 'package:nyxx/src/builders/channel/thread.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/channel/thread_list.dart';
import 'package:nyxx/src/models/snowflake.dart';

abstract class HasThreadsChannel implements GuildChannel {
  Duration get defaultAutoArchiveDuration;

  Duration? get defaultThreadRateLimitPerUser;

  Future<Thread> createThreadFromMessage(Snowflake messageId, ThreadFromMessageBuilder builder);

  Future<Thread> createThread(ThreadBuilder builder);

  Future<ThreadList> listPublicArchivedThreads({DateTime? before, int? limit});

  Future<ThreadList> listPrivateArchivedThreads({DateTime? before, int? limit});
}
