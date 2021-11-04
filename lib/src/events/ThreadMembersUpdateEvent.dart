part of nyxx;

/// Fired when a thread has a member added/removed
class ThreadMembersUpdateEvent {
  /// The thread that was updated
  late final CacheableTextChannel<ThreadChannel> thread;

  /// The guild it was updated in
  late final Cacheable<Snowflake, Guild> guild;

  /// The members that were added. Note that they are not cached
  late final Iterable<Cacheable<Snowflake, Member>> addedMembers;

  /// The approximate number of members in the thread, capped at 50
  late final int approxMemberCount;

  /// Users who were removed from the thread
  late final Iterable<Cacheable<Snowflake, User>> removedUsers;

  ThreadMembersUpdateEvent._new(RawApiMap raw, Nyxx client) {
    final data = raw["d"] as RawApiMap;

    this.thread = CacheableTextChannel._new(client, Snowflake(data["id"]));
    this.guild = _GuildCacheable(client, Snowflake(data["guild_id"]));

    this.addedMembers = [
      if(data["added_members"] != null)
        for(final memberData in data["added_members"] as List<dynamic>)
          _MemberCacheable(client, Snowflake(memberData["user_id"]), this.guild)
    ];

    this.removedUsers = [
      if(data["removed_member_ids"] != null)
        for(final removedUserId in data["removed_member_ids"])
          _UserCacheable(client, Snowflake(removedUserId))
    ];
  }
}
