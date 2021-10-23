import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/channel/CacheableTextChannel.dart';
import 'package:nyxx/src/core/channel/ThreadChannel.dart';
import 'package:nyxx/src/core/channel/guild/TextGuildChannel.dart';
import 'package:nyxx/src/core/guild/Guild.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
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

  /// Creates na instance of [ThreadDeletedEvent]
  ThreadDeletedEvent(RawApiMap raw, INyxx client) {
    final data = raw["d"] as RawApiMap;

    this.thread = CacheableTextChannel(client, Snowflake(data["id"]));
    this.parent = CacheableTextChannel(client, Snowflake(data["parent_id"]));
    this.guild = GuildCacheable(client, Snowflake(data["guild_id"]));
  }
}
