import 'dart:convert';
import 'dart:typed_data';

import 'package:nyxx/src/builders/channel/channel_position.dart';
import 'package:nyxx/src/builders/channel/guild_channel.dart';
import 'package:nyxx/src/builders/guild/guild.dart';
import 'package:nyxx/src/builders/guild/template.dart';
import 'package:nyxx/src/builders/guild/welcome_screen.dart';
import 'package:nyxx/src/builders/guild/widget.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/builders/voice.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/thread_list.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/guild/ban.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/guild_preview.dart';
import 'package:nyxx/src/models/guild/guild_widget.dart';
import 'package:nyxx/src/models/guild/onboarding.dart';
import 'package:nyxx/src/models/guild/template.dart';
import 'package:nyxx/src/models/guild/welcome_screen.dart';
import 'package:nyxx/src/models/invite/invite.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/models/voice/voice_region.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';
import 'package:nyxx/src/utils/flags.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

/// A manager for [Guild]s.
class GuildManager extends Manager<Guild> {
  /// Create a new [GuildManager].
  GuildManager(super.config, super.client) : super(identifier: 'guilds');

  @override
  PartialGuild operator [](Snowflake id) => PartialGuild(id: id, manager: this);

  @override
  Guild parse(Map<String, Object?> raw) {
    final id = Snowflake.parse(raw['id']!);

    return Guild(
      id: id,
      manager: this,
      name: raw['name'] as String,
      iconHash: (raw['icon'] ?? raw['icon_hash']) as String?,
      splashHash: raw['splash'] as String?,
      discoverySplashHash: raw['discovery_splash'] as String?,
      isOwnedByCurrentUser: raw['owner'] as bool?,
      ownerId: Snowflake.parse(raw['owner_id']!),
      currentUserPermissions: maybeParse(raw['permissions'], (String permissions) => Permissions(int.parse(permissions))),
      afkChannelId: maybeParse(raw['afk_channel_id'], Snowflake.parse),
      afkTimeout: Duration(seconds: raw['afk_timeout'] as int),
      isWidgetEnabled: raw['widget_enabled'] as bool? ?? false,
      widgetChannelId: maybeParse(raw['widget_channel_id'], Snowflake.parse),
      verificationLevel: VerificationLevel.parse(raw['verification_level'] as int),
      defaultMessageNotificationLevel: MessageNotificationLevel.parse(raw['default_message_notifications'] as int),
      explicitContentFilterLevel: ExplicitContentFilterLevel.parse(raw['explicit_content_filter'] as int),
      roleList: parseMany(raw['roles'] as List, this[id].roles.parse),
      features: parseGuildFeatures(raw['features'] as List),
      mfaLevel: MfaLevel.parse(raw['mfa_level'] as int),
      applicationId: maybeParse(raw['application_id'], Snowflake.parse),
      systemChannelId: maybeParse(raw['system_channel_id'], Snowflake.parse),
      systemChannelFlags: SystemChannelFlags(raw['system_channel_flags'] as int),
      rulesChannelId: maybeParse(raw['rules_channel_id'], Snowflake.parse),
      maxPresences: raw['max_presences'] as int?,
      maxMembers: raw['max_members'] as int?,
      vanityUrlCode: raw['vanity_url_code'] as String?,
      description: raw['description'] as String?,
      bannerHash: raw['banner'] as String?,
      premiumTier: PremiumTier.parse(raw['premium_tier'] as int),
      premiumSubscriptionCount: raw['premium_subscription_count'] as int?,
      preferredLocale: Locale.parse(raw['preferred_locale'] as String),
      publicUpdatesChannelId: maybeParse(raw['public_updates_channel_id'], Snowflake.parse),
      maxVideoChannelUsers: raw['max_video_channel_users'] as int?,
      maxStageChannelUsers: raw['max_stage_video_channel_users'] as int?,
      approximateMemberCount: raw['approximate_member_count'] as int?,
      approximatePresenceCount: raw['approximate_presence_count'] as int?,
      welcomeScreen: maybeParse(raw['welcome_screen'], parseWelcomeScreen),
      nsfwLevel: NsfwLevel.parse(raw['nsfw_level'] as int),
      hasPremiumProgressBarEnabled: raw['premium_progress_bar_enabled'] as bool,
      emojiList: parseMany(raw['emojis'] as List, this[id].emojis.parse),
      stickerList: parseMany(raw['stickers'] as List? ?? [], this[id].stickers.parse),
      safetyAlertsChannelId: maybeParse(raw['safety_alerts_channel_id'], Snowflake.parse),
    );
  }

