import 'dart:convert';

import 'package:nyxx/src/builders/channel/channel_position.dart';
import 'package:nyxx/src/builders/channel/guild_channel.dart';
import 'package:nyxx/src/builders/guild.dart';
import 'package:nyxx/src/cache/cache.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/thread_list.dart';
import 'package:nyxx/src/models/guild/ban.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/guild_preview.dart';
import 'package:nyxx/src/models/guild/welcome_screen.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/flags.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

class GuildManager extends Manager<Guild> {
  final Cache<Ban> banCache;

  GuildManager(super.config, super.client, {required CacheConfig<Ban> banConfig}) : banCache = Cache('Ban', banConfig);

  @override
  PartialGuild operator [](Snowflake id) => PartialGuild(id: id, manager: this);

  @override
  Guild parse(Map<String, Object?> raw) {
    return Guild(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      name: raw['name'] as String,
      iconHash: (raw['icon'] ?? raw['icon_hash']) as String?,
      splashHash: raw['splash'] as String?,
      discoverySplashHash: raw['discovery_splash'] as String?,
      isOwnedByCurrentUser: raw['owner'] as bool?,
      ownerId: Snowflake.parse(raw['owner_id'] as String),
      currentUserPermissions: maybeParse(raw['permissions'], (String permissions) => Permissions(int.parse(permissions))),
      afkChannelId: maybeParse(raw['afk_channel_id'], Snowflake.parse),
      afkTimeout: Duration(seconds: raw['afk_timeout'] as int),
      isWidgetEnabled: raw['widget_enabled'] as bool? ?? false,
      widgetChannelId: maybeParse(raw['widget_channel_id'], Snowflake.parse),
      verificationLevel: VerificationLevel.parse(raw['verification_level'] as int),
      defaultMessageNotificationLevel: MessageNotificationLevel.parse(raw['default_message_notifications'] as int),
      explicitContentFilterLevel: ExplicitContentFilterLevel.parse(raw['explicit_content_filter'] as int),
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
    );
  }

  final Map<String, Flag<GuildFeatures>> _nameToGuildFeature = {
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
    'ROLE_ICONS': GuildFeatures.roleIcons,
    'ROLE_SUBSCRIPTIONS_AVAILABLE_FOR_PURCHASE': GuildFeatures.roleSubscriptionsAvailableForPurchase,
    'ROLE_SUBSCRIPTIONS_ENABLED': GuildFeatures.roleSubscriptionsEnabled,
    'TICKETED_EVENTS_ENABLED': GuildFeatures.ticketedEventsEnabled,
    'VANITY_URL': GuildFeatures.vanityUrl,
    'VERIFIED': GuildFeatures.verified,
    'VIP_REGIONS': GuildFeatures.vipRegions,
    'WELCOME_SCREEN_ENABLED': GuildFeatures.welcomeScreenEnabled,
  };

  late final Map<Flag<GuildFeatures>, String> _guildFeatureToName = {
    for (final entry in _nameToGuildFeature.entries) entry.value: entry.key,
  };

  GuildFeatures parseGuildFeatures(List<Object?> raw) {
    final featureFlags = parseMany(raw, parseGuildFeature);

    return GuildFeatures(featureFlags.fold(0, (value, element) => value | element.value));
  }

  Flag<GuildFeatures> parseGuildFeature(String raw) {
    // TODO: Add support for parsing unknown guild features.
    return _nameToGuildFeature[raw]!; // ?? Flag<GuildFeatures>(0);
  }

  List<String> serializeGuildFeatures(GuildFeatures source) {
    return source.map(serializeGuildFeature).toList();
  }

  String serializeGuildFeature(Flag<GuildFeatures> source) {
    return _guildFeatureToName[source]!;
  }

  WelcomeScreen parseWelcomeScreen(Map<String, Object?> raw) {
    return WelcomeScreen(
      description: raw['description'] as String?,
      channels: parseMany(raw['welcome_channels'] as List, parseWelcomeScreenChannel),
    );
  }

  WelcomeScreenChannel parseWelcomeScreenChannel(Map<String, Object?> raw) {
    return WelcomeScreenChannel(
      channelId: Snowflake.parse(raw['channel_id'] as String),
      description: raw['description'] as String,
      emojiId: maybeParse(raw['emoji_id'], Snowflake.parse),
      emojiName: raw['emoji_name'] as String?,
    );
  }

