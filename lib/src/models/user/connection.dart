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
final class ConnectionType extends EnumLike<String> {
  static const battleNet = ConnectionType._('battlenet', 'Battle.net');
  static const bungieNet = ConnectionType._('bungie', 'Bungie.net');
  static const domain = ConnectionType._('domain', 'Domain');
  static const ebay = ConnectionType._('ebay', 'eBay');
  static const epicGames = ConnectionType._('epicgames', 'Epic Games');
  static const facebook = ConnectionType._('facebook', 'Facebook');
  static const github = ConnectionType._('github', 'GitHub');
  static const instagram = ConnectionType._('instagram', 'Instagram');
  static const leagueOfLegends = ConnectionType._('leagueoflegends', 'League of Legends');
  static const paypal = ConnectionType._('paypal', 'PayPal');
  static const playstation = ConnectionType._('playstation', 'PlayStation Network');
  static const reddit = ConnectionType._('reddit', 'Reddit');
  static const riotGames = ConnectionType._('riotgames', 'Riot Games');
  static const roblox = ConnectionType._('roblox', 'ROBLOX');
  static const spotify = ConnectionType._('spotify', 'Spotify');
  static const skype = ConnectionType._('skype', 'Skype');
  static const steam = ConnectionType._('steam', 'Steam');
  static const tikTok = ConnectionType._('tiktok', 'TikTok');
  static const twitch = ConnectionType._('twitch', 'Twitch');
  static const twitter = ConnectionType._('twitter', 'Twitter');
  static const xbox = ConnectionType._('xbox', 'Xbox');
  static const youtube = ConnectionType._('youtube', 'YouTube');

  static const List<ConnectionType> values = [
    battleNet,
    bungieNet,
    domain,
    ebay,
    epicGames,
    facebook,
    github,
    instagram,
    leagueOfLegends,
    paypal,
    playstation,
    reddit,
    riotGames,
    roblox,
    spotify,
    skype,
    steam,
    tikTok,
    twitch,
    twitter,
    xbox,
    youtube,
  ];

  /// A human-readable name for this connection type.
  final String name;

  const ConnectionType._(super.value, this.name);

  /// Parse a string to a [ConnectionType].
  ///
  /// The [value] must be a string containing a valid [ConnectionType.value].
  factory ConnectionType.parse(String value) => parseEnum(values, value);
}

/// The visibility level of a connection.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/user#connection-object-visibility-types
final class ConnectionVisibility extends EnumLike<int> {
  static const none = ConnectionVisibility._(0);
  static const everyone = ConnectionVisibility._(1);

  static const List<ConnectionVisibility> values = [none, everyone];

  const ConnectionVisibility._(super.value);

  factory ConnectionVisibility.parse(int value) => parseEnum(values, value);
}