  /// Parse [UserGuild] from [raw].
  UserGuild parseUserGuild(Map<String, Object?> raw) {
    final id = Snowflake.parse(raw['id']!);

    return UserGuild(
      id: id,
      manager: this,
      name: raw['name'] as String,
      iconHash: raw['icon'] as String?,
      isOwnedByCurrentUser: raw['owner'] as bool,
      currentUserPermissions: Permissions(int.parse(raw['permissions'] as String)),
      features: parseGuildFeatures(raw['features'] as List),
      approximateMemberCount: raw['approximate_member_count'] as int?,
      approximatePresenceCount: raw['approximate_presence_count'] as int?,
    );
  }

  static final Map<String, Flag<GuildFeatures>> _nameToGuildFeature = {
    'ANIMATED_BANNER': GuildFeatures.animatedBanner,
    'ANIMATED_ICON': GuildFeatures.animatedIcon,
    'APPLICATION_COMMAND_PERMISSIONS_V2': GuildFeatures.applicationCommandPermissionsV2,
    'AUTO_MODERATION': GuildFeatures.autoModeration,
    'BANNER': GuildFeatures.banner,
    'COMMUNITY': GuildFeatures.community,
    'CREATOR_MONETIZABLE_PROVISIONAL': GuildFeatures.creatorMonetizableProvisional,
    'CREATOR_STORE_PAGE': GuildFeatures.creatorStorePage,
    'DEVELOPER_SUPPORT_SERVER': GuildFeatures.developerSupportServer,
    'DISCOVERABLE': GuildFeatures.discoverable,
    'FEATURABLE': GuildFeatures.featurable,
    'INVITES_DISABLED': GuildFeatures.invitesDisabled,
    'INVITE_SPLASH': GuildFeatures.inviteSplash,
    'MEMBER_VERIFICATION_GATE_ENABLED': GuildFeatures.memberVerificationGateEnabled,
    'MORE_STICKERS': GuildFeatures.moreStickers,
    'NEWS': GuildFeatures.news,
    'PARTNERED': GuildFeatures.partnered,
    'PREVIEW_ENABLED': GuildFeatures.previewEnabled,
    'RAID_ALERTS_DISABLED': GuildFeatures.raidAlertsDisabled,
    'ROLE_ICONS': GuildFeatures.roleIcons,
    'ROLE_SUBSCRIPTIONS_AVAILABLE_FOR_PURCHASE': GuildFeatures.roleSubscriptionsAvailableForPurchase,
    'ROLE_SUBSCRIPTIONS_ENABLED': GuildFeatures.roleSubscriptionsEnabled,
    'TICKETED_EVENTS_ENABLED': GuildFeatures.ticketedEventsEnabled,
    'VANITY_URL': GuildFeatures.vanityUrl,
    'VERIFIED': GuildFeatures.verified,
    'VIP_REGIONS': GuildFeatures.vipRegions,
    'WELCOME_SCREEN_ENABLED': GuildFeatures.welcomeScreenEnabled,
  };

  static final Map<Flag<GuildFeatures>, String> _guildFeatureToName = {
    for (final entry in _nameToGuildFeature.entries) entry.value: entry.key,
  };

  /// Parse an [GuildFeatures] from [raw].
  GuildFeatures parseGuildFeatures(List<Object?> raw) {
    final featureFlags = parseMany(raw, parseGuildFeature);

    return GuildFeatures(featureFlags.fold(0, (value, element) => value | element.value));
  }

  /// Parse a [Flag]<GuildFeature> from [raw].
  Flag<GuildFeatures> parseGuildFeature(String raw) {
    return _nameToGuildFeature[raw] ?? Flag<GuildFeatures>(0);
  }

  /// Serialize [source] to a [List]<String>.
  static List<String> serializeGuildFeatures(Flags<GuildFeatures> source) {
    return source.map(serializeGuildFeature).toList();
  }

  /// Serialize [source] to a [String].
  static String serializeGuildFeature(Flag<GuildFeatures> source) {
    return _guildFeatureToName[source]!;
  }

  /// Parse a [WelcomeScreen] from [raw].
  WelcomeScreen parseWelcomeScreen(Map<String, Object?> raw) {
    return WelcomeScreen(
      description: raw['description'] as String?,
      channels: parseMany(raw['welcome_channels'] as List, parseWelcomeScreenChannel),
    );
  }

