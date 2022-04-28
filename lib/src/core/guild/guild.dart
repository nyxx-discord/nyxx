import 'package:nyxx/src/core/audit_logs/audit_log.dart';
import 'package:nyxx/src/core/audit_logs/audit_log_entry.dart';
import 'package:nyxx/src/core/channel/guild/guild_channel.dart';
import 'package:nyxx/src/core/channel/invite.dart';
import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/guild/guild_feature.dart';
import 'package:nyxx/src/core/guild/guild_nsfw_level.dart';
import 'package:nyxx/src/core/guild/guild_preview.dart';
import 'package:nyxx/src/core/guild/guild_welcome_screen.dart';
import 'package:nyxx/src/core/guild/premium_tier.dart';
import 'package:nyxx/src/core/guild/scheduled_event.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/user/presence.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/internal/cache/cache.dart';
import 'package:nyxx/src/internal/exceptions/invalid_shard_exception.dart';
import 'package:nyxx/src/internal/shard/shard.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/channel/cacheable_text_channel.dart';
import 'package:nyxx/src/core/channel/channel.dart';
import 'package:nyxx/src/core/channel/guild/text_guild_channel.dart';
import 'package:nyxx/src/core/channel/guild/voice_channel.dart';
import 'package:nyxx/src/core/guild/ban.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/message/guild_emoji.dart';
import 'package:nyxx/src/core/message/sticker.dart';
import 'package:nyxx/src/core/permissions/permissions.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/core/voice/voice_region.dart';
import 'package:nyxx/src/core/voice/voice_state.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/attachment_builder.dart';
import 'package:nyxx/src/utils/builders/channel_builder.dart';
import 'package:nyxx/src/utils/builders/guild_builder.dart';
import 'package:nyxx/src/utils/builders/guild_event_builder.dart';
import 'package:nyxx/src/utils/builders/sticker_builder.dart';

abstract class IGuild implements SnowflakeEntity {
  /// Reference to [NyxxWebsocket] instance
  INyxx get client;

  /// The guild's name.
  String get name;

  /// The guild's icon hash.
  String? get icon;

  /// Splash hash
  String? get splash;

  /// Discovery splash hash
  String? get discoverySplash;

  /// System channel where system messages are sent
  Cacheable<Snowflake, ITextGuildChannel>? get systemChannel;

  /// enabled guild features
  Iterable<GuildFeature> get features;

  /// The guild's afk channel ID, null if not set.
  Cacheable<Snowflake, IVoiceGuildChannel>? get afkChannel;

  /// The channel ID for the guild's widget if enabled.
  Cacheable<Snowflake, ITextGuildChannel>? get embedChannel;

  /// The guild's AFK timeout.
  int get afkTimeout;

  /// The guild's verification level.
  int get verificationLevel;

  /// The guild's notification level.
  int get notificationLevel;

  /// The guild's MFA level.
  int get mfaLevel;

  /// If the guild's widget is enabled.
  bool? get embedEnabled;

  /// Whether or not the guild is available.
  bool get available;

  /// System Channel Flags
  int get systemChannelFlags;

  /// Channel where "PUBLIC" guilds display rules and/or guidelines
  Cacheable<Snowflake, ITextChannel>? get rulesChannel;

  /// The guild owner's ID
  Cacheable<Snowflake, IUser> get owner;

  /// The guild's members.
  Map<Snowflake, IMember> get members;

  /// The guild's channels.
  Iterable<IGuildChannel> get channels;

  /// The guild's roles.
  Map<Snowflake, IRole> get roles;

  /// Guild custom emojis
  Map<Snowflake, IBaseGuildEmoji> get emojis;

  /// Boost level of guild
  PremiumTier get premiumTier;

  /// The number of boosts this server currently has
  int? get premiumSubscriptionCount;

  /// the preferred locale of a "PUBLIC" guild used
  /// in server discovery and notices from Discord; defaults to "en-US"
  String get preferredLocale;

  /// the id of the channel where admins and moderators
  /// of "PUBLIC" guilds receive notices from Discord
  CacheableTextChannel<ITextChannel>? get publicUpdatesChannel;

