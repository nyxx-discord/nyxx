import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/invite/invite.dart';
import 'package:nyxx/src/models/invite/invite_metadata.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

/// A manager for [Invite]s.
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
      code: raw['code'] as String,
      guild: guild,
      channel: PartialChannel(id: Snowflake.parse((raw['channel'] as Map<String, Object?>)['id']!), manager: client.channels),
      inviter: maybeParse(raw['inviter'], client.users.parse),
      targetType: maybeParse(raw['target_type'], TargetType.parse),
      targetUser: maybeParse(raw['target_user'], client.users.parse),
      targetApplication: maybeParse(
        raw['target_application'],
        (Map<String, Object?> raw) => PartialApplication(id: Snowflake.parse(raw['id']!), manager: client.applications),
      ),
      approximatePresenceCount: raw['approximate_presence_count'] as int?,
      approximateMemberCount: raw['approximate_member_count'] as int?,
      expiresAt: maybeParse(raw['expires_at'], DateTime.parse),
      // Don't use a tearoff so we don't evaluate `guild!.id` unless guild_scheduled_event is set.
      guildScheduledEvent: maybeParse(raw['guild_scheduled_event'], (Map<String, Object?> raw) => client.guilds[guild!.id].scheduledEvents.parse(raw)),
    );
  }

  InviteWithMetadata parseWithMetadata(Map<String, Object?> raw) {
    final invite = parse(raw);

    return InviteWithMetadata(
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
      uses: raw['uses'] as int,
      maxUses: raw['max_uses'] as int,
      maxAge: Duration(seconds: raw['max_age'] as int),
      isTemporary: raw['temporary'] as bool,
      createdAt: DateTime.parse(raw['created_at'] as String),
    );
  }

  /// Fetch an invite.
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
  Future<Invite> delete(String code) async {
    final route = HttpRoute()..invites(id: code);
    final request = BasicRequest(route, method: 'DELETE');

    final response = await client.httpHandler.executeSafe(request);
    final invite = parse(response.jsonBody as Map<String, Object?>);

    // Invites aren't cached, so we don't need to remove it, but it still contains nested objects we can cache.
    client.updateCacheWith(invite);
    return invite;
  }
}
