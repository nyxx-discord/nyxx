import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/invite/invite.dart';
import 'package:nyxx/src/models/invite/invite_metadata.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

/// A manager for [Invite]s.
class InviteManager {
  final NyxxRest client;

  InviteManager(this.client);

  Invite parse(Map<String, Object?> raw) {
    return Invite(
      code: raw['code'] as String,
      // TODO: is object
      guild: raw['guild'],
      channel: PartialChannel(id: Snowflake.parse((raw['channel'] as Map<String, Object?>)['id'] as String), manager: client.channels),
      inviter: maybeParse(
        raw['inviter'],
        client.users.parse,
      ),
      targetType: maybeParse(
        raw['target_type'],
        TargetType.parse,
      ),
      targetUser: maybeParse(
        raw['target_user'],
        client.users.parse,
      ),
      targetApplication: maybeParse(
        raw['target_application'],
        (Map<String, Object?> raw) => PartialApplication(
          id: Snowflake.parse(raw['id'] as String),
        ),
      ),
      approximatePresenceCount: raw['approximate_presence_count'] as int?,
      approximateMemberCount: raw['approximate_member_count'] as int?,
      expiresAt: maybeParse(raw['expires_at'], DateTime.parse),
      // TODO: is object
      guildScheduledEvent: raw['guild_scheduled_event'],
    );
  }

  InviteMetadata parseMetadata(Map<String, Object?> raw) {
    final invite = parse(raw);
    return InviteMetadata(
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

  Future<Invite> fetch(String code, {bool? withCounts, bool? withExpiration, Snowflake? guildSchedueledEventId}) async {
    final route = HttpRoute()..invites(id: code);
    final request = BasicRequest(route, queryParameters: {
      if (withCounts != null) 'with_counts': withCounts.toString(),
      if (withExpiration != null) 'with_expiration': withExpiration.toString(),
      if (guildSchedueledEventId != null) 'guild_scheduled_event_id': guildSchedueledEventId.toString(),
    });

    final response = await client.httpHandler.executeSafe(request);
    return parse(response.jsonBody as Map<String, Object?>);
  }

  Future<Invite> delete(String code) async {
    final route = HttpRoute()..invites(id: code);
    final request = BasicRequest(route, method: 'DELETE');

    final response = await client.httpHandler.executeSafe(request);
    return parse(response.jsonBody as Map<String, Object?>);
  }
}