  /// Permission of current(bot) user in this guild
  IPermissions? get currentUserPermissions;

  /// Users state cache
  Map<Snowflake, IVoiceState> get voiceStates;

  /// Stage instances in the guild
  Iterable<IStageChannelInstance> get stageInstances;

  /// Nsfw level of guild
  GuildNsfwLevel get guildNsfwLevel;

  /// Stickers of this guild
  Iterable<IGuildSticker> get stickers;

  /// Returns url to this guild.
  String get url;

  /// Getter for @everyone role
  IRole get everyoneRole;

  /// Returns member object for bot user
  Cacheable<Snowflake, IMember> get selfMember;

  /// File upload limit for channel in bytes.
  int get fileUploadLimit;

  /// Returns this guilds shard
  IShard get shard;

  /// Whether the guild has the boost progress bar enabled
  bool get boostProgressBarEnabled;

  /// The banner hash of the guild, if any.
  String? get banner;

  /// List of partial presences.
  ///
  /// Will only include non-offline members if the size of the guild is greater than the [ClientOptions.largeThreshold] option.
  List<IPartialPresence?> get presences;

  /// If this guild is considered large.
  bool get large;

  /// The maximum amount of members that can be in this guild.
  int get maximumMembers;

  /// The maximum amount of presences that can be in this guild.
  int? get maximumPresences;

  /// Explicit content filter level of this guild.
  int get explicitContentFilterLevel;

  /// The vanity URL code of this guild. If any.
  String? get vanityUrlCode;

  /// The description of this guild. If it's a community guild.
  String? get description;

  /// The total amount of members in this guild.
  int? get memberCount;

  /// The approximate amount of members in this guild.
  int? get approxMemberCount;

  /// The approximate amount of presences in the guild.
  int? get approxPresenceCount;

  /// The guild's icon, represented as URL.
  /// If guild doesn't have icon it returns null.
  String? iconURL({String format = "webp", int size = 128});

  /// URL to guild's splash.
  /// If guild doesn't have splash it returns null.
  String? splashURL({String format = "webp", int size = 128});

  /// URL to guilds discovery splash
  /// If guild doesn't have splash it returns null.
  String? discoveryURL({String format = "webp", int size = 128});

  /// URL to guild's banner.
  /// If guild doesn't have banner it returns null.
  String? bannerUrl({String? format, int? size});

  /// Allows to download [Guild] widget aka advert png
  /// Possible options for [style]: shield (default), banner1, banner2, banner3, banner4
  String guildWidgetUrl([String style = "shield"]);

  /// Fetches all stickers of current guild
  Stream<IGuildSticker> fetchStickers();

  /// Fetch sticker with given [id]
  Future<IGuildSticker> fetchSticker(Snowflake id);

  /// Fetches all roles that are in the server.
  Stream<IRole> fetchRoles();

  /// Creates sticker in current guild
  Future<IGuildSticker> createSticker(StickerBuilder builder);

  /// Fetches emoji from API
  Future<IBaseGuildEmoji> fetchEmoji(Snowflake emojiId);

  /// Allows to create new guild emoji. [name] is required. You can allow to set [roles] to restrict emoji usage.
  /// Put your image in [emojiAttachment] field.
  ///
  /// ```
  /// var emojiFile = File("weed.png");
  /// var emoji = await guild.createEmoji("weed", emojiAttachment: AttachmentBuilder.file(emojiFile));
  /// ```
  Future<IBaseGuildEmoji> createEmoji(String name, {List<SnowflakeEntity>? roles, AttachmentBuilder? emojiAttachment});

  /// Returns [int] indicating the number of members that would be removed in a prune operation.
  Future<int> pruneCount(int days, {Iterable<Snowflake>? includeRoles});

  /// Prunes the guild, returns the amount of members pruned.
  Future<int> prune(int days, {Iterable<Snowflake>? includeRoles, String? auditReason});

  /// Gets the guild's bans.
  Stream<IBan> getBans({int limit = 1000, Snowflake? before, Snowflake? after});