  /// Parse a [WelcomeScreenChannel] from [raw].
  WelcomeScreenChannel parseWelcomeScreenChannel(Map<String, Object?> raw) {
    return WelcomeScreenChannel(
      manager: this,
      channelId: Snowflake.parse(raw['channel_id']!),
      description: raw['description'] as String,
      emojiId: maybeParse(raw['emoji_id'], Snowflake.parse),
      emojiName: raw['emoji_name'] as String?,
    );
  }

  /// Parse a [GuildPreview] from [raw].
  GuildPreview parseGuildPreview(Map<String, Object?> raw) {
    final id = Snowflake.parse(raw['id']!);

    return GuildPreview(
      id: id,
      manager: this,
      name: raw['name'] as String,
      iconHash: raw['icon'] as String?,
      splashHash: raw['splash'] as String?,
      discoverySplashHash: raw['discovery_splash'] as String?,
      emojiList: parseMany(raw['emojis'] as List, this[id].emojis.parse),
      features: parseGuildFeatures(raw['features'] as List),
      description: raw['description'] as String?,
      approximateMemberCount: raw['approximate_member_count'] as int,
      approximatePresenceCount: raw['approximate_presence_count'] as int,
      stickerList: parseMany(raw['stickers'] as List? ?? [], this[id].stickers.parse),
    );
  }

  /// Parse a [Ban] from [raw].
  Ban parseBan(Map<String, Object?> raw) {
    return Ban(
      reason: raw['reason'] as String,
      user: client.users.parse(raw['user'] as Map<String, Object?>),
    );
  }

  /// Parse a [WidgetSettings] from [raw].
  WidgetSettings parseWidgetSettings(Map<String, Object?> raw) {
    return WidgetSettings(
      manager: this,
      isEnabled: raw['enabled'] as bool,
      channelId: maybeParse(raw['channel_id'], Snowflake.parse),
    );
  }

  /// Parse a [GuildWidget] from [raw].
  GuildWidget parseGuildWidget(Map<String, Object?> raw) {
    return GuildWidget(
      manager: this,
      guildId: Snowflake.parse(raw['id']!),
      name: raw['name'] as String,
      invite: raw['instant_invite'] as String?,
      channels: parseMany(
        raw['channels'] as List,
        (Map<String, Object?> raw) => PartialChannel(id: Snowflake.parse(raw['id']!), manager: client.channels),
      ),
      users: parseMany(
        raw['members'] as List,
        (Map<String, Object?> raw) => PartialUser(id: Snowflake.parse(raw['id']!), manager: client.users),
      ),
      presenceCount: raw['presence_count'] as int,
    );
  }

  /// Parse an [Onboarding] from [raw].
  Onboarding parseOnboarding(Map<String, Object?> raw) {
    final guildId = Snowflake.parse(raw['guild_id']!);

    return Onboarding(
      manager: this,
      guildId: guildId,
      prompts: parseMany(raw['prompts'] as List, (Map<String, Object?> raw) => parseOnboardingPrompt(raw, guildId: guildId)),
      defaultChannelIds: parseMany(raw['default_channel_ids'] as List, Snowflake.parse),
      isEnabled: raw['enabled'] as bool,
    );
  }

  /// Parse an [OnboardingPrompt] from [raw].
  OnboardingPrompt parseOnboardingPrompt(Map<String, Object?> raw, {Snowflake? guildId}) {
    return OnboardingPrompt(
      id: Snowflake.parse(raw['id']!),
      type: OnboardingPromptType.parse(raw['type'] as int),
      options: parseMany(raw['options'] as List, (Map<String, Object?> raw) => parseOnboardingPromptOption(raw, guildId: guildId)),
      title: raw['title'] as String,
      isSingleSelect: raw['single_select'] as bool,
      isRequired: raw['required'] as bool,
      isInOnboarding: raw['in_onboarding'] as bool,
    );
  }

  /// Parse an [OnboardingPromptOption] from [raw].
  OnboardingPromptOption parseOnboardingPromptOption(Map<String, Object?> raw, {Snowflake? guildId}) {
    Emoji? emoji;
    final rawEmoji = raw['emoji'] as Map<String, Object?>;

    // Discord passes an "empty" emoji object when unset instead of null
    if (rawEmoji['id'] != null || rawEmoji['name'] != null) {
      emoji = client.guilds[guildId ?? Snowflake.zero].emojis.parse(raw['emoji'] as Map<String, Object?>);
    }

    return OnboardingPromptOption(
      manager: this,
      id: Snowflake.parse(raw['id']!),
      channelIds: parseMany(raw['channel_ids'] as List, Snowflake.parse),
      roleIds: parseMany(raw['role_ids'] as List, Snowflake.parse),
      emoji: emoji,
      title: raw['title'] as String,
      description: raw['description'] as String?,
    );
  }

