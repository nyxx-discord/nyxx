import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/snowflake.dart';

/// {@template channel_create_event}
/// Emitted when a channel is created.
/// {@endtemplate}
class ChannelCreateEvent extends DispatchEvent {
  /// The created channel.
  final Channel channel;

  /// {@macro channel_create_event}
  ChannelCreateEvent({required this.channel});
}

/// {@template channel_update_event}
/// Emitted when a channel is updated.
/// {@endtemplate}
class ChannelUpdateEvent extends DispatchEvent {
  /// The channel as it was in the cache before it was updated.
  final Channel? oldChannel;

  /// The updated channel.
  final Channel channel;

  /// {@macro channel_update_event}
  ChannelUpdateEvent({required this.oldChannel, required this.channel});
}

/// {@template channel_delete_event}
/// Emitted when a channel is deleted.
/// {@endtemplate}
class ChannelDeleteEvent extends DispatchEvent {
  /// The channel which was deleted.
  final Channel channel;

  /// {@macro channel_delete_event}
  ChannelDeleteEvent({required this.channel});
}

/// {@template thread_create_event}
/// Emitted when a thread is created.
/// {@endtemplate}
class ThreadCreateEvent extends DispatchEvent {
  /// The thread that was created.
  final Thread thread;

  /// {@macro thread_create_event}
  ThreadCreateEvent({required this.thread});
}

/// {@template thread_update_event}
/// Emitted when a thread is updated.
/// {@endtemplate}
class ThreadUpdateEvent extends DispatchEvent {
  /// The thread as it was cached before it was updated.
  final Thread? oldThread;

  /// The updated thread.
  final Thread thread;

  /// {@macro thread_update_event}
  ThreadUpdateEvent({required this.oldThread, required this.thread});
}

/// {@template thread_delete_event}
/// Emitted when a thread is deleted.
/// {@endtemplate}
class ThreadDeleteEvent extends DispatchEvent {
  /// The thread which was deleted.
  final PartialChannel thread;

  /// {@macro thread_delete_event}
  ThreadDeleteEvent({required this.thread});
}

/// {@template thread_list_sync_event}
/// Emitted when the client's thread list is synced.
/// {@endtemplate}
class ThreadListSyncEvent extends DispatchEvent {
  /// The ID of the guild threads are syncing for.
  final Snowflake guildId;

  /// The IDs of the channels the threads are syncing for, or `null` if the entire guild is syncing.
  final List<Snowflake>? channelIds;

  /// The synced threads.
  final List<Thread> threads;

  /// The members of the synced threads.
  final List<ThreadMember> members;

  /// {@macro thread_list_sync_event}
  ThreadListSyncEvent({
    required this.guildId,
    required this.channelIds,
    required this.threads,
    required this.members,
  });
}

/// {@template thread_member_update_event}
/// Emitted when the client's thread member is updated.
/// {@endtemplate}
class ThreadMemberUpdateEvent extends DispatchEvent {
  /// The updated member.
  final ThreadMember member;

  /// {@macro thread_member_update_event}
  ThreadMemberUpdateEvent({required this.member});
}

/// {@template thread_members_update_event}
/// Emitted when a members in a thread are updated.
/// {@endtemplate}
class ThreadMembersUpdateEvent extends DispatchEvent {
  /// The ID of the thread the members were updated in.
  final Snowflake id;

  /// The ID of the guild the thread is in.
  final Snowflake guildId;

  /// The number of members in the thread.
  final int memberCount;

  /// A list of members added to the thread.
  final List<ThreadMember>? addedMembers;

  /// A list of the IDs of the removed members.
  final List<Snowflake>? removedMemberIds;

  /// {@macro thread_members_update_event}
  ThreadMembersUpdateEvent({
    required this.id,
    required this.guildId,
    required this.memberCount,
    required this.addedMembers,
    required this.removedMemberIds,
  });
}

/// {@template channel_pins_update_event}
/// Emitted when the pinned messages in a channel are changed.
/// {@endtemplate}
class ChannelPinsUpdateEvent extends DispatchEvent {
  /// The ID of the guild the channel is in.
  final Snowflake? guildId;

  /// The ID of the channel the pins were updated in.
  final Snowflake channelId;

  /// The time at which the last message was pinned.
  final DateTime? lastPinTimestamp;

  /// {@macro channel_pins_update_event}
  ChannelPinsUpdateEvent({required this.guildId, required this.channelId, required this.lastPinTimestamp});
}