  /// Change self nickname in guild
  Future<void> modifyCurrentMember({String? nick});

  /// Gets single [Ban] object for given [bannedUserId]
  Future<IBan> getBan(Snowflake bannedUserId);

  /// Change guild owner.
  Future<IGuild> changeOwner(SnowflakeEntity memberEntity, {String? auditReason});

  /// Leaves the guild.
  Future<void> leave();

  /// Returns list of Guilds invites
  Stream<IInvite> fetchGuildInvites();

  /// Returns Audit logs.
  /// https://discordapp.com/developers/docs/resources/audit-log
  /// ```dart
  /// var logs = await guild.fetchAuditLogs(auditType: AuditLogEntryType.guildUpdate);
  /// ```
  Future<IAuditLog> fetchAuditLogs({Snowflake? userId, AuditLogEntryType? auditType, Snowflake? before, int? limit});

  /// Creates new role
  /// ```dart
  /// var rb = new RoleBuilder("Dartyy")
  ///   ..color = DiscordColor.fromInt(0xFF04F2)
  ///   ..hoist = true;
  ///
  /// var role = await guild.createRole(roleBuilder);
  /// ```
  Future<IRole> createRole(RoleBuilder roleBuilder, {String? auditReason});

  /// Returns list of available [VoiceRegion]s
  Stream<IVoiceRegion> getVoiceRegions();

  /// Moves channel
  Future<void> moveChannel(IChannel channel, int position, {String? auditReason});

  /// Bans a user and allows to delete messages from [deleteMessageDays] number of days.
  /// ```dart
  /// await guild.ban(member);
  /// ```
  Future<void> ban(SnowflakeEntity user, {int deleteMessageDays = 0, String? auditReason});

  /// Kicks user from guild. Member is removed from guild and they're able to rejoin if they have a valid invite link.
  /// ```dart
  /// await guild.kick(member);
  /// ```
  Future<void> kick(SnowflakeEntity user, {String? auditReason});

  /// Unbans a user by ID.
  Future<void> unban(Snowflake id, Snowflake userId);

  /// Edits the guild.
  Future<IGuild> edit(GuildBuilder builder, {String? auditReason});

  /// Fetches member from API
  Future<IMember> fetchMember(Snowflake memberId);

  /// Allows to fetch guild members. In future will be restricted with `Privileged Intents`.
  /// [after] is used to continue from specified user id.
  /// By default limits to one user - use [limit] parameter to change that behavior.
  Stream<IMember> fetchMembers({int limit = 1, Snowflake? after});

  /// Returns a [Stream] of [Member]s objects whose username or nickname starts with a provided string.
  /// By default limits to one entry - can be changed with [limit] parameter.
  Stream<IMember> searchMembers(String query, {int limit = 1});

  /// Returns a [Stream] of [Member]s objects whose username or nickname starts with a provided string.
  /// By default limits to one entry - can be changed with [limit] parameter.
  Stream<IMember> searchMembersGateway(String query, {int limit = 0});

  /// Fetches guild preview for this guild. Allows to download approx member count in guild
  Future<IGuildPreview> fetchGuildPreview();

  /// Request members from gateway. Requires privileged intents in order to work.
  void requestChunking();

  /// Allows to create new guild channel
  Future<IChannel> createChannel(ChannelBuilder channelBuilder);

  /// Deletes the guild.
  Future<void> delete();

  /// Creates guild event using [builder]
  Future<GuildEvent> createGuildEvent(GuildEventBuilder builder);

  /// Fetches and returns from api single event with given id
  Future<GuildEvent> fetchGuildEvent(Snowflake guildEventId);

  /// Fetches from api list of events in guild
  Stream<GuildEvent> fetchGuildEvents({bool withUserCount = false});

  /// Fetches the welcome screen of this guild if it's a community guild.
  Future<IGuildWelcomeScreen?> fetchWelcomeScreen();
}

class Guild extends SnowflakeEntity implements IGuild {
  /// Reference to [NyxxWebsocket] instance
  @override
  final INyxx client;

