import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/snowflake.dart';

class ChannelCreateEvent extends DispatchEvent {
  final Channel channel;

  ChannelCreateEvent({required this.channel});
}

class ChannelUpdateEvent extends DispatchEvent {
  final Channel? oldChannel;

  final Channel channel;

  ChannelUpdateEvent({required this.oldChannel, required this.channel});
}

class ChannelDeleteEvent extends DispatchEvent {
  final Channel channel;

  ChannelDeleteEvent({required this.channel});
}

class ThreadCreateEvent extends DispatchEvent {
  final Thread thread;

  ThreadCreateEvent({required this.thread});
}

class ThreadUpdateEvent extends DispatchEvent {
  final Thread? oldThread;

  final Thread thread;

  ThreadUpdateEvent({required this.oldThread, required this.thread});
}

class ThreadDeleteEvent extends DispatchEvent {
  final PartialChannel thread;

  ThreadDeleteEvent({required this.thread});
}

class ThreadListSyncEvent extends DispatchEvent {
  final Snowflake guildId;

  final List<Snowflake>? channelIds;

  final List<Thread> threads;

  final List<ThreadMember> members;

  ThreadListSyncEvent({
    required this.guildId,
    required this.channelIds,
    required this.threads,
    required this.members,
  });
}

class ThreadMemberUpdateEvent extends DispatchEvent {
  final ThreadMember member;

  ThreadMemberUpdateEvent({required this.member});
}

class ThreadMembersUpdateEvent extends DispatchEvent {
  final Snowflake id;

  final Snowflake guildId;

  final int memberCount;

  final List<ThreadMember>? addedMembers;

  final List<Snowflake>? removedMemberIds;

  ThreadMembersUpdateEvent({
    required this.id,
    required this.guildId,
    required this.memberCount,
    required this.addedMembers,
    required this.removedMemberIds,
  });
}

class ChannelPinsUpdateEvent extends DispatchEvent {
  final Snowflake? guildId;

  final Snowflake channelId;

  final DateTime? lastPinTimestamp;

  ChannelPinsUpdateEvent({required this.guildId, required this.channelId, required this.lastPinTimestamp});
}
