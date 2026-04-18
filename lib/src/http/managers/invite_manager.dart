import 'dart:convert';

import 'package:http/http.dart' hide MultipartRequest;
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/invite/invite.dart';
import 'package:nyxx/src/models/invite/invite_metadata.dart';
import 'package:nyxx/src/models/invite/job_status.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

/// A manager for [Invite]s.
///
/// {@category managers}
class InviteManager {
  /// The client this [InviteManager] is for.
  final NyxxRest client;

  /// Create a new [InviteManager].
  InviteManager(this.client);

  /// Parse an [Invite] from [raw].
  Invite parse(Map<String, Object?> raw) {
    final guild = maybeParse(
      raw['guild'],
      (Map<String, Object?> raw) => PartialGuild(id: Snowflake.parse(raw['id']!), manager: client.guilds),
    );

    return Invite(
      manager: this,
      type: InviteType(raw['type'] as int),
      code: raw['code'] as String,
      guild: guild,
      channel: PartialChannel(id: Snowflake.parse((raw['channel'] as Map<String, Object?>)['id']!), manager: client.channels),
      inviter: maybeParse(raw['inviter'], client.users.parse),
      targetType: maybeParse(raw['target_type'], TargetType.new),
      targetUser: maybeParse(raw['target_user'], client.users.parse),
      targetApplication: maybeParse(
        raw['target_application'],
        (Map<String, Object?> raw) => PartialApplication(id: Snowflake.parse(raw['id']!), manager: client.applications),
      ),
      approximatePresenceCount: raw['approximate_presence_count'] as int?,
      approximateMemberCount: raw['approximate_member_count'] as int?,
      expiresAt: maybeParse(raw['expires_at'], DateTime.parse),
      // Don't use a tearoff so we don't evaluate `guild!` unless guild_scheduled_event is set.
      guildScheduledEvent: maybeParse(raw['guild_scheduled_event'], (Map<String, Object?> raw) => guild!.scheduledEvents.parse(raw)),
      flags: maybeParse(raw['flags'], GuildInviteFlags.new),
      roles: maybeParseMany(raw['roles'], (Map<String, Object?> raw) => guild!.roles[Snowflake.parse(raw['id']!)]),
    );
  }

  /// Parse an [InviteWithMetadata] from [raw].
  InviteWithMetadata parseWithMetadata(Map<String, Object?> raw) {
    final invite = parse(raw);

    return InviteWithMetadata(
      manager: this,
      type: invite.type,
      code: invite.code,
      guild: invite.guild,
      channel: invite.channel,
      inviter: invite.inviter,
      targetType: invite.targetType,
      targetUser: invite.targetUser,
      targetApplication: invite.targetApplication,
      approximatePresenceCount: invite.approximatePresenceCount,
      approximateMemberCount: invite.approximateMemberCount,
      expiresAt: invite.expiresAt,
      guildScheduledEvent: invite.guildScheduledEvent,
      flags: invite.flags,
      roles: invite.roles,
      uses: raw['uses'] as int,
      maxUses: raw['max_uses'] as int,
      maxAge: Duration(seconds: raw['max_age'] as int),
      isTemporary: raw['temporary'] as bool,
      createdAt: DateTime.parse(raw['created_at'] as String),
    );
  }

  InviteTargetsJobStatus parseInviteTargetsJobStatus(Map<String, Object?> raw) {
    return InviteTargetsJobStatus(
      status: InviteTargetsJobStatusType(raw['status'] as int),
      totalUsers: raw['total_users'] as int,
      processedUsers: raw['processed_users'] as int,
      createdAt: DateTime.parse(raw['created_at'] as String),
      completedAt: maybeParse(raw['created_at'], DateTime.parse),
      errorMessage: raw['error_message'] as String?,
    );
  }

  Future<Invite> fetch(String code, {bool? withCounts, bool? withExpiration, Snowflake? scheduledEventId}) async {
    final route = HttpRoute()..invites(id: code);
    final request = BasicRequest(route, queryParameters: {
      if (withCounts != null) 'with_counts': withCounts.toString(),
      if (withExpiration != null) 'with_expiration': withExpiration.toString(),
      if (scheduledEventId != null) 'guild_scheduled_event_id': scheduledEventId.toString(),
    });

    final response = await client.httpHandler.executeSafe(request);
    final invite = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(invite);
    return invite;
  }

  /// Delete an invite.
  Future<Invite> delete(String code, {String? auditLogReason}) async {
    final route = HttpRoute()..invites(id: code);
    final request = BasicRequest(route, method: 'DELETE', auditLogReason: auditLogReason);

    final response = await client.httpHandler.executeSafe(request);
    final invite = parse(response.jsonBody as Map<String, Object?>);

    // Invites aren't cached, so we don't need to remove it, but it still contains nested objects we can cache.
    client.updateCacheWith(invite);
    return invite;
  }

  /// Fetch the users the specified invite is for.
  Future<List<PartialUser>> fetchTargetUsers(String code) async {
    final route = HttpRoute()
      ..invites(id: code)
      ..targetUsers();
    final request = BasicRequest(route, method: 'GET');

    final response = await client.httpHandler.executeSafe(request);
    return LineSplitter().convert(response.textBody!).skip(1).map(Snowflake.parse).map((id) => client.users[id]).toList();
  }

  /// Update the users targeted by the specified invite.
  Future<void> updateTargetUsers(String code, List<Snowflake> userIds) async {
    final route = HttpRoute()
      ..invites(id: code)
      ..targetUsers();
    final request = MultipartRequest(
      route,
      method: 'PUT',
      files: [MultipartFile.fromString('target_users_file', filename: 'target_users.csv', userIds.join('\n'))],
    );

    await client.httpHandler.executeSafe(request);
  }

  Future<InviteTargetsJobStatus> fetchTargetUsersJobStatus(String code) async {
    final route = HttpRoute()
      ..invites(id: code)
      ..targetUsers()
      ..jobStatus();
    final request = BasicRequest(route, method: 'GET');

    final response = await client.httpHandler.executeSafe(request);
    return parseInviteTargetsJobStatus(response.jsonBody as Map<String, Object?>);
  }
}
