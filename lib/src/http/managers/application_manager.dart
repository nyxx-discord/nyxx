import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/team.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

/// A manager for [Application]s.
// See the comment on PartialApplication for why we do not implement Manager.
class ApplicationManager {
  /// The client this manager belongs to.
  final NyxxRest client;

  /// Create a new [ApplicationManager].
  ApplicationManager(this.client);

  /// Return a partial application with the given [id].
  PartialApplication operator [](Snowflake id) => PartialApplication(id: id, manager: this);

  /// Parse an [Application] from [raw].
  Application parse(Map<String, Object?> raw) {
    return Application(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      name: raw['name'] as String,
      iconHash: raw['icon'] as String?,
      description: raw['description'] as String,
      rpcOrigins: maybeParseMany(raw['rpc_origins']),
      isBotPublic: raw['bot_public'] as bool,
      botRequiresCodeGrant: raw['bot_require_code_grant'] as bool,
      termsOfServiceUrl: maybeParse(raw['terms_of_service_url'], Uri.parse),
      privacyPolicyUrl: maybeParse(raw['privacy_policy_url'], Uri.parse),
      owner: maybeParse(
        raw['owner'],
        (Map<String, Object?> raw) => PartialUser(
          id: Snowflake.parse(raw['id'] as String),
          manager: client.users,
        ),
      ),
      verifyKey: raw['verify_key'] as String,
      team: maybeParse(raw['team'], parseTeam),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      primarySkuId: maybeParse(raw['primary_sku_id'], Snowflake.parse),
      slug: raw['slug'] as String?,
      coverImageHash: raw['cover_image'] as String?,
      flags: ApplicationFlags(raw['flags'] as int? ?? 0),
      tags: maybeParseMany(raw['tags']),
      installationParameters: maybeParse(raw['install_params'], parseInstallationParameters),
      customInstallUrl: maybeParse(raw['custom_install_url'], Uri.parse),
      roleConnectionsVerificationUrl: maybeParse(raw['role_connections_verification_url'], Uri.parse),
    );
  }

  Team parseTeam(Map<String, Object?> raw) {
    return Team(
      iconHash: raw['icon'] as String?,
      id: Snowflake.parse(raw['id'] as String),
      members: parseMany(raw['members'] as List, parseTeamMember),
      name: raw['name'] as String,
      ownerId: Snowflake.parse(raw['owner_user_id'] as String),
    );
  }

  TeamMember parseTeamMember(Map<String, Object?> raw) {
    return TeamMember(
      membershipState: TeamMembershipState.parse(raw['membership_state'] as int),
      teamId: Snowflake.parse(raw['team_id'] as String),
      user: PartialUser(id: Snowflake.parse((raw['user'] as Map<String, Object?>)['id'] as String), manager: client.users),
    );
  }

  InstallationParameters parseInstallationParameters(Map<String, Object?> raw) {
    return InstallationParameters(
      scopes: parseMany(raw['scopes'] as List),
      permissions: Permissions(int.parse(raw['permissions'] as String)),
    );
  }

  ApplicationRoleConnectionMetadata parseApplicationRoleConnectionMetadata(Map<String, Object?> raw) {
    return ApplicationRoleConnectionMetadata(
      type: ConnectionMetadataType.parse(raw['type'] as int),
      key: raw['key'] as String,
      name: raw['name'] as String,
      localizedNames: maybeParse(
        raw['name_localizations'],
        (Map<String, Object?> raw) => raw.map((key, value) => MapEntry(Locale.parse(key), value as String)),
      ),
      description: raw['description'] as String,
      localizedDescriptions: maybeParse(
        raw['description_localizations'],
        (Map<String, Object?> raw) => raw.map((key, value) => MapEntry(Locale.parse(key), value as String)),
      ),
    );
  }

  /// Fetch an application's role connection metadata.
  Future<List<ApplicationRoleConnectionMetadata>> fetchApplicationRoleConnectionMetadata(Snowflake id) async {
    final route = HttpRoute()
      ..applications(id: id.toString())
      ..roleConnections()
      ..metadata();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseMany(response.jsonBody as List<Object?>, parseApplicationRoleConnectionMetadata);
  }

  /// Update and fetch an application's role connection metadata.
  Future<List<ApplicationRoleConnectionMetadata>> updateApplicationRoleConnectionMetadata(Snowflake id) async {
    final route = HttpRoute()
      ..applications(id: id.toString())
      ..roleConnections()
      ..metadata();
    final request = BasicRequest(route, method: 'PUT');

    final response = await client.httpHandler.executeSafe(request);
    return parseMany(response.jsonBody as List<Object?>, parseApplicationRoleConnectionMetadata);
  }
}