  GuildPreview parseGuildPreview(Map<String, Object?> raw) {
    return GuildPreview(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      name: raw['name'] as String,
      iconHash: raw['icon'] as String?,
      splashHash: raw['splash'] as String?,
      discoverySplashHash: raw['discovery_splash'] as String?,
      features: parseGuildFeatures(raw['features'] as List),
      description: raw['description'] as String?,
      approximateMemberCount: raw['approximate_member_count'] as int,
      approximatePresenceCount: raw['approximate_presence_count'] as int,
    );
  }

  Ban parseBan(Map<String, Object?> raw) {
    return Ban(
      reason: raw['reason'] as String,
      user: client.users.parse(raw['user'] as Map<String, Object?>),
    );
  }

  @override
  Future<Guild> fetch(Snowflake id, {bool? withCounts}) async {
    final route = HttpRoute()..guilds(id: id.toString());
    final request = BasicRequest(route, queryParameters: {if (withCounts != null) 'with_counts': withCounts.toString()});

    final response = await client.httpHandler.executeSafe(request);
    final guild = parse(response.jsonBody as Map<String, Object?>);

    cache[guild.id] = guild;
    return guild;
  }

  @override
  Future<Guild> create(GuildBuilder builder) async {
    final route = HttpRoute()..guilds();
    final request = BasicRequest(route, method: 'POST', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final guild = parse(response.jsonBody as Map<String, Object?>);

    cache[guild.id] = guild;
    return guild;
  }

  @override
  Future<Guild> update(Snowflake id, GuildUpdateBuilder builder, {String? auditLogReason}) async {
    final route = HttpRoute()..guilds(id: id.toString());
    final request = BasicRequest(route, method: 'PATCH', auditLogReason: auditLogReason, body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final guild = parse(response.jsonBody as Map<String, Object?>);

    cache[guild.id] = guild;
    return guild;
  }

  @override
  Future<void> delete(Snowflake id) async {
    final route = HttpRoute()..guilds(id: id.toString());
    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
    cache.remove(id);
  }

  Future<GuildPreview> fetchGuildPreview(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..preview();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseGuildPreview(response.jsonBody as Map<String, Object?>);
  }

  Future<List<GuildChannel>> fetchGuildChannels(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..channels();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final channels = parseMany(response.jsonBody as List, client.channels.parse).cast<GuildChannel>();

    client.channels.cache.addEntries(channels.map((channel) => MapEntry(channel.id, channel)));
    return channels;
  }

  Future<T> createGuildChannel<T extends GuildChannel>(Snowflake id, GuildChannelBuilder<T> builder, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..channels();
    final request = BasicRequest(route, method: 'POST', auditLogReason: auditLogReason, body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final channel = client.channels.parse(response.jsonBody as Map<String, Object?>) as T;

    client.channels.cache[channel.id] = channel;
    return channel;
  }

  Future<void> updateChannelPositions(Snowflake id, List<ChannelPositionBuilder> positions) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..channels();
    final request = BasicRequest(route, method: 'PATCH', body: jsonEncode(positions.map((e) => e.build()).toList()));

    await client.httpHandler.executeSafe(request);
  }

  Future<ThreadList> listActiveThreads(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..threads()
      ..active();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final list = client.channels.parseThreadList(response.jsonBody as Map<String, Object?>);

    client.channels.cache.addEntries(list.threads.map((e) => MapEntry(e.id, e)));
    return list;
  }

  Future<List<Ban>> listBans(Snowflake id, {int? limit, Snowflake? after, Snowflake? before}) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..bans();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final bans = parseMany(response.jsonBody as List, parseBan);

    banCache.addEntries(bans.map((e) => MapEntry(e.user.id, e)));
    return bans;
  }

  Future<Ban> fetchBan(Snowflake id, Snowflake userId) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..bans(id: userId.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final ban = parseBan(response.jsonBody as Map<String, Object?>);

    banCache[ban.user.id] = ban;
    return ban;
  }

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

  Future<void> deleteBan(Snowflake id, Snowflake userId, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..bans(id: userId.toString());
    final request = BasicRequest(route, method: 'DELETE', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);
  }

  Future<void> updateMfaLevel(Snowflake id, MfaLevel level, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: id.toString())
      ..mfa();
    final request = BasicRequest(
      route,
      method: 'POST',
      auditLogReason: auditLogReason,
      body: jsonEncode({'level': level.value}),
    );

    await client.httpHandler.executeSafe(request);
  }

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
}