  /// Parse a [GuildTemplate] from [raw].
  GuildTemplate parseGuildTemplate(Map<String, Object?> raw) {
    final sourceGuildId = Snowflake.parse(raw['source_guild_id']!);

    return GuildTemplate(
      code: raw['code'] as String,
      manager: this,
      name: raw['name'] as String,
      description: raw['description'] as String?,
      usageCount: raw['usage_count'] as int,
      creatorId: Snowflake.parse(raw['creator_id']!),
      creator: client.users.parse(raw['creator'] as Map<String, Object?>),
      createdAt: DateTime.parse(raw['created_at'] as String),
      updatedAt: DateTime.parse(raw['updated_at'] as String),
      sourceGuildId: sourceGuildId,
      // Add synthetic fields so we can parse the (mostly complete) partial guild as a full guild
      serializedSourceGuild: parse({
        'id': sourceGuildId.toString(),
        'owner_id': Snowflake.zero.toString(),
        'features': [],
        'mfa_level': MfaLevel.none.value,
        'premium_tier': PremiumTier.none.value,
        'nsfw_level': NsfwLevel.unset.value,
        'premium_progress_bar_enabled': false,
        'emojis': [],
        ...(raw['serialized_source_guild'] as Map<String, Object?>),
        'roles': [
          for (final role in ((raw['serialized_source_guild'] as Map<String, Object?>)['roles'] as List).cast<Map<String, Object?>>())
            {
              'position': 0,
              'flags': 0,
              ...role,
            },
        ],
      }),
      isDirty: raw['is_dirty'] as bool?,
    );
  }

  @override
  Future<Guild> fetch(Snowflake id, {bool? withCounts}) async {
    final route = HttpRoute()..guilds(id: id.toString());
    final request = BasicRequest(route, queryParameters: {if (withCounts != null) 'with_counts': withCounts.toString()});

    final response = await client.httpHandler.executeSafe(request);
    final guild = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(guild);
    return guild;
  }

