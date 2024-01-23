import 'package:nyxx/src/errors.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/guild/integration.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

/// A [Manager] for [Integration]s.
class IntegrationManager extends ReadOnlyManager<Integration> {
  /// The ID of the guild this manager is for.
  final Snowflake guildId;

  /// Create a new [IntegrationManager].
  IntegrationManager(super.config, super.client, {required this.guildId}) : super(identifier: '$guildId.integrations');

  @override
  PartialIntegration operator [](Snowflake id) => PartialIntegration(id: id, manager: this);

  @override
  Integration parse(Map<String, Object?> raw) {
    return Integration(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      name: raw['name'] as String,
      type: raw['type'] as String,
      isEnabled: raw['enabled'] as bool,
      isSyncing: raw['syncing'] as bool?,
      roleId: maybeParse(raw['role_id'], Snowflake.parse),
      enableEmoticons: raw['enable_emoticons'] as bool?,
      expireBehavior: maybeParse(raw['expire_behavior'], IntegrationExpireBehavior.parse),
      expireGracePeriod: maybeParse(raw['expire_grace_period'], (int value) => Duration(days: value)),
      user: maybeParse(raw['user'], client.users.parse),
      account: parseIntegrationAccount(raw['account'] as Map<String, Object?>),
      syncedAt: maybeParse(raw['synced_at'], DateTime.parse),
      subscriberCount: raw['subscriber_count'] as int?,
      isRevoked: raw['revoked'] as bool?,
      application: maybeParse(raw['application'], parseIntegrationApplication),
      scopes: maybeParseMany(raw['scopes']),
    );
  }

  /// Parse an [IntegrationAccount] from [raw].
  IntegrationAccount parseIntegrationAccount(Map<String, Object?> raw) {
    return IntegrationAccount(
      id: Snowflake.parse(raw['id']!),
      name: raw['name'] as String,
    );
  }

  /// Parse an [IntegrationApplication] from [raw].
  IntegrationApplication parseIntegrationApplication(Map<String, Object?> raw) {
    return IntegrationApplication(
      id: Snowflake.parse(raw['id']!),
      name: raw['name'] as String,
      iconHash: raw['icon'] as String?,
      description: raw['description'] as String,
      bot: maybeParse(raw['bot'], client.users.parse),
    );
  }

  @override
  Future<Integration> fetch(Snowflake id) async {
    final integrations = await list();

    return integrations.firstWhere(
      (integration) => integration.id == id,
      orElse: () => throw IntegrationNotFoundException(guildId, id),
    );
  }

  /// List the integrations in the guild.
  Future<List<Integration>> list() async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..integrations();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final integrations = parseMany(response.jsonBody as List, parse);

    integrations.forEach(client.updateCacheWith);
    return integrations;
  }

  /// Delete an integration from the guild.
  Future<void> delete(Snowflake id, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..integrations(id: id.toString());
    final request = BasicRequest(route, method: 'DELETE', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);

    cache.remove(id);
  }
}