  /// The guild's name.
  @override
  late final String name;

  /// The guild's icon hash.
  @override
  late String? icon;

  /// Splash hash
  @override
  late String? splash;

  /// Discovery splash hash
  @override
  late String? discoverySplash;

  /// System channel where system messages are sent
  @override
  late final Cacheable<Snowflake, TextGuildChannel>? systemChannel;

  /// enabled guild features
  @override
  late final Iterable<GuildFeature> features;

  /// The guild's afk channel ID, null if not set.
  @override
  late Cacheable<Snowflake, IVoiceGuildChannel>? afkChannel;

  /// The channel ID for the guild's widget if enabled.
  @override
  late final Cacheable<Snowflake, TextGuildChannel>? embedChannel;

  /// The guild's AFK timeout.
  @override
  late final int afkTimeout;

  /// The guild's verification level.
  @override
  late final int verificationLevel;

  /// The guild's notification level.
  @override
  late final int notificationLevel;

  /// The guild's MFA level.
  @override
  late final int mfaLevel;

  /// If the guild's widget is enabled.
  @override
  late final bool? embedEnabled;

  /// Whether or not the guild is available.
  @override
  late final bool available;

  /// System Channel Flags
  @override
  late final int systemChannelFlags;

  /// Channel where "PUBLIC" guilds display rules and/or guidelines
  @override
  late final Cacheable<Snowflake, ITextChannel>? rulesChannel;

  /// The guild owner's ID
  @override
  late final Cacheable<Snowflake, IUser> owner;

  /// The guild's members.
  @override
  late final SnowflakeCache<IMember> members;

  /// The guild's channels.
  @override
  Iterable<IGuildChannel> get channels => client.channels.values.where((item) => item is IGuildChannel && item.guild.id == id).cast();

  /// The guild's roles.
  @override
  late final SnowflakeCache<IRole> roles;

  /// Guild custom emojis
  @override
  late final SnowflakeCache<IBaseGuildEmoji> emojis;

  /// Boost level of guild
  @override
  late final PremiumTier premiumTier;

  /// The number of boosts this server currently has
  @override
  late final int? premiumSubscriptionCount;

  /// the preferred locale of a "PUBLIC" guild used
  /// in server discovery and notices from Discord; defaults to "en-US"
  @override
  late final String preferredLocale;

  /// the id of the channel where admins and moderators
  /// of "PUBLIC" guilds receive notices from Discord
  @override
  late final CacheableTextChannel<ITextChannel>? publicUpdatesChannel;

  /// Permission of current(bot) user in this guild
  @override
  late final IPermissions? currentUserPermissions;

  /// Users state cache
  @override
  late final Map<Snowflake, IVoiceState> voiceStates;

  /// Stage instances in the guild
  @override
  late final Iterable<IStageChannelInstance> stageInstances;

  /// Nsfw level of guild
  @override
  late final GuildNsfwLevel guildNsfwLevel;

  /// Stickers of this guild
  @override
  late final Iterable<IGuildSticker> stickers;

  @override
  late final bool boostProgressBarEnabled;

  /// The banner hash of the guild. If any.
  @override
  late final String? banner;

  /// List of partial presences.
  ///
  /// Will only include non-offline members if the size of the guild is greater than the [ClientOptions.largeThreshold] option.
  @override
  late final List<IPartialPresence?> presences;

  /// If this guild is considered large.
  @override
  late final bool large;

  /// The maximum amount of members that can be in this guild.
  @override
  late final int maximumMembers;

  /// The approximate amount of members in this guild.
  @override
  late final int? approxMemberCount;

  /// The approximate amount of presences in this guild.
  @override
  late final int? approxPresenceCount;

  /// The maximum amount of presences that can be in this guild.
  @override
  late final int? maximumPresences;

  /// Explicit content filter level of guild
  @override
  late final int explicitContentFilterLevel;

  /// The vanity URL code of the guild. If any.
  @override
  late final String? vanityUrlCode;

  /// The description of the guild. If it's a community guild.
  @override
  late final String? description;

