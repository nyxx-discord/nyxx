import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';

/// Sent in response to `GUILD_REQUENT_MEMBERS` websocket command.
/// You can use the `chunk_index` and `chunk_count` to calculate how many chunks are left for your request.
abstract class IMemberChunkEvent {
  /// Guild members
  Iterable<IMember> get members;

  /// Reference to guild
  Cacheable<Snowflake, IGuild> get guild;

  /// Index of current event
  int get chunkIndex;

  /// Total number of chunks that will be sent.
  int get chunkCount;

  /// Array of snowflakes which were invalid in search
  Iterable<Snowflake>? get invalidIds;

  /// Nonce is used to identify events.
  String? get nonce;

  /// Id of shard where chunk was received
  int get shardId;
}

/// Sent in response to `GUILD_REQUENT_MEMBERS` websocket command.
/// You can use the `chunk_index` and `chunk_count` to calculate how many chunks are left for your request.
class MemberChunkEvent implements IMemberChunkEvent {
  /// Guild members
  @override
  late final Iterable<IMember> members;

  /// Reference to guild
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Index of current event
  @override
  late final int chunkIndex;

  /// Total number of chunks that will be sent.
  @override
  late final int chunkCount;

  /// Array of snowflakes which were invalid in search
  @override
  Iterable<Snowflake>? invalidIds;

  /// Nonce is used to identify events.
  @override
  String? nonce;

  /// Id of shard where chunk was received
  @override
  final int shardId;

  MemberChunkEvent(RawApiMap raw, INyxx client, this.shardId) {
    chunkIndex = raw["d"]["chunk_index"] as int;
    chunkCount = raw["d"]["chunk_count"] as int;

    guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));

    if (raw["d"]["not_found"] != null) {
      invalidIds = [for (var id in raw["d"]["not_found"] as RawApiList) Snowflake(id)];
    }

    members = [for (var memberRaw in raw["d"]["members"] as RawApiList) Member(client, memberRaw as RawApiMap, guild.id)];

    if (client.cacheOptions.memberCachePolicyLocation.event) {
      final guildInstance = guild.getFromCache();
      for (final member in members) {
        if (client.cacheOptions.memberCachePolicy.canCache(member)) {
          guildInstance?.members[member.id] = member;
        }
      }
    }
  }
}
