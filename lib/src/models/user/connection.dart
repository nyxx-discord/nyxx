import 'package:nyxx/src/models/guild/integration.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// A link to an account on a service other than Discord.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/user#connection-object
class Connection with ToStringHelper {
  /// The ID of the account on the target service.
  final String id;

  /// The username of the account on the target service.
  final String name;

  /// The type of connection.
  final ConnectionType type;

  /// Whether the connection is revoked.
  final bool? isRevoked;

  /// A list of integrations associated with this connection.
  final List<PartialIntegration>? integrations;

  /// Whether the connection is verified.
  final bool isVerified;

  /// Whether friend sync is enabled for this connection.
  final bool isFriendSyncEnabled;

  /// Whether activities related to this connection will be shown in presence updates.
  final bool showActivity;

  /// Whether the connection has a corresponding third party OAuth2 token.
  final bool isTwoWayLink;

  /// The visibility of this connection.
  final ConnectionVisibility visibility;

  /// Create a new [Connection].
  /// @nodoc
  Connection({
    required this.id,
    required this.name,
    required this.type,
    required this.isRevoked,
    required this.integrations,
    required this.isVerified,
    required this.isFriendSyncEnabled,
    required this.showActivity,
    required this.isTwoWayLink,
    required this.visibility,
  });
}

/// The type of a connection.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/user#connection-object-services
enum ConnectionType {
  battleNet._('battlenet', 'Battle.net'),
  bungieNet._('bungie', 'Bungie.net'),
  bluesky._('bluesky', 'Bluesky'),
  crunchyroll._('crunchyroll', 'Crunchyroll'),
  domain._('domain', 'Domain'),
  ebay._('ebay', 'eBay'),
  epicGames._('epicgames', 'Epic Games'),
  facebook._('facebook', 'Facebook'),
  github._('github', 'GitHub'),
  instagram._('instagram', 'Instagram'),
  leagueOfLegends._('leagueoflegends', 'League of Legends'),
  mastodon._('mastodon', 'Mastodon'),
  paypal._('paypal', 'PayPal'),
  playstation._('playstation', 'PlayStation Network'),
  reddit._('reddit', 'Reddit'),
  riotGames._('riotgames', 'Riot Games'),
  roblox._('roblox', 'ROBLOX'),
  spotify._('spotify', 'Spotify'),
  skype._('skype', 'Skype'),
  steam._('steam', 'Steam'),
  tikTok._('tiktok', 'TikTok'),
  twitch._('twitch', 'Twitch'),
  twitter._('twitter', 'Twitter'),
  xbox._('xbox', 'Xbox'),
  youtube._('youtube', 'YouTube');

  /// The value of this connection type.
  final String value;

  /// A human-readable name for this connection type.
  final String name;

  const ConnectionType._(this.value, this.name);

  /// Parse a string to a [ConnectionType].
  ///
  /// The [value] must be a string containing a valid [ConnectionType.value].
  factory ConnectionType.parse(String value) => values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown ConnectionType', value),
      );
}

/// The visibility level of a connection.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/user#connection-object-visibility-types
final class ConnectionVisibility extends EnumLike<int, ConnectionVisibility> {
  static const none = ConnectionVisibility(0);
  static const everyone = ConnectionVisibility(1);

  /// @nodoc
  const ConnectionVisibility(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  ConnectionVisibility.parse(int value) : this(value);
}