  /// The total amount of members in the guild.
  @override
  late final int? memberCount;

  /// Returns url to this guild.
  @override
  String get url => "https://discordapp.com/guilds/${id.toString()}";

  /// Getter for @everyone role
  @override
  IRole get everyoneRole => roles.values.firstWhere((r) => r.name == "@everyone");

  /// Returns member object for bot user
  @override
  Cacheable<Snowflake, IMember> get selfMember {
    if (client is! NyxxWebsocket) {
      throw UnsupportedError("Cannot use this property with NyxxRest");
    }

    return MemberCacheable(client, (client as NyxxWebsocket).self.id, GuildCacheable(client, id));
  }

  /// File upload limit for channel in bytes.
  @override
  int get fileUploadLimit {
    const megabyte = 1024 * 1024;

    if (premiumTier == PremiumTier.tier2) {
      return 50 * megabyte;
    }

    if (premiumTier == PremiumTier.tier3) {
      return 100 * megabyte;
    }

    return 8 * megabyte;
  }

  /// Returns this guilds shard
  @override
  IShard get shard {
    if (client is! NyxxWebsocket) {
      throw UnsupportedError("Cannot use this property with NyxxRest");
    }

    final shardId = (id.id >> 22) % (client as NyxxWebsocket).shardManager.shards.length;

    return (client as NyxxWebsocket).shardManager.shards.firstWhere(
          (element) => element.id == shardId,
          orElse: () =>
              throw InvalidShardException('Cannot find shard for this guild! Calculated shard id for this guild is: $shardId but no such shard exist'),
        );
  }

  /// Creates an instance of [Guild]
  Guild(this.client, RawApiMap raw, [bool guildCreate = false]) : super(Snowflake(raw["id"])) {
    name = raw["name"] as String;
    afkTimeout = raw["afk_timeout"] as int;
    mfaLevel = raw["mfa_level"] as int;
    verificationLevel = raw["verification_level"] as int;
    notificationLevel = raw["default_message_notifications"] as int;
    available = !(raw["unavailable"] as bool? ?? false);

    icon = raw["icon"] as String?;
    discoverySplash = raw["discovery_splash"] as String?;
    splash = raw["splash"] as String?;
    embedEnabled = raw["widget_enabled"] as bool?;

    systemChannelFlags = raw["system_channel_flags"] as int;
    premiumTier = PremiumTier.from(raw["premium_tier"] as int);
    premiumSubscriptionCount = raw["premium_subscription_count"] as int?;
    preferredLocale = raw["preferred_locale"] as String;
    boostProgressBarEnabled = raw['premium_progress_bar_enabled'] as bool;
    banner = raw['banner'] as String?;
    large = raw["large"] as bool? ?? false;
    maximumMembers = raw["max_members"] as int;
    maximumPresences = raw["max_presences"] as int?;
    explicitContentFilterLevel = raw["explicit_content_filter"] as int;
    vanityUrlCode = raw["vanity_url_code"] as String?;
    description = raw["description"] as String?;
    memberCount = raw["member_count"] as int?;
    approxMemberCount = raw["approximate_member_count"] as int?;
    approxPresenceCount = raw["approximate_presence_count"] as int?;

    owner = UserCacheable(client, Snowflake(raw["owner_id"]));

    roles = SnowflakeCache<IRole>();
    if (raw["roles"] != null) {
      raw["roles"].forEach((o) {
        final role = Role(client, o as RawApiMap, id);
        roles[role.id] = role;
      });
    }

    emojis = SnowflakeCache<IBaseGuildEmoji>();
    if (raw["emojis"] != null) {
      raw["emojis"].forEach((dynamic o) {
        final emoji = GuildEmoji(client, o as RawApiMap, id);
        emojis[emoji.id] = emoji;
      });
    }

    if (raw["widget_channel_id"] != null) {
      embedChannel = ChannelCacheable(client, Snowflake(raw["widget_channel_id"]));
    } else {
      embedChannel = null;
    }

    if (raw["system_channel_id"] != null) {
      systemChannel = ChannelCacheable(client, Snowflake(raw["system_channel_id"]));
    } else {
      systemChannel = null;
    }

    features = (raw["features"] as RawApiList).map((e) => GuildFeature.from(e.toString()));

    if (raw["permissions"] != null) {
      currentUserPermissions = Permissions(raw["permissions"] as int);
    } else {
      currentUserPermissions = null;
    }

    afkChannel = raw["afk_channel_id"] != null ? ChannelCacheable(client, Snowflake(raw["afk_channel_id"])) : null;

    members = SnowflakeCache();
    voiceStates = SnowflakeCache();

    guildNsfwLevel = GuildNsfwLevel.from(raw["nsfw_level"] as int);

    stickers = [
      if (raw["stickers"] != null)
        for (final rawSticker in raw["stickers"]) GuildSticker(rawSticker as RawApiMap, client)
    ];

    if (!guildCreate) return;

    raw["channels"].forEach((o) {
      final channel = Channel.deserialize(client, o as RawApiMap, id);
      client.channels[channel.id] = channel;
    });

    if (client.cacheOptions.memberCachePolicyLocation.objectConstructor) {
      raw["members"].forEach((o) {
        final member = Member(client, o as RawApiMap, id);
        if (client.cacheOptions.memberCachePolicy.canCache(member)) {
          members[member.id] = member;
        }
      });
    }

    if (raw["voice_states"] != null) {
      raw["voice_states"].forEach((o) {
        final state = VoiceState(client, o as RawApiMap);
        voiceStates[state.user.id] = state;
      });
    }

    if (raw["rules_channel_id"] != null) {
      rulesChannel = ChannelCacheable(client, Snowflake(raw["rules_channel_id"]));
    } else {
      rulesChannel = null;
    }

    if (raw["public_updates_channel_id"] != null) {
      publicUpdatesChannel = CacheableTextChannel<ITextChannel>(client, Snowflake(raw["public_updates_channel_id"]));
    } else {
      publicUpdatesChannel = null;
    }

    presences = [
      if (raw['presences'] != null)
        for (final presence in raw['presences']) PartialPresence(presence as RawApiMap, client)
    ];

    stageInstances = [
      if (raw["stage_instances"] != null)
        for (final rawInstance in raw["stage_instances"]) StageChannelInstance(client, rawInstance as RawApiMap)
    ];
  }

