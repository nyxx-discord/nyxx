import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/http/managers/user_manager.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/commands/application_command_option.dart';
import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/message/author.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/flags.dart';

/// A partial [User] object.
class PartialUser extends ManagedSnowflakeEntity<User> {
  @override
  final UserManager manager;

  /// Create a new [PartialUser].
  /// @nodoc
  PartialUser({required super.id, required this.manager});
}

/// {@template user}
/// A single user, outside of a [Guild]'s context.
///
/// [User]s can be actual users, bots or teams. See [isBot] and [UserFlags.isTeamUser] to check for
/// the latter two.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/user#users-resource
/// {@endtemplate}
class User extends PartialUser implements MessageAuthor, CommandOptionMentionable<User> {
  /// The user's username.
  @override
  final String username;

  /// The user's discriminator.
  final String discriminator;

  /// The user's global display name, if it is set.
  final String? globalName;

  /// The user's avatar hash, if they have an avatar.
  @override
  final String? avatarHash;

  /// Whether the user is a bot.
  final bool isBot;

  /// Whether the user is a system user.
  final bool isSystem;

  /// Whether the user has two factor authentication enabled.
  final bool hasMfaEnabled;

  /// The user's banner hash, if they have a banner.
  final String? bannerHash;

  /// The user's accent color, if they have an accent color.
  final DiscordColor? accentColor;

  /// The user's locale, if they have a locale.
  final Locale? locale;

  /// The [UserFlags] on the user's account.
  final UserFlags? flags;

  /// The [NitroType] on the user's account.
  final NitroType nitroType;

  /// The public [UserFlags] on the user's account.
  final UserFlags? publicFlags;

  /// The hash of this user's avatar decoration.
  final String? avatarDecorationHash;

  /// {@macro user}
  /// @nodoc
  User({
    required super.manager,
    required super.id,
    required this.username,
    required this.discriminator,
    required this.globalName,
    required this.avatarHash,
    required this.isBot,
    required this.isSystem,
    required this.hasMfaEnabled,
    required this.bannerHash,
    required this.accentColor,
    required this.locale,
    required this.flags,
    required this.nitroType,
    required this.publicFlags,
    required this.avatarDecorationHash,
  });

  /// This user's banner.
  CdnAsset? get banner => bannerHash == null
      ? null
      : CdnAsset(
          client: manager.client,
          base: HttpRoute()..banners(id: id.toString()),
          hash: bannerHash!,
        );

  /// This user's default avatar.
  CdnAsset get defaultAvatar => CdnAsset(
        client: manager.client,
        base: HttpRoute()
          ..embed()
          ..avatars(),
        hash: ((id.value >> 22) % 6).toString(),
      );

  @override
  CdnAsset get avatar => avatarHash == null
      ? defaultAvatar
      : CdnAsset(
          client: manager.client,
          base: HttpRoute()..avatars(id: id.toString()),
          hash: avatarHash!,
        );

  CdnAsset? get avatarDecoration => avatarDecorationHash == null
      ? null
      : CdnAsset(
          client: manager.client,
          base: HttpRoute()..avatarDecorations(id: id.toString()),
          hash: avatarDecorationHash!,
        );
}

/// A set of [Flags] a user can have.
class UserFlags extends Flags<UserFlags> {
  /// The user is a Discord employee.
  static const staff = Flag<UserFlags>.fromOffset(0);

  /// The user is a Partnered Server Owner.
  static const partner = Flag<UserFlags>.fromOffset(1);

  /// The user is a Hypesquad Events Member.
  static const hypesquad = Flag<UserFlags>.fromOffset(2);

  /// The user has the Bug Hunter level 1 badge.
  static const bugHunter1 = Flag<UserFlags>.fromOffset(3);

  /// The user is a House of Bravery Member.
  static const hypesquadHouse1 = Flag<UserFlags>.fromOffset(6);

  /// The user is a House of Brilliance Member.
  static const hypesquadHouse2 = Flag<UserFlags>.fromOffset(7);

  /// The user is a House of Balance Member.
  static const hypesquadHouse3 = Flag<UserFlags>.fromOffset(8);

  /// The user is an Early Nitro Supporter.
  static const earlySupporter = Flag<UserFlags>.fromOffset(9);

  /// The user is a pseudo-user for a [Team].
  static const teamUser = Flag<UserFlags>.fromOffset(10);

  /// The user has the Bug Hunter level 2 badge.
  static const bugHunter2 = Flag<UserFlags>.fromOffset(14);

  /// The user is a verified bot.
  static const verifiedBot = Flag<UserFlags>.fromOffset(16);

  /// The user is an Early Verified Bot Developer.
  static const verifiedDeveloper = Flag<UserFlags>.fromOffset(17);

  /// The user is a Moderator Programs Alumni.
  static const certifierModerator = Flag<UserFlags>.fromOffset(18);

  /// The user is a bot which uses only HTTP interactions, and as such is shown as online in the
  /// member list.
  static const botHttpInteractions = Flag<UserFlags>.fromOffset(19);

  /// The user is an Active Developer.
  static const activeDeveloper = Flag<UserFlags>.fromOffset(22);

  /// Whether the user is a Discord employee.
  bool get isStaff => has(staff);

  /// Whether the user is a Partnered Server Owner.
  bool get isPartner => has(partner);

  /// Whether the user is a Hypesquad Events Member.
  bool get isHypesquad => has(hypesquad);

  /// Whether the user has the Bug Hunter level 1 badge.
  bool get isBugHunter1 => has(bugHunter1);

  /// Whether the user is a House of Bravery Member.
  bool get isHypesquadHouse1 => has(hypesquadHouse1);

  /// Whether the user is a House of Brilliance Member.
  bool get isHypesquadHouse2 => has(hypesquadHouse2);

  /// Whether the user is a House of Balance Member.
  bool get isHypesquadHouse3 => has(hypesquadHouse3);

  /// Whether the user is an Early Nitro Supporter.
  bool get isEarlySupporter => has(earlySupporter);

  /// Whether the user is a pseudo-user for a [Team].
  bool get isTeamUser => has(teamUser);

  /// Whether the user has the Bug Hunter level 2 badge.
  bool get isBugHunter2 => has(bugHunter2);

  /// Whether the user is a verified bot.
  bool get isVerifiedBot => has(verifiedBot);

  /// Whether the user is an Early Verified Bot Developer.
  bool get isVerifiedDeveloper => has(verifiedDeveloper);

  /// Whether the user is a Moderator Programs Alumni.
  bool get isCertifierModerator => has(certifierModerator);

  /// Whether the user is a bot which uses only HTTP interactions.
  bool get isBotHttpInteractions => has(botHttpInteractions);

  /// Whether the user is an Active Developer.
  bool get isActiveDeveloper => has(activeDeveloper);

  /// Create a new [UserFlags].
  const UserFlags(super.value);
}

/// The types of Discord Nitro subscription a user can have.
final class NitroType extends EnumLike<int, NitroType> {
  static const none = NitroType(0);
  static const classic = NitroType(1);
  static const nitro = NitroType(2);
  static const basic = NitroType(3);

  /// @nodoc
  const NitroType(super.value);

  NitroType.parse(int value) : this(value);
}
