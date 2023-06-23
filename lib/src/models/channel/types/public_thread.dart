import 'package:nyxx/src/builders/invite.dart';
import 'package:nyxx/src/builders/permission_overwrite.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/invite/invite.dart';
import 'package:nyxx/src/models/invite/invite_metadata.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/webhook.dart';

/// {@template public_thread}
/// A public [Thread] channel.
/// {@endtemplate}
class PublicThread extends TextChannel implements Thread {
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
  ChannelType get type => ChannelType.publicThread;

  /// {@macro public_thread}
  PublicThread({
    required super.id,
    required super.manager,
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
}
