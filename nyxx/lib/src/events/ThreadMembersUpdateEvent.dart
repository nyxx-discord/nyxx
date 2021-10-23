part of nyxx;

/// Fired when a thread has a member added/removed
class ThreadMembersUpdateEvent implements IThreadMembersUpdateEvent {
  /// The thread that was updated
  late final CacheableTextChannel<IThreadChannel> thread;

  /// The guild it was updated in
  late final Cacheable<Snowflake, IGuild> guild;

  /// The members that were added. Note that they are not cached
  late final Iterable<Cacheable<Snowflake, IMember>> addedMembers;

  /// The approximate number of members in the thread, capped at 50
  late final int approxMemberCount;

  /// Users who were removed from the thread
  late final Iterable<Cacheable<Snowflake, IUser>> removedUsers;

  /// Creates an instance of [ThreadMembersUpdateEvent]
  ThreadMembersUpdateEvent(RawApiMap raw, INyxx client) {
    final data = raw["d"] as RawApiMap;

    this.thread = CacheableTextChannel(client, Snowflake(data["id"]));
    this.guild = GuildCacheable(client, Snowflake(data["guild_id"]));

    this.addedMembers = [
      if(data["added_members"] != null)
        for(final memberData in data["added_members"] as List<dynamic>)
          MemberCacheable(client, Snowflake(memberData["user_id"]), this.guild)
    ];

    this.removedUsers = [
      if(data["removed_member_ids"] != null)
        for(final removedUserId in data["removed_member_ids"])
          UserCacheable(client, Snowflake(removedUserId))
    ];
  }
}
