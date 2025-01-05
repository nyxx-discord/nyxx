import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/http/managers/user_manager.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class UserClan with ToStringHelper {
  final UserManager manager;

  /// The ID of this user's primary clan
  final Snowflake identityGuildId;

  /// Whether the user is displaying their clan tag
  final bool isIdentityEnabled;

  /// The text of the user's clan tag. Limited to 4 characters
  final String tag;

  /// The clan badge hash.
  final String badgeHash;

  UserClan({required this.identityGuildId, required this.badgeHash, required this.isIdentityEnabled, required this.tag, required this.manager});

  /// The guild of this user's primary clan
  PartialGuild get identifyGuild => manager.client.guilds[identityGuildId];

  /// The clan badge
  CdnAsset get badge => CdnAsset(client: manager.client, base: HttpRoute()..clanBadges(id: identityGuildId.toString()), hash: badgeHash);
}
