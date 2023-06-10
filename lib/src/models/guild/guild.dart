import 'dart:typed_data';

import 'package:nyxx/src/builders/channel/channel_position.dart';
import 'package:nyxx/src/builders/channel/guild_channel.dart';
import 'package:nyxx/src/builders/guild/welcome_screen.dart';
import 'package:nyxx/src/builders/guild/widget.dart';
import 'package:nyxx/src/builders/voice.dart';
import 'package:nyxx/src/http/managers/guild_manager.dart';
import 'package:nyxx/src/http/managers/member_manager.dart';
import 'package:nyxx/src/http/managers/role_manager.dart';
import 'package:nyxx/src/http/managers/scheduled_event_manager.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/thread_list.dart';
import 'package:nyxx/src/models/guild/ban.dart';
import 'package:nyxx/src/models/guild/guild_preview.dart';
import 'package:nyxx/src/models/guild/guild_widget.dart';
import 'package:nyxx/src/models/guild/integration.dart';
import 'package:nyxx/src/models/guild/onboarding.dart';
import 'package:nyxx/src/models/guild/welcome_screen.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/voice/voice_region.dart';
import 'package:nyxx/src/utils/flags.dart';

/// A partial [Guild].
class PartialGuild extends WritableSnowflakeEntity<Guild> {
  @override
  final GuildManager manager;

  /// A [MemberManager] for the members of this guild.
  MemberManager get members => MemberManager(manager.client.options.memberCacheConfig, manager.client, guildId: id);

  /// A [RoleManager] for the roles of this guild.
  RoleManager get roles => RoleManager(manager.client.options.roleCacheConfig, manager.client, guildId: id);

  ScheduledEventManager get scheduledEvents => ScheduledEventManager(manager.client.options.scheduledEventCacheConfig, manager.client, guildId: id);

  /// Create a new [PartialGuild].
  PartialGuild({required super.id, required this.manager});

  @override
  Future<Guild> fetch({bool? withCounts}) => manager.fetch(id, withCounts: withCounts);

  /// Fetch this guild's preview.
  Future<GuildPreview> fetchPreview() => manager.fetchGuildPreview(id);

  /// Fetch the channels in this guild.
  Future<List<GuildChannel>> fetchChannels() => manager.fetchGuildChannels(id);

  /// Create a channel in this guild.
  Future<T> createChannel<T extends GuildChannel>(GuildChannelBuilder<T> builder, {String? auditLogReason}) =>
      manager.createGuildChannel(id, builder, auditLogReason: auditLogReason);

  /// Update the channel positions in this guild.
  Future<void> updateChannelPositions(List<ChannelPositionBuilder> positions) => manager.updateChannelPositions(id, positions);

  /// List the active threads in this guild.
  Future<ThreadList> listActiveThreads() => manager.listActiveThreads(id);

  /// List the bans in this guild.
  Future<List<Ban>> listBans() => manager.listBans(id);

  /// Ban a member in this guild.
  Future<void> createBan(Snowflake userId, {Duration? deleteMessages, String? auditLogReason}) =>
      manager.createBan(id, userId, auditLogReason: auditLogReason, deleteMessages: deleteMessages);

  /// Unban a member in this guild.
  Future<void> deleteBan(Snowflake userId, {String? auditLogReason}) => manager.deleteBan(id, userId, auditLogReason: auditLogReason);

  /// Fetch the MFA level for this guild.
  Future<void> updateMfaLevel(MfaLevel level, {String? auditLogReason}) => manager.updateMfaLevel(id, level, auditLogReason: auditLogReason);

  /// Fetch the member prune count for the given [days] and [roleIds].
  Future<int> fetchPruneCount({int? days, List<Snowflake>? roleIds}) => manager.fetchPruneCount(id, days: days, roleIds: roleIds);

  /// Start a member prune with the given [days] and [roleIds].
  ///
  /// Returns the pruned count if [computeCount] is `true`
  Future<int?> startPrune({int? days, bool? computeCount, List<Snowflake>? roleIds, String? auditLogReason}) => manager.startGuildPrune(
        id,
        auditLogReason: auditLogReason,
        computeCount: computeCount,
        days: days,
        roleIds: roleIds,
      );

