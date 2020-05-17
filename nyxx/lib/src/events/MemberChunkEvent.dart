part of nyxx;

/// Sent in response to `GUILD_REQUENT_MEMBERS` websocket command.
/// You can use the `chunk_index` and `chunk_count` to calculate how many chunks are left for your request.
class MemberChunkEvent {
  /// Guild members
  late final Iterable<Member> members;

  /// Id of guild
  late final Snowflake guildId;

  /// Reference to guild
  Guild? guild;

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

  MemberChunkEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.chunkIndex = raw["d"]["chunk_index"] as int;
    this.chunkCount = raw["d"]["chunk_count"] as int;

    this.guildId = Snowflake(raw["d"]["guild_id"]);
    this.guild = client.guilds[this.guildId];

    if (raw["d"]["not_found"] != null) {
      this.invalidIds = [for (var id in raw["d"]["not_found"]) Snowflake(id)];
    }

    if (this.guild == null) {
      return;
    }

    this.members = [
      for (var memberRaw in raw["d"]["members"])
        Member._standard(memberRaw as Map<String, dynamic>, this.guild!, client)
    ];

    // TODO: Thats probably redundant
    for (final member in members) {
      this.guild!.members.add(member.id, member);
    }
  }
}
