import 'package:nyxx/src/models/guild/integration.dart';
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
  ebay._('ebay', 'eBay'),
  epicGames._('epicgames', 'Epic Games'),
  facebook._('facebook', 'Facebook'),
  github._('github', 'GitHub'),
  instagram._('instagram', 'Instagram'),
  leagueOfLegends._('leagueoflegends', 'League of Legends'),
  paypal._('paypal', 'PayPal'),
  playstation._('playstation', 'PlayStation Network'),
  reddit._('reddit', 'Reddit'),
  riotGames._('riotgames', 'Riot Games'),
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
  factory ConnectionType.parse(String value) => ConnectionType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown ConnectionType', value),
      );

  @override
  String toString() => 'ConnectionType($name)';
}

/// The visibility level of a connection.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/user#connection-object-visibility-types
enum ConnectionVisibility {
  none._(0),
  everyone._(1);

  /// THe value of this connection visibility level.
  final int value;

  const ConnectionVisibility._(this.value);

  /// Parse an integer value to a [ConnectionVisibility].
  ///
  /// The [value] must be a valid [ConnectionVisibility].
  factory ConnectionVisibility.parse(int value) => ConnectionVisibility.values.firstWhere(
        (visibility) => visibility.value == value,
        orElse: () => throw FormatException('Unknown ConnectionVisibility', value),
      );

  @override
  String toString() => 'ConnectionVisibility($name)';
}