  /// The guild's icon, represented as URL.
  /// If guild doesn't have icon it returns null.
  @override
  String? iconURL({String format = "webp", int size = 128}) => client.httpEndpoints.getGuildIconUrl(id, icon, format, size);

  /// URL to guild's splash.
  /// If guild doesn't have splash it returns null.
  @override
  String? splashURL({String format = "webp", int size = 128}) => client.httpEndpoints.getGuildSplashURL(id, splash, format, size);

  /// URL to guilds discovery splash
  /// If guild doesn't have splash it returns null.
  @override
  String? discoveryURL({String format = "webp", int size = 128}) => client.httpEndpoints.getGuildDiscoveryURL(id, splash, format: format, size: size);

  /// Allows to download [Guild] widget aka advert png
  /// Possible options for [style]: shield (default), banner1, banner2, banner3, banner4
  @override
  String guildWidgetUrl([String style = "shield"]) => client.httpEndpoints.getGuildWidgetUrl(id, style);

  /// Returns the URL to guild's banner.
  /// If guild doesn't have banner it returns null.
  @override
  String? bannerUrl({String? format, int? size}) => client.httpEndpoints.getGuildBannerUrl(id, banner, format: format, size: size);

  /// Fetches all stickers of current guild
  @override
  Stream<IGuildSticker> fetchStickers() => client.httpEndpoints.fetchGuildStickers(id);

  /// Fetch sticker with given [id]
  @override
  Future<IGuildSticker> fetchSticker(Snowflake id) => client.httpEndpoints.fetchGuildSticker(this.id, id);

  /// Fetches all roles that are in the server.
  @override
  Stream<IRole> fetchRoles() => client.httpEndpoints.fetchGuildRoles(id);

