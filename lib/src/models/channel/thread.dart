import 'package:nyxx/src/http/managers/channel_manager.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/flags.dart';

/// A thread channel.
abstract class Thread implements TextChannel, GuildChannel {
  /// The ID of the user that created this thread.
  Snowflake get ownerId;

  /// An approximate count of messages in this channel.
  ///
  /// Stops counting after 50.
  int get messageCount;

  /// An approximate number of members in this thread.
  int get approximateMemberCount;

  /// Whether this thread is archived.
  bool get isArchived;

  /// The time after which this thread will be archived.
  Duration get autoArchiveDuration;

  /// The time at which this thread's archive status was last updated.
  ///
  /// Will be the creation time if [isArchived] is `false`.
  DateTime get archiveTimestamp;

  /// Whether this thread is locked.
  bool get isLocked;

  /// The time at which this thread was created.
  DateTime get createdAt;

  /// The total number of messages sent in this thread, including deleted messages.
  int get totalMessagesSent;

  /// If this thread is in a [ForumChannel], the IDs of the [ForumTag]s applied to this thread.
  List<Snowflake>? get appliedTags;

  /// The flags this thread has applied.
  ChannelFlags? get flags;

  /// The user that created this thread.
  PartialUser get owner;

  /// The member for the user that created this thread.
  PartialMember get ownerMember;

  /// Add a member to this thread.
  ///
  /// External references:
  /// * [ChannelManager.addThreadMember]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#add-thread-member
  Future<void> addThreadMember(Snowflake memberId);

  /// Remove a member from this thread.
  ///
  /// External references:
  /// * [ChannelManager.removeThreadMember]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#remove-thread-member
  Future<void> removeThreadMember(Snowflake memberId);

  /// Fetch the [ThreadMember] for a given member.
  ///
  /// External reference:
  /// * [ChannelManager.fetchThreadMember]
  /// * Discord API References: https://discord.com/developers/docs/resources/channel#remove-thread-member
  Future<ThreadMember> fetchThreadMember(Snowflake memberId, {bool? withMember});

  /// List the members of this thread.
  ///
  /// External references:
  /// * [ChannelManager.listThreadMembers]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#list-thread-members
  Future<List<ThreadMember>> listThreadMembers({bool? withMembers, Snowflake? after, int? limit});
}

/// {@template partial_thread_member}
/// A partial [ThreadMember].
/// {@endtemplate}
class PartialThreadMember {
  /// The time at which this member joined the thread.
  final DateTime joinTimestamp;

  /// Internal flags used by Discord for notification purposes.
  final Flags<Never> flags;

  /// {@macro partial_thread_member}
  /// @nodoc
  PartialThreadMember({required this.joinTimestamp, required this.flags});
}

/// {@template thread_member}
/// Additional information associated with a [Member] in a [Thread].
/// {@endtemplate}
class ThreadMember extends PartialThreadMember {
  /// The manager for this [ThreadMember].
  final ChannelManager manager;

  /// The ID of the thread this member is in.
  final Snowflake threadId;

  /// The ID of the user associated with this thread member.
  final Snowflake userId;

  final Member? member;

  /// {@macro thread_member}
  /// @nodoc
  ThreadMember({
    required super.joinTimestamp,
    required super.flags,
    required this.manager,
    required this.threadId,
    required this.userId,
    required this.member,
  });

  /// The thread this member is in.
  PartialTextChannel get thread => manager.client.channels[threadId] as PartialTextChannel;

  /// The user associated with this thread member.
  PartialUser get user => manager.client.users[userId];
}
