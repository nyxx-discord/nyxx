import 'package:nyxx/src/models/channel/guild_channel.dart';

abstract class HasThreadsChannel implements GuildChannel {
  Duration get defaultAutoArchiveDuration;

  Duration? get defaultThreadRateLimitPerUser;
}
