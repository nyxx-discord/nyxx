part of nyxx;

class ThreadMember extends SnowflakeEntity {
  /// Reference to client
  final INyxx client;

  late final int flags;

  late final DateTime joinedAt;

  late final Cacheable<Snowflake, Member> member;

  ThreadMember._new(this.client, Map<String, dynamic> raw, Snowflake guildId) : super(Snowflake(raw["id"])) {
    this.flags = raw["flags"] as int;
    this.joinedAt = DateTime.parse(raw["join_timestamp"] as String);
    this.member = CacheUtility.createCacheableMember(client, Snowflake(raw["user_id"] as String), CacheUtility.createCacheableGuild(client, guildId));
  }
}