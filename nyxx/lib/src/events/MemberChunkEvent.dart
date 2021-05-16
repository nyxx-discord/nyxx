part of nyxx;

/// Sent in response to `GUILD_REQUENT_MEMBERS` websocket command.
/// You can use the `chunk_index` and `chunk_count` to calculate how many chunks are left for your request.
class MemberChunkEvent {
  /// Guild members
  late final Iterable<Member> members;

  /// Reference to guild
  late final Cacheable<Snowflake, Guild> guild;

  /// Set of presences if requested
//  late final Iterable<Activity>? presences;

  /// Index of current event
  late final int chunkIndex;

  /// Total number of chunks that will be sent.
  late final int chunkCount;

  /// Array of snowflakes which were invalid in search
  Iterable<Snowflake>? invalidIds;

  /// Nonce is used to identify events.
  String? nonce;

  /// Id of shard where chunk was received
  final int shardId;

  MemberChunkEvent._new(Map<String, dynamic> raw, Nyxx client, this.shardId) {
    this.chunkIndex = raw["d"]["chunk_index"] as int;
    this.chunkCount = raw["d"]["chunk_count"] as int;

    this.guild = _GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));

    if (raw["d"]["not_found"] != null) {
      this.invalidIds = [for (var id in raw["d"]["not_found"]) Snowflake(id)];
    }

    this.members = [
      for (var memberRaw in raw["d"]["members"]) Member._new(client, memberRaw as Map<String, dynamic>, this.guild.id)
    ];

    if (client._cacheOptions.memberCachePolicyLocation.event) {
      final guildInstance = this.guild.getFromCache();
      // TODO: Thats probably redundant
      for (final member in members) {
        if (client._cacheOptions.memberCachePolicy.canCache(member)) {
          guildInstance?.members.add(member.id, member);
        }
      }
    }
  }
}
