import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class UserClan with ToStringHelper {
  final NyxxRest _client;

  /// The ID of this user's primary clan
  final Snowflake identityGuildId;

  /// Whether the user is displaying their clan tag
  final bool isIdentityEnabled;

  /// The text of the user's clan tag. Limited to 4 characters
  final String tag;

  /// The clan badge hash.
  final String badgeHash;

  UserClan({required this.identityGuildId, required this.badgeHash, required this.isIdentityEnabled, required this.tag, required NyxxRest client})
      : _client = client;

  /// The guild of this user's primary clan
  PartialGuild get identifyGuild => PartialGuild(id: identityGuildId, manager: _client.guilds);

  /// The clan badge
  CdnAsset get badge => CdnAsset(client: _client, base: HttpRoute()..clanBadges(id: identityGuildId.toString()), hash: badgeHash);
}