  /// List the voice regions available in the guild.
  Future<List<VoiceRegion>> listVoiceRegions() => manager.listVoiceRegions(id);

  /// List the integrations in this guild.
  Future<List<Integration>> listIntegrations() => manager.listIntegrations(id);

  /// Remove an integration from this guild.
  Future<void> deleteIntegration(Snowflake integrationId, {String? auditLogReason}) => manager.deleteIntegration(id, integrationId);

  /// Fetch this guild's widget settings.
  Future<WidgetSettings> fetchWidgetSettings() => manager.fetchWidgetSettings(id);

  /// Update this guild's widget settings.
  Future<WidgetSettings> updateWidgetSettings(WidgetSettingsUpdateBuilder builder, {String? auditLogReason}) =>
      manager.updateWidgetSettings(id, builder, auditLogReason: auditLogReason);

  /// Fetch this guild's widget information.
  Future<GuildWidget> fetchWidget() => manager.fetchGuildWidget(id);

  /// Fetch this guild's widget image.
  ///
  /// The returned data is in PNG format.
  Future<Uint8List> fetchWidgetImage({WidgetImageStyle? style}) => manager.fetchGuildWidgetImage(id, style: style);

  /// Fetch this guild's welcome screen.
  Future<WelcomeScreen> fetchWelcomeScreen() => manager.fetchWelcomeScreen(id);

  /// Update this guild's welcome screen.
  Future<WelcomeScreen> updateWelcomeScreen(WelcomeScreenUpdateBuilder builder, {String? auditLogReason}) =>
      manager.updateWelcomeScreen(id, builder, auditLogReason: auditLogReason);

  /// Fetch the onboarding information for this guild.
  Future<Onboarding> fetchOnboarding() => manager.fetchOnboarding(id);

  /// Update the current user's voice state in this guild.
  Future<void> updateCurrentUserVoiceState(CurrentUserVoiceStateUpdateBuilder builder) => manager.updateCurrentUserVoiceState(id, builder);

  /// Update a member's voice state in this guild.
  Future<void> updateVoiceState(Snowflake userId, VoiceStateUpdateBuilder builder) => manager.updateVoiceState(id, userId, builder);
}

/// {@template guild}
/// A collection of channels & users.
///
/// Guilds are often referred to as servers.
/// {@endtemplate}
class Guild extends PartialGuild {
  /// This guild's name.
  final String name;

  /// The hash of this guild's icon.
  final String? iconHash;

  /// The hash of this guild's splash image.
  final String? splashHash;

  /// The hash of this guild's discovery splash image.
  final String? discoverySplashHash;

  /// Whether this guild is owned by the current user.
  ///
  /// {@template get_current_user_guilds_only}
  /// This field is only present when fetching the current user's guilds.
  /// {@endtemplate}
  final bool? isOwnedByCurrentUser;

  /// The ID of this guild's owner.
  final Snowflake ownerId;

  /// The current user's permissions.
  ///
  /// {@macro get_current_user_guilds_only}
  final Permissions? currentUserPermissions;

  /// The ID of this guild's AFK channel.
  final Snowflake? afkChannelId;

  /// The time after which members are moved into the AFK channel.
  final Duration afkTimeout;

  /// Whether the widget is enabled in this guild.
  final bool isWidgetEnabled;

  /// The channel ID the widget's invite will send users to.
  final Snowflake? widgetChannelId;

  /// This guild's verification level.
  final VerificationLevel verificationLevel;

  /// The default message notification level.
  final MessageNotificationLevel defaultMessageNotificationLevel;

  /// The explicit content filter level for this guild.
  final ExplicitContentFilterLevel explicitContentFilterLevel;

  /// A list of roles in this guild.
  // Renamed to avoid conflict with the roles manager.
  final List<Role> roleList;

  // TODO
  //final List<Emoji> emojis;

  /// A set of features enabled in this guild.
  final GuildFeatures features;

  /// This guild's MFA level.
  final MfaLevel mfaLevel;

  /// The ID of the application that created this guild.
  final Snowflake? applicationId;

