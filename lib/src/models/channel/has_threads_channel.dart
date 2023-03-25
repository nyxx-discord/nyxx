import 'package:nyxx/src/models/channel/guild_channel.dart';

class PartialHasThreadsChannel extends PartialGuildChannel {
  PartialHasThreadsChannel({required super.id, required super.manager});
}

abstract class HasThreadsChannel extends PartialHasThreadsChannel implements GuildChannel {
  final Duration defaultAutoArchiveDuration;

  final Duration? defaultThreadRateLimitPerUser;

  HasThreadsChannel({
    required super.id,
    required super.manager,
    required this.defaultAutoArchiveDuration,
    required this.defaultThreadRateLimitPerUser,
  });
}
