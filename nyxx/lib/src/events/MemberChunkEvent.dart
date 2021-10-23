import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/guild/Guild.dart';
import 'package:nyxx/src/core/user/Member.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
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
class MemberChunkEvent implements IMemberChunkEvent{
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
    this.chunkIndex = raw["d"]["chunk_index"] as int;
    this.chunkCount = raw["d"]["chunk_count"] as int;

    this.guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));

    if (raw["d"]["not_found"] != null) {
      this.invalidIds = [for (var id in raw["d"]["not_found"]) Snowflake(id)];
    }

    this.members = [
      for (var memberRaw in raw["d"]["members"])
        Member(client, memberRaw as RawApiMap, this.guild.id)
    ];

    if (client.cacheOptions.memberCachePolicyLocation.event) {
      final guildInstance = this.guild.getFromCache();
      // TODO: Thats probably redundant
      for (final member in members) {
        if (client.cacheOptions.memberCachePolicy.canCache(member)) {
          guildInstance?.members[member.id] = member;
        }
      }
    }
  }
}
