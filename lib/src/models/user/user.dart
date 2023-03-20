import 'package:nyxx/src/http/managers/user_manager.dart';
import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/utils/flags.dart';

/// A partial [User] object.
class PartialUser extends SnowflakeEntity<User> with SnowflakeEntityMixin<User> {
  @override
  final UserManager manager;

  /// Create a new [PartialUser].
  PartialUser({required super.id, required this.manager});
}

/// A single user, outside of a [Guild]'s context.
///
/// [User]s can be actual users, bots or teams. See [isBot] and [UserFlags.isTeamUser] to check for
/// the latter two.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/user#users-resource
class User extends PartialUser {
  /// The user's username.
  final String username;

  /// The user's discriminator.
  final String discriminator;

  /// The user's avatar hash, if they have an avatar.
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

  /// Create a new [User].
  User({
    required super.manager,
    required super.id,
    required this.username,
    required this.discriminator,
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
  });
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
enum NitroType {
  none(0),
  classic(1),
  nitro(2),
  basic(3);

  final int value;

  const NitroType(this.value);

  /// Parse an integer from the API to a [NitroType].
  ///
  /// The [value] must be a valid nitro type.
  factory NitroType.parse(int value) => NitroType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown NitroType', value),
      );

  @override
  String toString() => 'NitroType($value)';
}