  /// The ID of the channel system messages are sent to.
  final Snowflake? systemChannelId;

  /// The configuration for this guild's system channel.
  final SystemChannelFlags systemChannelFlags;

  /// The ID of the rules channel in a community guild.
  final Snowflake? rulesChannelId;

  /// The maximum number of presences in this guild.
  final int? maxPresences;

  /// The maximum number of members in this guild.
  final int? maxMembers;

  /// This guild's vanity invite URL code.
  final String? vanityUrlCode;

  /// This guild's description.
  final String? description;

  /// The hash of this guild's banner.
  final String? bannerHash;

  /// The current premium tier of this guild.
  final PremiumTier premiumTier;

  /// The number of members who have boosted this guild.
  final int? premiumSubscriptionCount;

  /// This guild's preferred locale.
  final Locale preferredLocale;

  /// The ID of the public updates channel in a community guild.
  final Snowflake? publicUpdatesChannelId;

  /// The maximum number of users in a video channel.
  final int? maxVideoChannelUsers;

  /// The maximum number of users in a stage video channel.
  final int? maxStageChannelUsers;

  /// An approximate number of members in this guild.
  ///
  /// {@template fetch_with_counts_only}
  /// This is only returned when fetching this guild with `withCounts` set to `true`.
  /// {@endtemplate}
  final int? approximateMemberCount;

  /// An approximate number of presences in this guild.
  ///
  /// {@macro fetch_with_counts_only}
  final int? approximatePresenceCount;

  /// This guild's welcome screen.
  final WelcomeScreen? welcomeScreen;

  /// This guild's NSFW level.
  final NsfwLevel nsfwLevel;

  // TODO
  //final List<Sticker> stickers;

  /// Whether this guild has the premium progress bar enabled.
  final bool hasPremiumProgressBarEnabled;

  /// {@macro guild}
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
    required this.roleList,
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

/// The verification level for a guild.
enum VerificationLevel {
  none._(0),
  low._(1),
  medium._(2),
  high._(3),
  veryHigh._(4);

  /// The value of this verification level.
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

/// The level at which message notifications are sent in a guild.
enum MessageNotificationLevel {
  allMessages._(0),
  onlyMentions._(1);

  /// The value of this message notification level.
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

/// The level of explicit content filtering in a guild.
enum ExplicitContentFilterLevel {
  disabled._(0),
  membersWithoutRoles._(1),
  allMembers._(2);

  /// The value of this explicit content filter level.
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

/// Features that can be enabled in certain guilds.
// Artificial flags for guild features. The values are arbitrary, and are associated with the strings from the API in [GuildManager].
class GuildFeatures extends Flags<GuildFeatures> {
  /// The guild has an animated banner.
  static const animatedBanner = Flag<GuildFeatures>.fromOffset(0);

  /// The guild has an animated icon.
  static const animatedIcon = Flag<GuildFeatures>.fromOffset(1);

  /// The guild has the Application Command Permissions V2.
  static const applicationCommandPermissionsV2 = Flag<GuildFeatures>.fromOffset(2);

  /// The guild has auto moderation.
  static const autoModeration = Flag<GuildFeatures>.fromOffset(3);

  /// The guild has a banner.
  static const banner = Flag<GuildFeatures>.fromOffset(4);

  /// The guild is a community guild.
  static const community = Flag<GuildFeatures>.fromOffset(5);

  /// The guild has enabled monetization.
  static const creatorMonetizableProvisional = Flag<GuildFeatures>.fromOffset(6);

  /// The guild has enabled the role subscription promo page.
  static const creatorStorePage = Flag<GuildFeatures>.fromOffset(7);

  /// The guild has been set as a support server on the App Directory.
  static const developerSupportServer = Flag<GuildFeatures>.fromOffset(8);

  /// The guild is able to be discovered in the directory.
  static const discoverable = Flag<GuildFeatures>.fromOffset(9);

  /// The guild is able to be featured in the directory.
  static const featurable = Flag<GuildFeatures>.fromOffset(10);

  /// The guild has paused invites, preventing new users from joining.
  static const invitesDisabled = Flag<GuildFeatures>.fromOffset(11);

