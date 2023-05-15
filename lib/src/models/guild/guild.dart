import 'package:nyxx/src/http/managers/guild_manager.dart';
import 'package:nyxx/src/http/managers/member_manager.dart';
import 'package:nyxx/src/http/managers/role_manager.dart';
import 'package:nyxx/src/models/guild/welcome_screen.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/utils/flags.dart';

class PartialGuild extends SnowflakeEntity<Guild> with SnowflakeEntityMixin<Guild> {
  @override
  final GuildManager manager;

  MemberManager get members => MemberManager(manager.client.options.memberCacheConfig, manager.client, guildId: id);

  RoleManager get roles => RoleManager(manager.client.options.roleCacheConfig, manager.client, guildId: id);

  PartialGuild({required super.id, required this.manager});
}

class Guild extends PartialGuild {
  final String name;

  final String? iconHash;

  final String? splashHash;

  final String? discoverySplashHash;

  final bool? isOwnedByCurrentUser;

  final Snowflake ownerId;

  final Permissions? currentUserPermissions;

  final Snowflake? afkChannelId;

  final Duration afkTimeout;

  final bool isWidgetEnabled;

  final Snowflake? widgetChannelId;

  final VerificationLevel verificationLevel;

  final MessageNotificationLevel defaultMessageNotificationLevel;

  final ExplicitContentFilterLevel explicitContentFilterLevel;

  // TODO
  //final List<Role> roles;

  // TODO
  //final List<Emoji> emojis;

  final GuildFeatures features;

  final MfaLevel mfaLevel;

  final Snowflake? applicationId;

  final Snowflake? systemChannelId;

  final SystemChannelFlags systemChannelFlags;

  final Snowflake? rulesChannelId;

  final int? maxPresences;

  final int? maxMembers;

  final String? vanityUrlCode;

  final String? description;

  final String? bannerHash;

  final PremiumTier premiumTier;

  final int? premiumSubscriptionCount;

  final Locale preferredLocale;

  final Snowflake? publicUpdatesChannelId;

  final int? maxVideoChannelUsers;

  final int? maxStageChannelUsers;

  final int? approximateMemberCount;

  final int? approximatePresenceCount;

  final WelcomeScreen? welcomeScreen;

  final NsfwLevel nsfwLevel;

  // TODO
  //final List<Sticker> stickers;

  final bool hasPremiumProgressBarEnabled;

  Guild({
    required super.id,
    required super.manager,
    required this.name,
    required this.iconHash,
    required this.splashHash,
    required this.discoverySplashHash,
    required this.isOwnedByCurrentUser,
    required this.ownerId,
    required this.currentUserPermissions,
    required this.afkChannelId,
    required this.afkTimeout,
    required this.isWidgetEnabled,
    required this.widgetChannelId,
    required this.verificationLevel,
    required this.defaultMessageNotificationLevel,
    required this.explicitContentFilterLevel,
    required this.features,
    required this.mfaLevel,
    required this.applicationId,
    required this.systemChannelId,
    required this.systemChannelFlags,
    required this.rulesChannelId,
    required this.maxPresences,
    required this.maxMembers,
    required this.vanityUrlCode,
    required this.description,
    required this.bannerHash,
    required this.premiumTier,
    required this.premiumSubscriptionCount,
    required this.preferredLocale,
    required this.publicUpdatesChannelId,
    required this.maxVideoChannelUsers,
    required this.maxStageChannelUsers,
    required this.approximateMemberCount,
    required this.approximatePresenceCount,
    required this.welcomeScreen,
    required this.nsfwLevel,
    required this.hasPremiumProgressBarEnabled,
  });
}

enum VerificationLevel {
  none._(0),
  low._(1),
  medium._(2),
  high._(3),
  veryHigh._(4);

  final int value;

  const VerificationLevel._(this.value);

  /// Parses a [VerificationLevel] from an [int].
  ///
  /// The [value] must be a valid verification level.
  factory VerificationLevel.parse(int value) => VerificationLevel.values.firstWhere(
        (level) => level.value == value,
        orElse: () => throw FormatException('Invalid verification level', value),
      );

