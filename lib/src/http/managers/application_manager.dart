import 'dart:convert';

import 'package:nyxx/src/builders/application.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/sku.dart';
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
      id: Snowflake.parse(raw['id']!),
      manager: this,
      name: raw['name'] as String,
      iconHash: raw['icon'] as String?,
      description: raw['description'] as String,
      rpcOrigins: maybeParseMany(raw['rpc_origins']),
      isBotPublic: raw['bot_public'] as bool,
      botRequiresCodeGrant: raw['bot_require_code_grant'] as bool,
      bot: maybeParse(raw['bot'], (Map<String, Object?> raw) => PartialUser(id: Snowflake.parse(raw['id']!), manager: client.users)),
      termsOfServiceUrl: maybeParse(raw['terms_of_service_url'], Uri.parse),
      privacyPolicyUrl: maybeParse(raw['privacy_policy_url'], Uri.parse),
      owner: maybeParse(
        raw['owner'],
        (Map<String, Object?> raw) => PartialUser(
          id: Snowflake.parse(raw['id']!),
          manager: client.users,
        ),
      ),
      verifyKey: raw['verify_key'] as String,
      team: maybeParse(raw['team'], parseTeam),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      guild: maybeParse(raw['guild'], (Map<String, Object?> raw) => PartialGuild(id: Snowflake.parse(raw['id']!), manager: client.guilds)),
      primarySkuId: maybeParse(raw['primary_sku_id'], Snowflake.parse),
      slug: raw['slug'] as String?,
      coverImageHash: raw['cover_image'] as String?,
      flags: ApplicationFlags(raw['flags'] as int? ?? 0),
      approximateGuildCount: raw['approximate_guild_count'] as int?,
      redirectUris: maybeParseMany(raw['redirect_uris'], Uri.parse),
      interactionsEndpointUrl: maybeParse(raw['interactions_endpoint_url'], Uri.parse),
      tags: maybeParseMany(raw['tags']),
      installationParameters: maybeParse(raw['install_params'], parseInstallationParameters),
      customInstallUrl: maybeParse(raw['custom_install_url'], Uri.parse),
      integrationTypesConfig: maybeParse(
        raw['integration_types_config'],
        (Map<String, Object?> config) => {
          for (final MapEntry(:key, :value) in config.entries)
            ApplicationIntegrationType(int.parse(key)): parseApplicationIntegrationTypeConfiguration(value as Map<String, Object?>)
        },
      ),
      roleConnectionsVerificationUrl: maybeParse(raw['role_connections_verification_url'], Uri.parse),
      approximateUserInstallCount: raw['approximate_user_install_count'] as int?,
    );
  }

  /// Parse a [Team] from [raw].
  Team parseTeam(Map<String, Object?> raw) {
    return Team(
      manager: this,
      iconHash: raw['icon'] as String?,
      id: Snowflake.parse(raw['id']!),
      members: parseMany(raw['members'] as List, parseTeamMember),
      name: raw['name'] as String,
      ownerId: Snowflake.parse(raw['owner_user_id']!),
    );
  }

  /// Parse a [TeamMember] from [raw].
  TeamMember parseTeamMember(Map<String, Object?> raw) {
    return TeamMember(
      membershipState: TeamMembershipState(raw['membership_state'] as int),
      teamId: Snowflake.parse(raw['team_id']!),
      user: PartialUser(id: Snowflake.parse((raw['user'] as Map<String, Object?>)['id']!), manager: client.users),
      role: TeamMemberRole.parse(raw['role'] as String),
    );
  }

  /// Parse a [InstallationParameters] from [raw].
  InstallationParameters parseInstallationParameters(Map<String, Object?> raw) {
    return InstallationParameters(
      scopes: parseMany(raw['scopes'] as List),
      permissions: Permissions(int.parse(raw['permissions'] as String)),
    );
  }

  /// Parse a [ApplicationIntegrationTypeConfiguration] from [raw].
  ApplicationIntegrationTypeConfiguration parseApplicationIntegrationTypeConfiguration(Map<String, Object?> raw) {
    return ApplicationIntegrationTypeConfiguration(
      oauth2InstallParameters: maybeParse(raw['oauth2_install_params'], parseInstallationParameters),
    );
  }

  /// Parse a [ApplicationRoleConnectionMetadata] from [raw].
  ApplicationRoleConnectionMetadata parseApplicationRoleConnectionMetadata(Map<String, Object?> raw) {
    return ApplicationRoleConnectionMetadata(
      type: ConnectionMetadataType(raw['type'] as int),
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

  /// Parse a [Sku] from [raw].
  @Deprecated('Use SkuManager.parse')
  Sku parseSku(Map<String, Object?> raw) {
    final applicationId = Snowflake.parse(raw['application_id']!);

    return client.applications[applicationId].skus.parse(raw);
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

  /// Fetch the current application.
  Future<Application> fetchCurrentApplication() async {
    final route = HttpRoute()..applications(id: '@me');
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parse(response.jsonBody as Map<String, Object?>);
  }

  /// Fetch the current OAuth2 application.
  Future<Application> fetchOAuth2CurrentApplication() async {
    final route = HttpRoute()
      ..oauth2()
      ..applications(id: '@me');
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parse(response.jsonBody as Map<String, Object?>);
  }

  /// Update the current application.
  Future<Application> updateCurrentApplication(ApplicationUpdateBuilder builder) async {
    final route = HttpRoute()..applications(id: '@me');
    final request = BasicRequest(route, method: 'PATCH', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    return parse(response.jsonBody as Map<String, Object?>);
  }

  /// List this application's SKUs.
  @Deprecated('Use SkuManager.list')
  Future<List<Sku>> listSkus(Snowflake id) => client.applications[id].skus.list();
}