  /// The guild has access to set an invite splash background.
  static const inviteSplash = Flag<GuildFeatures>.fromOffset(12);

  /// The guild has enabled Membership Screening.
  static const memberVerificationGateEnabled = Flag<GuildFeatures>.fromOffset(13);

  /// The guild has increased custom sticker slots.
  static const moreStickers = Flag<GuildFeatures>.fromOffset(14);

  /// The guild has access to create announcement channels.
  static const news = Flag<GuildFeatures>.fromOffset(15);

  /// The guild is partnered.
  static const partnered = Flag<GuildFeatures>.fromOffset(16);

  /// The guild can be previewed before joining via Membership Screening or the directory.
  static const previewEnabled = Flag<GuildFeatures>.fromOffset(17);

  /// The guild has disabled alerts for join raids in the configured safety alerts channel.
  static const raidAlertsDisabled = Flag<GuildFeatures>.fromOffset(18);

  /// The guild is able to set role icons.
  static const roleIcons = Flag<GuildFeatures>.fromOffset(19);

  /// The guild has role subscriptions that can be purchased.
  static const roleSubscriptionsAvailableForPurchase = Flag<GuildFeatures>.fromOffset(20);

  /// The guild has enabled role subscriptions.
  static const roleSubscriptionsEnabled = Flag<GuildFeatures>.fromOffset(21);

  /// The guild has enabled ticketed events.
  static const ticketedEventsEnabled = Flag<GuildFeatures>.fromOffset(22);

  /// The guild has access to set a vanity URL.
  static const vanityUrl = Flag<GuildFeatures>.fromOffset(23);

  /// The guild is verified.
  static const verified = Flag<GuildFeatures>.fromOffset(24);

  /// The guild has access to set 384kbps bitrate in voice (previously VIP voice servers).
  static const vipRegions = Flag<GuildFeatures>.fromOffset(25);

  /// The guild has enabled the welcome screen.
  static const welcomeScreenEnabled = Flag<GuildFeatures>.fromOffset(26);

  /// Create a new [GuildFeatures].
  const GuildFeatures(super.value);

  /// Whether this guild has the [animatedBanner] feature.
  bool get hasAnimatedBanner => has(animatedBanner);

  /// Whether this guild has the [animatedIcon] feature.
  bool get hasAnimatedIcon => has(animatedIcon);

  /// Whether this guild has the [applicationCommandPermissionsV2] feature.
  bool get hasApplicationCommandPermissionsV2 => has(applicationCommandPermissionsV2);

  /// Whether this guild has the [autoModeration] feature.
  bool get hasAutoModeration => has(autoModeration);

  /// Whether this guild has the [banner] feature.
  bool get hasBanner => has(banner);

  /// Whether this guild has the [community] feature.
  bool get hasCommunity => has(community);

  /// Whether this guild has the [creatorMonetizableProvisional] feature.
  bool get isCreatorMonetizableProvisional => has(creatorMonetizableProvisional);

  /// Whether this guild has the [creatorStorePage] feature.
  bool get hasCreatorStorePage => has(creatorStorePage);

  /// Whether this guild has the [developerSupportServer] feature.
  bool get hasDeveloperSupportServer => has(developerSupportServer);

  /// Whether this guild has the [discoverable] feature.
  bool get isDiscoverable => has(discoverable);

  /// Whether this guild has the [featurable] feature.
  bool get isFeaturable => has(featurable);

  /// Whether this guild has the [invitesDisabled] feature.
  bool get hasInvitesDisabled => has(invitesDisabled);

  /// Whether this guild has the [inviteSplash] feature.
  bool get hasInviteSplash => has(inviteSplash);

  /// Whether this guild has the [memberVerificationGateEnabled] feature.
  bool get hasMemberVerificationGateEnabled => has(memberVerificationGateEnabled);

  /// Whether this guild has the [moreStickers] feature.
  bool get hasMoreStickers => has(moreStickers);

  /// Whether this guild has the [news] feature.
  bool get hasNews => has(news);

  /// Whether this guild has the [partnered] feature.
  bool get isPartnered => has(partnered);

  /// Whether this guild has the [previewEnabled] feature.
  bool get hasPreviewEnabled => has(previewEnabled);

