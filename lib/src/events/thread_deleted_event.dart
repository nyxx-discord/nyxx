import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/channel/cacheable_text_channel.dart';
import 'package:nyxx/src/core/channel/thread_channel.dart';
import 'package:nyxx/src/core/channel/guild/text_guild_channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IThreadDeletedEvent {
  /// Thread that was deleted
  CacheableTextChannel<IThreadChannel> get thread;

  /// Channel where thread was located
  CacheableTextChannel<ITextGuildChannel> get parent;

  /// Guild where event was generated
  Cacheable<Snowflake, IGuild> get guild;
}

/// Fired when a thread is created
class ThreadDeletedEvent implements IThreadDeletedEvent {
  /// Thread that was deleted
  @override
  late final CacheableTextChannel<ThreadChannel> thread;

  /// Channel where thread was located
  @override
  late final CacheableTextChannel<TextGuildChannel> parent;

  /// Guild where event was generated
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates an instance of [ThreadDeletedEvent]
  ThreadDeletedEvent(RawApiMap raw, INyxx client) {
    final data = raw["d"] as RawApiMap;

    thread = CacheableTextChannel(client, Snowflake(data["id"]));
    parent = CacheableTextChannel(client, Snowflake(data["parent_id"]));
    guild = GuildCacheable(client, Snowflake(data["guild_id"]));
  }
}