  /// Creates sticker in current guild
  @override
  Future<IGuildSticker> createSticker(StickerBuilder builder) => client.httpEndpoints.createGuildSticker(id, builder);

  /// Fetches emoji from API
  @override
  Future<IBaseGuildEmoji> fetchEmoji(Snowflake emojiId) => client.httpEndpoints.fetchGuildEmoji(id, emojiId);

  /// Allows to create new guild emoji. [name] is required. You can allow to set [roles] to restrict emoji usage.
  /// Put your image in [emojiAttachment] field.
  ///
  /// ```dart
  /// var emojiFile = File("weed.png");
  /// var emoji = await guild.createEmoji("weed", emojiAttachment: AttachmentBuilder.file(emojiFile));
  /// ```
  @override
  Future<IBaseGuildEmoji> createEmoji(String name, {List<SnowflakeEntity>? roles, AttachmentBuilder? emojiAttachment}) =>
      client.httpEndpoints.createEmoji(id, name, roles: roles, emojiAttachment: emojiAttachment);

  /// Returns [int] indicating the number of members that would be removed in a prune operation.
  @override
  Future<int> pruneCount(int days, {Iterable<Snowflake>? includeRoles}) => client.httpEndpoints.guildPruneCount(id, days, includeRoles: includeRoles);

  /// Prunes the guild, returns the amount of members pruned.
  @override
  Future<int> prune(int days, {Iterable<Snowflake>? includeRoles, String? auditReason}) =>
      client.httpEndpoints.guildPrune(id, days, includeRoles: includeRoles, auditReason: auditReason);

  /// Gets the guild's bans.
  @override
  Stream<IBan> getBans({int limit = 1000, Snowflake? before, Snowflake? after}) =>
      client.httpEndpoints.getGuildBans(id, limit: limit, before: before, after: after);

  /// Change self nickname in guild
  @override
  Future<void> modifyCurrentMember({String? nick}) async => client.httpEndpoints.modifyCurrentMember(id, nick: nick);

  /// Gets single [Ban] object for given [bannedUserId]
  @override
  Future<IBan> getBan(Snowflake bannedUserId) async => client.httpEndpoints.getGuildBan(id, bannedUserId);

  /// Change guild owner.
  @override
  Future<IGuild> changeOwner(SnowflakeEntity memberEntity, {String? auditReason}) =>
      client.httpEndpoints.changeGuildOwner(id, memberEntity, auditReason: auditReason);

  /// Leaves the guild.
  @override
  Future<void> leave() async => client.httpEndpoints.leaveGuild(id);

  /// Returns list of Guilds invites
  @override
  Stream<IInvite> fetchGuildInvites() => client.httpEndpoints.fetchGuildInvites(id);

  /// Returns Audit logs.
  /// https://discordapp.com/developers/docs/resources/audit-log
  ///
  /// ```dart
  /// var logs = await guild.fetchAuditLogs(auditType: AuditLogEntryType.guildUpdate);
  /// ```
  @override
  Future<IAuditLog> fetchAuditLogs({Snowflake? userId, AuditLogEntryType? auditType, Snowflake? before, int? limit}) =>
      client.httpEndpoints.fetchAuditLogs(id, userId: userId, auditType: auditType, before: before, limit: limit);

  /// Creates new role
  ///
  /// ```dart
  /// var rb = RoleBuilder("Dartyy")
  ///   ..color = DiscordColor.fromInt(0xFF04F2)
  ///   ..hoist = true;
  ///
  /// var role = await guild.createRole(roleBuilder);
  /// ```
  @override
  Future<IRole> createRole(RoleBuilder roleBuilder, {String? auditReason}) => client.httpEndpoints.createGuildRole(id, roleBuilder, auditReason: auditReason);

  /// Returns list of available [VoiceRegion]s
  @override
  Stream<IVoiceRegion> getVoiceRegions() => client.httpEndpoints.fetchGuildVoiceRegions(id);

  /// Moves the [position] from the given [channel].
  @override
  Future<void> moveChannel(IChannel channel, int position, {String? auditReason}) =>
      client.httpEndpoints.moveGuildChannel(id, channel.id, position, auditReason: auditReason);