  /// Whether this guild has the [roleIcons] feature.
  bool get hasRoleIcons => has(roleIcons);

  /// Whether this guild has the [roleSubscriptionsAvailableForPurchase] feature.
  bool get hasRoleSubscriptionsAvailableForPurchase => has(roleSubscriptionsAvailableForPurchase);

  /// Whether this guild has the [roleSubscriptionsEnabled] feature.
  bool get hasRoleSubscriptionsEnabled => has(roleSubscriptionsEnabled);

  /// Whether this guild has the [ticketedEventsEnabled] feature.
  bool get hasTicketedEventsEnabled => has(ticketedEventsEnabled);

  /// Whether this guild has the [vanityUrl] feature.
  bool get hasVanityUrl => has(vanityUrl);

  /// Whether this guild has the [verified] feature.
  bool get isVerified => has(verified);

  /// Whether this guild has the [vipRegions] feature.
  bool get hasVipRegions => has(vipRegions);

  /// Whether this guild has the [welcomeScreenEnabled] feature.
  bool get hasWelcomeScreenEnabled => has(welcomeScreenEnabled);

  /// Whether this guild has the [raidAlertsDisabled] feature.
  bool get hasRaidAlertsDisabled => has(raidAlertsDisabled);
}

/// The MFA level required for moderators of a guild.
enum MfaLevel {
  none._(0),
  elevated._(1);

  /// The value of this MFA level.
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

/// The configuration of a guild's system channel.
class SystemChannelFlags extends Flags<SystemChannelFlags> {
  /// Suppress member join notifications.
  static const suppressJoinNotifications = Flag<SystemChannelFlags>.fromOffset(0);

  /// Suppress server boost notifications.
  static const suppressPremiumSubscriptions = Flag<SystemChannelFlags>.fromOffset(1);

  /// Suppress server setup tips.
  static const suppressGuildReminderNotifications = Flag<SystemChannelFlags>.fromOffset(2);

  /// Hide member join sticker reply buttons.
  static const suppressJoinNotificationReplies = Flag<SystemChannelFlags>.fromOffset(3);

  /// Suppress role subscription purchase and renewal notifications.
  static const suppressRoleSubscriptionPurchaseNotifications = Flag<SystemChannelFlags>.fromOffset(4);

  /// Hide role subscription sticker reply buttons.
  static const suppressRoleSubscriptionPurchaseNotificationReplies = Flag<SystemChannelFlags>.fromOffset(5);

  /// Create a new [SystemChannelFlags].
  const SystemChannelFlags(super.value);

  /// Whether this configuration has the [suppressJoinNotifications] flag.
  bool get shouldSuppressJoinNotifications => has(suppressJoinNotifications);

  /// Whether this configuration has the [suppressPremiumSubscriptions] flag.
  bool get shouldSuppressPremiumSubscriptions => has(suppressPremiumSubscriptions);

  /// Whether this configuration has the [suppressGuildReminderNotifications] flag.
  bool get shouldSuppressGuildReminderNotifications => has(suppressGuildReminderNotifications);

  /// Whether this configuration has the [suppressJoinNotificationReplies] flag.
  bool get shouldSuppressJoinNotificationReplies => has(suppressJoinNotificationReplies);

  /// Whether this configuration has the [suppressRoleSubscriptionPurchaseNotifications] flag.
  bool get shouldSuppressRoleSubscriptionPurchaseNotifications => has(suppressRoleSubscriptionPurchaseNotifications);

  /// Whether this configuration has the [suppressRoleSubscriptionPurchaseNotificationReplies] flag.
  bool get shouldSuppressRoleSubscriptionPurchaseNotificationReplies => has(suppressRoleSubscriptionPurchaseNotificationReplies);
}

/// The premium tier of a guild.
enum PremiumTier {
  none._(0),
  one._(1),
  two._(2),
  three._(3);

  /// The value of this tier.
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

/// The NSFW level of a guild.
enum NsfwLevel {
  unset._(0),
  explicit._(1),
  safe._(2),
  ageRestricted._(3);

  /// The value of this NSFW level.
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