  @override
  String toString() => 'VerificationLevel($value)';
}

enum MessageNotificationLevel {
  allMessages._(0),
  onlyMentions._(1);

  final int value;

  const MessageNotificationLevel._(this.value);

  /// Parses a [MessageNotificationLevel] from an [int].
  ///
  /// The [value] must be a valid message notification level.
  factory MessageNotificationLevel.parse(int value) => MessageNotificationLevel.values.firstWhere(
        (level) => level.value == value,
        orElse: () => throw FormatException('Invalid message notification level', value),
      );

  @override
  String toString() => 'MessageNotificationLevel($value)';
}

enum ExplicitContentFilterLevel {
  disabled._(0),
  membersWithoutRoles._(1),
  allMembers._(2);

  final int value;

  const ExplicitContentFilterLevel._(this.value);

  /// Parses an [ExplicitContentFilterLevel] from an [int].
  ///
  /// The [value] must be a valid explicit content filter level.
  factory ExplicitContentFilterLevel.parse(int value) => ExplicitContentFilterLevel.values.firstWhere(
        (level) => level.value == value,
        orElse: () => throw FormatException('Invalid explicit content filter level', value),
      );

  @override
  String toString() => 'ExplicitContentFilterLevel($value)';
}

// Artificial flags for guild features. The values are arbitrary, and are associated with the strings from the API in [GuildManager].
class GuildFeatures extends Flags<GuildFeatures> {
  static const animatedBanner = Flag<GuildFeatures>.fromOffset(0);
  static const animatedIcon = Flag<GuildFeatures>.fromOffset(1);
  static const applicationCommandPermissionsV2 = Flag<GuildFeatures>.fromOffset(2);
  static const autoModeration = Flag<GuildFeatures>.fromOffset(3);
  static const banner = Flag<GuildFeatures>.fromOffset(4);
  static const community = Flag<GuildFeatures>.fromOffset(5);
  static const creatorMonetizableProvisional = Flag<GuildFeatures>.fromOffset(6);
  static const creatorStorePage = Flag<GuildFeatures>.fromOffset(7);
  static const developerSupportServer = Flag<GuildFeatures>.fromOffset(8);
  static const discoverable = Flag<GuildFeatures>.fromOffset(9);
  static const featurable = Flag<GuildFeatures>.fromOffset(10);
  static const invitesDisabled = Flag<GuildFeatures>.fromOffset(11);
  static const inviteSplash = Flag<GuildFeatures>.fromOffset(12);
  static const memberVerificationGateEnabled = Flag<GuildFeatures>.fromOffset(13);
  static const moreStickers = Flag<GuildFeatures>.fromOffset(14);
  static const news = Flag<GuildFeatures>.fromOffset(15);
  static const partnered = Flag<GuildFeatures>.fromOffset(16);
  static const previewEnabled = Flag<GuildFeatures>.fromOffset(17);
  static const roleIcons = Flag<GuildFeatures>.fromOffset(18);
  static const roleSubscriptionsAvailableForPurchase = Flag<GuildFeatures>.fromOffset(19);
  static const roleSubscriptionsEnabled = Flag<GuildFeatures>.fromOffset(20);
  static const ticketedEventsEnabled = Flag<GuildFeatures>.fromOffset(21);
  static const vanityUrl = Flag<GuildFeatures>.fromOffset(22);
  static const verified = Flag<GuildFeatures>.fromOffset(23);
  static const vipRegions = Flag<GuildFeatures>.fromOffset(24);
  static const welcomeScreenEnabled = Flag<GuildFeatures>.fromOffset(25);

  const GuildFeatures(super.value);

