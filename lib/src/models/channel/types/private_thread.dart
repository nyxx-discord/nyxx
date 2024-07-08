import 'package:nyxx/src/builders/invite.dart';
import 'package:nyxx/src/builders/permission_overwrite.dart';
import 'package:nyxx/src/builders/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/invite/invite.dart';
import 'package:nyxx/src/models/invite/invite_metadata.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/models/webhook.dart';

/// {@template private_thread}
/// A private [Thread] channel.
/// {@endtemplate}
class PrivateThread extends TextChannel implements Thread {
  final bool isInvitable;

  @override
  final List<Snowflake>? appliedTags;

  @override
  final int approximateMemberCount;

  @override
  final DateTime archiveTimestamp;

  @override
  final Duration autoArchiveDuration;

  @override
  final DateTime createdAt;

  @override
  final Snowflake guildId;

  @override
  final bool isArchived;

  @override
  final bool isLocked;

  @override
  final bool isNsfw;

  @override
  final Snowflake? lastMessageId;

  @override
  final DateTime? lastPinTimestamp;

  @override
  final int messageCount;

  @override
  final String name;

  @override
  final Snowflake ownerId;

  @override
  final Snowflake? parentId;

  @override
  final List<PermissionOverwrite> permissionOverwrites;

  @override
  final int position;

  @override
  final Duration? rateLimitPerUser;

  @override
  final int totalMessagesSent;

  @override
  final ChannelFlags? flags;

  @override
  ChannelType get type => ChannelType.privateThread;

  /// {@macro private_thread}
  /// @nodoc
  PrivateThread({
    required super.id,
    required super.manager,
    required this.isInvitable,
    required this.appliedTags,
    required this.approximateMemberCount,
    required this.archiveTimestamp,
    required this.autoArchiveDuration,
    required this.createdAt,
    required this.guildId,
    required this.isArchived,
    required this.isLocked,
    required this.isNsfw,
    required this.lastMessageId,
    required this.lastPinTimestamp,
    required this.messageCount,
    required this.name,
    required this.ownerId,
    required this.parentId,
    required this.permissionOverwrites,
    required this.position,
    required this.rateLimitPerUser,
    required this.totalMessagesSent,
    required this.flags,
  });

  @override
  PartialGuild get guild => manager.client.guilds[guildId];

  @override
  PartialMessage? get lastMessage => lastMessageId == null ? null : messages[lastMessageId!];

  @override
  PartialUser get owner => manager.client.users[ownerId];

  @override
  PartialMember get ownerMember => guild.members[ownerId];

  @override
  PartialChannel? get parent => parentId == null ? null : manager.client.channels[parentId!];

  @override
  Future<void> addThreadMember(Snowflake memberId) => manager.addThreadMember(id, memberId);

  @override
  Future<void> deletePermissionOverwrite(Snowflake id) => manager.deletePermissionOverwrite(this.id, id);

  @override
  Future<ThreadMember> fetchThreadMember(Snowflake memberId) => manager.fetchThreadMember(id, memberId);

  @override
  Future<List<ThreadMember>> listThreadMembers({bool? withMembers, Snowflake? after, int? limit}) =>
      manager.listThreadMembers(id, after: after, limit: limit, withMembers: withMembers);

  @override
  Future<void> removeThreadMember(Snowflake memberId) => manager.removeThreadMember(id, memberId);

  @override
  Future<void> updatePermissionOverwrite(PermissionOverwriteBuilder builder) => manager.updatePermissionOverwrite(id, builder);

  @override
  Future<List<Webhook>> fetchWebhooks() => manager.client.webhooks.fetchChannelWebhooks(id);

  @override
  Future<List<InviteWithMetadata>> listInvites() => manager.listInvites(id);

  @override
  Future<Invite> createInvite(InviteBuilder builder, {String? auditLogReason}) => manager.createInvite(id, builder, auditLogReason: auditLogReason);

  @override
  GuildChannelBuilder<PrivateThread> toBuilder() => GuildChannelBuilder(
      name: name,
      type: type,
      permissionOverwrites: permissionOverwrites.map((e) => PermissionOverwriteBuilder(id: e.id, type: e.type, allow: e.allow, deny: e.deny)).toList(),
      position: position);
}
