import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/channel/CacheableTextChannel.dart';
import 'package:nyxx/src/core/channel/ThreadChannel.dart';
import 'package:nyxx/src/core/guild/Guild.dart';
import 'package:nyxx/src/core/user/Member.dart';
import 'package:nyxx/src/core/user/User.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IThreadMembersUpdateEvent {
  /// The thread that was updated
  CacheableTextChannel<IThreadChannel> get thread;

  /// The guild it was updated in
  Cacheable<Snowflake, IGuild> get guild;

  /// The members that were added. Note that they are not cached
  Iterable<Cacheable<Snowflake, IMember>> get addedMembers;

  /// The approximate number of members in the thread, capped at 50
  int get approxMemberCount;

  /// Users who were removed from the thread
  Iterable<Cacheable<Snowflake, IUser>> get removedUsers;
}

/// Fired when a thread has a member added/removed
class ThreadMembersUpdateEvent implements IThreadMembersUpdateEvent {
  /// The thread that was updated
  @override
  late final CacheableTextChannel<IThreadChannel> thread;

  /// The guild it was updated in
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// The members that were added. Note that they are not cached
  @override
  late final Iterable<Cacheable<Snowflake, IMember>> addedMembers;

  /// The approximate number of members in the thread, capped at 50
  @override
  late final int approxMemberCount;

  /// Users who were removed from the thread
  @override
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
