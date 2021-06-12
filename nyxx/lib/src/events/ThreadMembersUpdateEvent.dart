part of nyxx;

/// Fired when a thread has a member added/removed
class ThreadMembersUpdateEvent {
  /// The thread that was updated
  late final CacheableTextChannel<ThreadChannel> thread;

  /// The guild it was updated in
  late final Cacheable<Snowflake, Guild> guild;

  /// The members that were added. Note that they are not cached
  late final List<Cacheable<Snowflake, Member>> addedMembers;

  ThreadMembersUpdateEvent._new(Map<String, dynamic> raw, Nyxx client) {
    final data = raw["d"] as Map<String, dynamic>;

    this.thread = new CacheableTextChannel._new(client, Snowflake(data["id"]));
    this.guild = new _GuildCacheable(client, Snowflake(data["guild_id"]));

    addedMembers = [];
    if(data["added_members"] != null) {
      for(final memberData in data["added_members"] as List<dynamic>) {
        addedMembers.add(new _MemberCacheable(client, Snowflake(memberData["user_id"]), this.guild));
      }
    }
  }
}