  /// Bans a user and allows to delete messages from [deleteMessageDays] number of days.
  /// ```dart
  /// await guild.ban(member);
  /// ```
  @override
  Future<void> ban(SnowflakeEntity user, {int deleteMessageDays = 0, String? auditReason}) =>
      client.httpEndpoints.guildBan(id, user.id, deleteMessageDays: deleteMessageDays, auditReason: auditReason);

  /// Kicks user from guild. Member is removed from guild and they're able to rejoin if they have a valid invite link.
  ///
  /// ```dart
  /// await guild.kick(member);
  /// ```
  @override
  Future<void> kick(SnowflakeEntity user, {String? auditReason}) => client.httpEndpoints.guildKick(id, user.id, auditReason: auditReason);

  /// Unbans a user by ID.
  @override
  Future<void> unban(Snowflake id, Snowflake userId) => client.httpEndpoints.guildUnban(this.id, userId);

  /// Edits the guild.
  @override
  Future<IGuild> edit(GuildBuilder builder, {String? auditReason}) => client.httpEndpoints.editGuild(id, builder, auditReason: auditReason);

  /// Fetches member from API
  @override
  Future<IMember> fetchMember(Snowflake memberId) => client.httpEndpoints.fetchGuildMember(id, memberId);

  /// Allows to fetch guild members. In future will be restricted with `Privileged Intents`.
  /// [after] is used to continue from specified user id.
  /// By default limits to one user - use [limit] parameter to change that behavior.
  @override
  Stream<IMember> fetchMembers({int limit = 1, Snowflake? after}) => client.httpEndpoints.fetchGuildMembers(id, limit: limit, after: after);

  /// Returns a [Stream] of [IMember]s objects whose username or nickname starts with a provided string.
  /// By default limits to one entry - can be changed with [limit] parameter.
  @override
  Stream<IMember> searchMembers(String query, {int limit = 1}) => client.httpEndpoints.searchGuildMembers(id, query, limit: limit);

  /// Returns a [Stream] of [IMember]s objects whose username or nickname starts with a provided string.
  /// By default limits to one entry - can be changed with [limit] parameter.
  @override
  Stream<IMember> searchMembersGateway(String query, {int limit = 0}) async* {
    final nonce = "$query${id.toString()}";
    shard.requestMembers(id, query: query, limit: limit, nonce: nonce);

    final first = (await shard.onMemberChunk.take(1).toList()).first;

    for (final member in first.members) {
      yield member;
    }

    if (first.chunkCount > 1) {
      await for (final event in shard.onMemberChunk.where((event) => event.nonce == nonce).take(first.chunkCount - 1)) {
        for (final member in event.members) {
          yield member;
        }
      }
    }
  }

  /// Fetches guild preview for this guild. Allows to download approx member count in guild
  @override
  Future<IGuildPreview> fetchGuildPreview() async => client.httpEndpoints.fetchGuildPreview(id);

  /// Request members from gateway. Requires privileged intents in order to work.
  @override
  void requestChunking() => shard.requestMembers(id);

  /// Allows to create new guild channel
  @override
  Future<IChannel> createChannel(ChannelBuilder channelBuilder) => client.httpEndpoints.createGuildChannel(id, channelBuilder);

  /// Deletes the guild.
  @override
  Future<void> delete() => client.httpEndpoints.deleteGuild(id);

  @override
  Future<GuildEvent> createGuildEvent(GuildEventBuilder builder) => client.httpEndpoints.createGuildEvent(id, builder);

  @override
  Future<GuildEvent> fetchGuildEvent(Snowflake guildEventId) => client.httpEndpoints.fetchGuildEvent(id, guildEventId);

  @override
  Stream<GuildEvent> fetchGuildEvents({bool withUserCount = false}) => client.httpEndpoints.fetchGuildEvents(id);

  @override
  Future<IGuildWelcomeScreen> fetchWelcomeScreen() => client.httpEndpoints.fetchGuildWelcomeScreen(id);
}