  bool get hasAnimatedBanner => has(animatedBanner);
  bool get hasAnimatedIcon => has(animatedIcon);
  bool get hasApplicationCommandPermissionsV2 => has(applicationCommandPermissionsV2);
  bool get hasAutoModeration => has(autoModeration);
  bool get hasBanner => has(banner);
  bool get hasCommunity => has(community);
  bool get isCreatorMonetizableProvisional => has(creatorMonetizableProvisional);
  bool get hasCreatorStorePage => has(creatorStorePage);
  bool get hasDeveloperSupportServer => has(developerSupportServer);
  bool get isDiscoverable => has(discoverable);
  bool get isFeaturable => has(featurable);
  bool get hasInvitesDisabled => has(invitesDisabled);
  bool get hasInviteSplash => has(inviteSplash);
  bool get hasMemberVerificationGateEnabled => has(memberVerificationGateEnabled);
  bool get hasMoreStickers => has(moreStickers);
  bool get hasNews => has(news);
  bool get isPartnered => has(partnered);
  bool get hasPreviewEnabled => has(previewEnabled);
  bool get hasRoleIcons => has(roleIcons);
  bool get hasRoleSubscriptionsAvailableForPurchase => has(roleSubscriptionsAvailableForPurchase);
  bool get hasRoleSubscriptionsEnabled => has(roleSubscriptionsEnabled);
  bool get hasTicketedEventsEnabled => has(ticketedEventsEnabled);
  bool get hasVanityUrl => has(vanityUrl);
  bool get isVerified => has(verified);
  bool get hasVipRegions => has(vipRegions);
  bool get hasWelcomeScreenEnabled => has(welcomeScreenEnabled);
}

enum MfaLevel {
  none._(0),
  elevated._(1);

  final int value;

  const MfaLevel._(this.value);

  /// Parses an [MfaLevel] from an [int].
  ///
  /// The [value] must be a valid mfa level.
  factory MfaLevel.parse(int value) => MfaLevel.values.firstWhere(
        (level) => level.value == value,
        orElse: () => throw FormatException('Invalid mfa level', value),
      );

  @override
  String toString() => 'MfaLevel($value)';
}

class SystemChannelFlags extends Flags<SystemChannelFlags> {
  static const suppressJoinNotifications = Flag<SystemChannelFlags>.fromOffset(0);
  static const suppressPremiumSubscriptions = Flag<SystemChannelFlags>.fromOffset(1);
  static const suppressGuildReminderNotifications = Flag<SystemChannelFlags>.fromOffset(2);
  static const suppressJoinNotificationReplies = Flag<SystemChannelFlags>.fromOffset(3);
  static const suppressRoleSubscriptionPurchaseNotifications = Flag<SystemChannelFlags>.fromOffset(4);
  static const suppressRoleSubscriptionPurchaseNotificationReplies = Flag<SystemChannelFlags>.fromOffset(5);

  const SystemChannelFlags(super.value);

  bool get shouldSuppressJoinNotifications => has(suppressJoinNotifications);
  bool get shouldSuppressPremiumSubscriptions => has(suppressPremiumSubscriptions);
  bool get shouldSuppressGuildReminderNotifications => has(suppressGuildReminderNotifications);
  bool get shouldSuppressJoinNotificationReplies => has(suppressJoinNotificationReplies);
  bool get shouldSuppressRoleSubscriptionPurchaseNotifications => has(suppressRoleSubscriptionPurchaseNotifications);
  bool get shouldSuppressRoleSubscriptionPurchaseNotificationReplies => has(suppressRoleSubscriptionPurchaseNotificationReplies);
}

enum PremiumTier {
  none._(0),
  one._(1),
  two._(2),
  three._(3);

  final int value;

  const PremiumTier._(this.value);

  /// Parses a [PremiumTier] from an [int].
  ///
  /// The [value] must be a valid premium tier.
  factory PremiumTier.parse(int value) => PremiumTier.values.firstWhere(
        (level) => level.value == value,
        orElse: () => throw FormatException('Invalid premium tier', value),
      );

  @override
  String toString() => 'PremiumTier($value)';
}

enum NsfwLevel {
  unset._(0),
  explicit._(1),
  safe._(2),
  ageRestricted._(3);

  final int value;

  const NsfwLevel._(this.value);

  /// Parses an [NsfwLevel] from an [int].
  ///
  /// The [value] must be a valid nsfw level.
  factory NsfwLevel.parse(int value) => NsfwLevel.values.firstWhere(
        (level) => level.value == value,
        orElse: () => throw FormatException('Invalid nsfw level', value),
      );

  @override
  String toString() => 'NsfwLevel($value)';
}
