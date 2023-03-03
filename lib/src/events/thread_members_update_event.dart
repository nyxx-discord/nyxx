import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/channel/cacheable_text_channel.dart';
import 'package:nyxx/src/core/channel/thread_channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
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

    thread = CacheableTextChannel(client, Snowflake(data["id"]));
    guild = GuildCacheable(client, Snowflake(data["guild_id"]));
    approxMemberCount = data["member_count"] as int;

    addedMembers = [
      if (data["added_members"] != null)
        for (final memberData in data["added_members"] as RawApiList) MemberCacheable(client, Snowflake(memberData["user_id"]), guild)
    ];

    removedUsers = [
      if (data["removed_member_ids"] != null)
        for (final removedUserId in data["removed_member_ids"] as RawApiList) UserCacheable(client, Snowflake(removedUserId))
    ];
  }
}

abstract class IThreadMemberUpdateEvent {
  /// The current user's thread member that was updated.
  IThreadMember get member;
}

class ThreadMemberUpdateEvent implements IThreadMemberUpdateEvent {
  @override
  late final ThreadMember member;

  ThreadMemberUpdateEvent(RawApiMap raw, INyxx client) {
    member = ThreadMember(
      client,
      raw,
      GuildCacheable(client, Snowflake(raw['guild_id'])),
    );
  }
}