  @override
  Future<Guild> create(GuildBuilder builder) async {
    final route = HttpRoute()..guilds();
    final request = BasicRequest(route, method: 'POST', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final guild = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(guild);
    return guild;
  }

  @override
  Future<Guild> update(Snowflake id, GuildUpdateBuilder builder, {String? auditLogReason}) async {
    final route = HttpRoute()..guilds(id: id.toString());
    final request = BasicRequest(route, method: 'PATCH', auditLogReason: auditLogReason, body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final guild = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(guild);
    return guild;
  }

  @override
  Future<void> delete(Snowflake id) async {
    final route = HttpRoute()..guilds(id: id.toString());
    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
    cache.remove(id);
  }

  /// Fetch a guild's preview.
  Future<GuildPreview> fetchGuildPreview(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..preview();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final preview = parseGuildPreview(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(preview);
    return preview;
  }

  /// Fetch the channels in a guild.
  Future<List<GuildChannel>> fetchGuildChannels(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..channels();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final channels = parseMany(response.jsonBody as List, client.channels.parse).cast<GuildChannel>();

    channels.forEach(client.updateCacheWith);
    return channels;
  }

  /// Create a channel in a guild.
  Future<T> createGuildChannel<T extends GuildChannel>(Snowflake id, GuildChannelBuilder<T> builder, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..channels();
    final request = BasicRequest(route, method: 'POST', auditLogReason: auditLogReason, body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final channel = client.channels.parse(response.jsonBody as Map<String, Object?>) as T;

    client.updateCacheWith(channel);
    return channel;
  }

  /// Update the positions of channels in a guild.
  Future<void> updateChannelPositions(Snowflake id, List<ChannelPositionBuilder> positions) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..channels();
    final request = BasicRequest(route, method: 'PATCH', body: jsonEncode(positions.map((e) => e.build()).toList()));

    await client.httpHandler.executeSafe(request);
  }

  /// List the active threads in a guild.
  Future<ThreadList> listActiveThreads(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..threads()
      ..active();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final list = client.channels.parseThreadList(response.jsonBody as Map<String, Object?>, guildId: id);

    client.updateCacheWith(list);
    return list;
  }

  /// List the bans in a guild.
  Future<List<Ban>> listBans(Snowflake id, {int? limit, Snowflake? after, Snowflake? before}) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..bans();
    final request = BasicRequest(route, queryParameters: {
      if (limit != null) 'limit': limit.toString(),
      if (after != null) 'after': after.toString(),
      if (before != null) 'before': before.toString(),
    });

    final response = await client.httpHandler.executeSafe(request);
    final bans = parseMany(response.jsonBody as List, parseBan);

    bans.forEach(client.updateCacheWith);
    return bans;
  }

  /// Fetch a ban in a guild.
  Future<Ban> fetchBan(Snowflake id, Snowflake userId) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..bans(id: userId.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final ban = parseBan(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(ban);
    return ban;
  }

  /// Create a ban in a guild.
  Future<void> createBan(Snowflake id, Snowflake userId, {Duration? deleteMessages, String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..bans(id: userId.toString());
    final request = BasicRequest(
      route,
      method: 'PUT',
      auditLogReason: auditLogReason,
      body: jsonEncode({
        if (deleteMessages != null) 'delete_message_seconds': deleteMessages.inSeconds,
      }),
    );

    await client.httpHandler.executeSafe(request);
  }

  /// Delete a ban in a guild.
  Future<void> deleteBan(Snowflake id, Snowflake userId, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..bans(id: userId.toString());
    final request = BasicRequest(route, method: 'DELETE', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);
  }

  /// Update a guild's MFA level.
  Future<MfaLevel> updateMfaLevel(Snowflake id, MfaLevel level, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..mfa();
    final request = BasicRequest(
      route,
      method: 'POST',
      auditLogReason: auditLogReason,
      body: jsonEncode({'level': level.value}),
    );

    final response = await client.httpHandler.executeSafe(request);
    return MfaLevel.parse((response.jsonBody as Map<String, Object?>)['level'] as int);
  }

  /// Fetch the prune count in a guild.
  Future<int> fetchPruneCount(Snowflake id, {int? days, List<Snowflake>? roleIds}) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..prune();
    final request = BasicRequest(route, queryParameters: {
      if (days != null) 'days': days.toString(),
      if (roleIds != null) 'include_roles': roleIds.map((e) => e.toString()).join(','),
    });

    final response = await client.httpHandler.executeSafe(request);
    return (response.jsonBody as Map<String, Object?>)['pruned'] as int;
  }

  /// Start a prune in a guild.
  Future<int?> startGuildPrune(
    Snowflake id, {
    int? days,
    bool? computeCount,
    List<Snowflake>? roleIds,
    String? auditLogReason,
  }) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..prune();
    final request = BasicRequest(
      route,
      method: 'POST',
      auditLogReason: auditLogReason,
      body: jsonEncode({
        if (days != null) 'days': days,
        if (computeCount != null) 'compute_prune_count': computeCount,
        if (roleIds != null) 'include_roles': roleIds.map((e) => e.toString()).toList(),
      }),
    );

    final response = await client.httpHandler.executeSafe(request);
    return (response.jsonBody as Map<String, Object?>)['pruned'] as int?;
  }

  /// List the voice regions in a guild.
  Future<List<VoiceRegion>> listVoiceRegions(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..regions();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseMany(response.jsonBody as List, client.voice.parseVoiceRegion);
  }

  /// List the invites in a guild.
  Future<List<Invite>> listInvites(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..invites();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final invites = parseMany(response.jsonBody as List, client.invites.parse);

    invites.forEach(client.updateCacheWith);
    return invites;
  }

  /// Fetch a guild's widget settings.
  Future<WidgetSettings> fetchWidgetSettings(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..widget();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseWidgetSettings(response.jsonBody as Map<String, Object?>);
  }

  /// Update a guild's widget settings.
  Future<WidgetSettings> updateWidgetSettings(Snowflake id, WidgetSettingsUpdateBuilder builder, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..widget();
    final request = BasicRequest(route, method: 'PATCH', auditLogReason: auditLogReason, body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    return parseWidgetSettings(response.jsonBody as Map<String, Object?>);
  }

  /// Fetch a guild's widget.
  Future<GuildWidget> fetchGuildWidget(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..widgetJson();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseGuildWidget(response.jsonBody as Map<String, Object?>);
  }

  /// Fetch a guild's vanity invite code.
  Future<String?> fetchVanityCode(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..vanityUrl();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return (response.jsonBody as Map<String, Object?>)['code'] as String?;
  }

  /// Fetch the image for a guild's widget.
  Future<Uint8List> fetchGuildWidgetImage(Snowflake id, {WidgetImageStyle? style}) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..widgetPng();
    final request = BasicRequest(
      route,
      authenticated: false,
      queryParameters: {if (style != null) 'style': style.value},
    );

    final response = await client.httpHandler.executeSafe(request);
    return response.body;
  }

  /// Fetch a guild's welcome screen.
  Future<WelcomeScreen> fetchWelcomeScreen(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..welcomeScreen();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseWelcomeScreen(response.jsonBody as Map<String, Object?>);
  }

  /// Update a guild's welcome screen.
  Future<WelcomeScreen> updateWelcomeScreen(Snowflake id, WelcomeScreenUpdateBuilder builder, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..welcomeScreen();
    final request = BasicRequest(route, method: 'PATCH', auditLogReason: auditLogReason, body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    return parseWelcomeScreen(response.jsonBody as Map<String, Object?>);
  }

  /// Fetch a guild's onboarding.
  Future<Onboarding> fetchOnboarding(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..onboarding();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseOnboarding(response.jsonBody as Map<String, Object?>);
  }

  /// Update the current user's voice state in a guild.
  Future<void> updateCurrentUserVoiceState(Snowflake id, CurrentUserVoiceStateUpdateBuilder builder) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..voiceStates(id: '@me');
    final request = BasicRequest(route, method: 'PATCH', body: jsonEncode(builder.build()));

    await client.httpHandler.executeSafe(request);
  }

  /// Update a member's voice state in a guild.
  Future<void> updateVoiceState(Snowflake id, Snowflake userId, VoiceStateUpdateBuilder builder) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..voiceStates(id: userId.toString());
    final request = BasicRequest(route, method: 'PATCH', body: jsonEncode(builder.build()));

    await client.httpHandler.executeSafe(request);
  }

  /// Fetch a guild template by [code].
  Future<GuildTemplate> fetchGuildTemplate(String code) async {
    final route = HttpRoute()
      ..guilds()
      ..templates(code: code);
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final template = parseGuildTemplate(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(template);
    return template;
  }

  /// Create a guild from a guild template.
  Future<Guild> createGuildFromTemplate(String code, {required String name, ImageBuilder? icon}) async {
    final route = HttpRoute()
      ..guilds()
      ..templates(code: code);
    final request = BasicRequest(route, method: 'POST', body: jsonEncode({'name': name, if (icon != null) 'icon': icon.buildDataString()}));

    final response = await client.httpHandler.executeSafe(request);
    final guild = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(guild);
    return guild;
  }

  /// List the templates in a guild.
  Future<List<GuildTemplate>> listGuildTemplates(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..templates();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final templates = parseMany(response.jsonBody as List<Object?>, parseGuildTemplate);

    templates.forEach(client.updateCacheWith);
    return templates;
  }

  /// Create a guild template.
  Future<GuildTemplate> createGuildTemplate(Snowflake id, GuildTemplateBuilder builder) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..templates();
    final request = BasicRequest(route, method: 'POST', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final template = parseGuildTemplate(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(template);
    return template;
  }

  /// Sync a guild template to the source guild.
  Future<GuildTemplate> syncGuildTemplate(Snowflake id, String code) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..templates(code: code);
    final request = BasicRequest(route, method: 'PUT');

    final response = await client.httpHandler.executeSafe(request);
    final template = parseGuildTemplate(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(template);
    return template;
  }

  /// Update a guild template.
  Future<GuildTemplate> updateGuildTemplate(Snowflake id, String code, GuildTemplateUpdateBuilder builder) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..templates(code: code);
    final request = BasicRequest(route, method: 'PATCH', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final template = parseGuildTemplate(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(template);
    return template;
  }

  /// Delete a guild template.
  Future<GuildTemplate> deleteGuildTemplate(Snowflake id, String code) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..templates(code: code);
    final request = BasicRequest(route, method: 'DELETE');

    final response = await client.httpHandler.executeSafe(request);
    final template = parseGuildTemplate(response.jsonBody as Map<String, Object?>);

    // Templates aren't cached, so we don't need to remove it from any cache, but it still contains a nested user object we can cache.
    client.updateCacheWith(template);
    return template;
  }
}
