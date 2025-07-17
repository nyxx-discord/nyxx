import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/http/managers/user_manager.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class UserPrimaryGuild with ToStringHelper {
  final UserManager manager;

  /// The id of this user's primary guild.
  final Snowflake identityGuildId;

  /// Whether the user is displaying their primary guild tag.
  final bool isIdentityEnabled;

  /// The text of the user's server tag. Limited to 4 characters.
  final String tag;

  /// The server tag badge hash.
  final String badgeHash;

  /// @nodoc
  UserPrimaryGuild({required this.identityGuildId, required this.badgeHash, required this.isIdentityEnabled, required this.tag, required this.manager});

  /// The guild of this user's primary guild.
  PartialGuild get identifyGuild => manager.client.guilds[identityGuildId];

  /// The server tag as an asset.
  CdnAsset get badge => CdnAsset(client: manager.client, base: HttpRoute()..guildTagBadges(id: identityGuildId.toString()), hash: badgeHash);
}
