part of nyxx;

/// Fired when a thread has a member added/removed
class ThreadMembersUpdateEvent {
  /// The thread that was updated
  late final _ChannelCacheable<ThreadChannel> thread;

  /// The guild it was updated in
  late final _GuildCacheable guild;

  /// The members that were added
  late final List<_MemberCacheable> addedMembers;

  ThreadMembersUpdateEvent._new(Map<String, dynamic> raw, Nyxx client) {
    final data = raw["d"] as Map<String, dynamic>;
    this.thread = new _ChannelCacheable(client, Snowflake(data["id"]));
    this.guild = new _GuildCacheable(client, Snowflake(data["guild_id"]));
    addedMembers = [];
    if(data["added_members"] != null) {
      for(final dynamic memberData in data["added_members"] as List<dynamic>) {
        final member = memberData as Map<String, dynamic>;
        addedMembers.add(new _MemberCacheable(client, Snowflake(member["user_id"]), this.guild));
      }
    }
  }
}
