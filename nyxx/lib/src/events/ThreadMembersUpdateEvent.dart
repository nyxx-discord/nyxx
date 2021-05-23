part of nyxx;

/// Fired when a thread has a member added/removed
class ThreadMembersUpdateEvent {
  late final _ChannelCacheable<ThreadChannel> thread;
  late final _GuildCacheable guild;
  late final List<Cacheable<Snowflake, Member>> addedMembers;

  ThreadMembersUpdateEvent._new(Map<String, dynamic> raw, Nyxx client) {
    final data = raw["d"] as Map<String, dynamic>;
    this.thread = new _ChannelCacheable(client, Snowflake(data["id"]));
    this.guild = new _GuildCacheable(client, Snowflake(data["guild_id"]));
    addedMembers = [];
    if(data["added_members"] != null) {
      for(final dynamic memberData in data["added_members"] as List<dynamic>) {
        final member = memberData as Map<String, dynamic>;
        addedMembers.add(CacheUtility.createCacheableMember(client, Snowflake(member["user_id"]), this.guild));
      }
    }
  }
}