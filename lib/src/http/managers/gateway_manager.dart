import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/gateway/gateway.dart';
import 'package:nyxx/src/models/presence.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

/// A [Manager] for gateway information.
// Use an abstract class so the client getter can be abstract,
// allowing us to override it in Gateway to have a more specific type.
abstract class GatewayManager {
  /// The client this manager is for.
  NyxxRest get client;

  /// @nodoc
  // We need a constructor to be allowed to use this class as a superclass.
  GatewayManager.create();

  /// Create a new [GatewayManager].
  factory GatewayManager(NyxxRest client) = _GatewayManagerImpl;

  GatewayConfiguration parseGatewayConfiguration(Map<String, Object?> raw) {
    return GatewayConfiguration(url: Uri.parse(raw['url'] as String));
  }

  GatewayBot parseGatewayBot(Map<String, Object?> raw) {
    return GatewayBot(
      url: Uri.parse(raw['url'] as String),
      shards: raw['shards'] as int,
      sessionStartLimit: parseSessionStartLimit(raw['session_start_limit'] as Map<String, Object?>),
    );
  }

  SessionStartLimit parseSessionStartLimit(Map<String, Object?> raw) {
    return SessionStartLimit(
      total: raw['total'] as int,
      remaining: raw['remaining'] as int,
      resetAfter: Duration(milliseconds: raw['reset_after'] as int),
      maxConcurrency: raw['max_concurrency'] as int,
    );
  }

  Activity parseActivity(Map<String, Object?> raw) {
    // No fields are validated server-side. Expect errors.
    return Activity(
      name: raw['name'] as String,
      type: ActivityType(raw['type'] as int),
      url: tryParse(raw['url'], Uri.parse),
      createdAt: tryParse(raw['created_at'], DateTime.fromMillisecondsSinceEpoch),
      timestamps: tryParse(raw['timestamps'], parseActivityTimestamps),
      applicationId: tryParse(raw['application_id'], Snowflake.parse),
      details: tryParse(raw['details']),
      state: tryParse(raw['state']),
      emoji: tryParse(raw['emoji'], client.guilds[Snowflake.zero].emojis.parse),
      party: tryParse(raw['party'], parseActivityParty),
      assets: tryParse(raw['assets'], parseActivityAssets),
      secrets: tryParse(raw['secrets'], parseActivitySecrets),
      isInstance: tryParse(raw['instance']),
      flags: tryParse(raw['flags'], ActivityFlags.new),
      buttons: tryParseMany(raw['buttons'], parseActivityButton),
    );
  }

  ActivityTimestamps parseActivityTimestamps(Map<String, Object?> raw) {
    return ActivityTimestamps(
      start: maybeParse(raw['start'], (int milliseconds) => DateTime.fromMillisecondsSinceEpoch(milliseconds)),
      end: maybeParse(raw['end'], (int milliseconds) => DateTime.fromMillisecondsSinceEpoch(milliseconds)),
    );
  }

  ActivityParty parseActivityParty(Map<String, Object?> raw) {
    return ActivityParty(
      id: raw['id'] as String?,
      currentSize: (raw['size'] as List<Object?>?)?[0] as int?,
      maxSize: (raw['size'] as List<Object?>?)?[1] as int?,
    );
  }

  ActivityAssets parseActivityAssets(Map<String, Object?> raw) {
    return ActivityAssets(
      largeImage: raw['large_image'] as String?,
      largeText: raw['large_text'] as String?,
      smallImage: raw['small_image'] as String?,
      smallText: raw['small_text'] as String?,
    );
  }

  ActivitySecrets parseActivitySecrets(Map<String, Object?> raw) {
    return ActivitySecrets(
      join: raw['join'] as String?,
      spectate: raw['spectate'] as String?,
      match: raw['match'] as String?,
    );
  }

  ActivityButton parseActivityButton(Map<String, Object?> raw) {
    return ActivityButton(
      label: raw['label'] as String,
      url: Uri.parse(raw['url'] as String),
    );
  }

  ClientStatus parseClientStatus(Map<String, Object?> raw) {
    return ClientStatus(
      desktop: maybeParse(raw['desktop'], UserStatus.new),
      mobile: maybeParse(raw['mobile'], UserStatus.new),
      web: maybeParse(raw['web'], UserStatus.new),
    );
  }

  /// Fetch the current gateway configuration.
  Future<GatewayConfiguration> fetchGatewayConfiguration() async {
    final route = HttpRoute()..gateway();
    final request = BasicRequest(route, authenticated: false);

    final response = await client.httpHandler.executeSafe(request);
    return parseGatewayConfiguration(response.jsonBody as Map<String, Object?>);
  }

  /// Fetch the current gateway configuration for the client.
  Future<GatewayBot> fetchGatewayBot() async {
    final route = HttpRoute()
      ..gateway()
      ..bot();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseGatewayBot(response.jsonBody as Map<String, Object?>);
  }
}

class _GatewayManagerImpl extends GatewayManager {
  @override
  final NyxxRest client;

  _GatewayManagerImpl(this.client) : super.create();
}
