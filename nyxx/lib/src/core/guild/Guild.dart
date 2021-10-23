import 'package:nyxx/src/core/Invite.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/SnowflakeEntity.dart';
import 'package:nyxx/src/core/audit_logs/AuditLog.dart';
import 'package:nyxx/src/core/channel/Channel.dart';
import 'package:nyxx/src/core/channel/CacheableTextChannel.dart';
import 'package:nyxx/src/core/channel/guild/GuildChannel.dart';
import 'package:nyxx/src/core/channel/guild/TextGuildChannel.dart';
import 'package:nyxx/src/core/channel/guild/VoiceChannel.dart';
import 'package:nyxx/src/core/guild/Ban.dart';
import 'package:nyxx/src/core/guild/GuildFeature.dart';
import 'package:nyxx/src/core/guild/GuildNsfwLevel.dart';
import 'package:nyxx/src/core/guild/GuildPreview.dart';
import 'package:nyxx/src/core/guild/PremiumTier.dart';
import 'package:nyxx/src/core/guild/Role.dart';
import 'package:nyxx/src/core/message/GuildEmoji.dart';
import 'package:nyxx/src/core/message/Sticker.dart';
import 'package:nyxx/src/core/permissions/Permissions.dart';
import 'package:nyxx/src/core/user/Member.dart';
import 'package:nyxx/src/core/user/User.dart';
import 'package:nyxx/src/core/voice/VoiceRegion.dart';
import 'package:nyxx/src/core/voice/VoiceState.dart';
import 'package:nyxx/src/internal/cache/Cache.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
import 'package:nyxx/src/internal/shard/Shard.dart';
import 'package:nyxx/src/utils/builders/AttachmentBuilder.dart';
import 'package:nyxx/src/utils/builders/GuildBuilder.dart';
import 'package:nyxx/src/utils/builders/StickerBuilder.dart';
import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/channel/ITextChannel.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IGuild implements SnowflakeEntity {
  /// Reference to [NyxxWebsocket] instance
  INyxx get client;

  /// The guild's name.
  String get name;

  /// The guild's icon hash.
  String? get icon;

  /// Splash hash
  String? get splash;

class Guild extends SnowflakeEntity {
  /// Reference to [Nyxx] instance
  final INyxx client;

  /// The guild's name.
  late final String name;

  /// The guild's icon hash.
  late String? icon;

  /// Splash hash
  late String? splash;

  /// Discovery splash hash
  late String? discoverySplash;

  /// System channel where system messages are sent
  late final Cacheable<Snowflake, TextGuildChannel>? systemChannel;

  /// enabled guild features
  late final Iterable<GuildFeature> features;

  /// The guild's afk channel ID, null if not set.
  late Cacheable<Snowflake, IVoiceGuildChannel>? afkChannel;

  /// The guild's voice region.
  late String region;

  /// The channel ID for the guild's widget if enabled.
  late final Cacheable<Snowflake, TextGuildChannel>? embedChannel;

  /// The guild's AFK timeout.
  late final int afkTimeout;

  /// The guild's verification level.
  late final int verificationLevel;

  /// The guild's notification level.
  late final int notificationLevel;

  /// The guild's MFA level.
  late final int mfaLevel;

  /// If the guild's widget is enabled.
  late final bool? embedEnabled;

  /// Whether or not the guild is available.
  late final bool available;

  /// System Channel Flags
  late final int systemChannelFlags;

  /// Channel where "PUBLIC" guilds display rules and/or guidelines
  late final Cacheable<Snowflake, ITextChannel>? rulesChannel;

  /// The guild owner's ID
  late final Cacheable<Snowflake, IUser> owner;

  /// The guild's members.
  late final SnowflakeCache<Member> members;

  /// The guild's channels.
  Iterable<IGuildChannel> get channels => this.client.channels.values
      .where((item) => item is IGuildChannel && item.guild.id == this.id).cast();

  /// The guild's roles.
  late final Map<Snowflake, IRole> roles;

  /// Guild custom emojis
  late final Map<Snowflake, BaseGuildEmoji> emojis;

  /// Boost level of guild
  late final PremiumTier premiumTier;

  /// The number of boosts this server currently has
  late final int? premiumSubscriptionCount;

  /// the preferred locale of a "PUBLIC" guild used
  /// in server discovery and notices from Discord; defaults to "en-US"
  late final String preferredLocale;

  /// the id of the channel where admins and moderators
  /// of "PUBLIC" guilds receive notices from Discord
  late final CacheableTextChannel<ITextChannel>? publicUpdatesChannel;

  /// Permission of current(bot) user in this guild
  late final IPermissions? currentUserPermissions;

  /// Users state cache
  late final SnowflakeCache<IVoiceState> voiceStates;

  /// Stage instances in the guild
  late final Iterable<IStageChannelInstance> stageInstances;

  /// Nsfw level of guild
  late final GuildNsfwLevel guildNsfwLevel;

  /// Stickers of this guild
  late final Iterable<IGuildSticker> stickers;

  /// Returns url to this guild.
  String get url => "https://discordapp.com/channels/${this.id.toString()}";

  /// Getter for @everyone role
  IRole get everyoneRole => roles.values.firstWhere((r) => r.name == "@everyone");

  /// Returns member object for bot user
  Cacheable<Snowflake, IMember> get selfMember {
    if (this.client is! NyxxWebsocket) {
      throw new UnsupportedError("Cannot use this property with NyxxRest");
    }

    return MemberCacheable(
        this.client,
        (client as NyxxWebsocket).self.id,
        GuildCacheable(this.client, this.id)
    );
  }

  /// File upload limit for channel in bytes.
  int get fileUploadLimit {
    const megabyte = 1024 * 1024;

    if (this.premiumTier == PremiumTier.tier2) {
      return 50 * megabyte;
    }

    if (this.premiumTier == PremiumTier.tier3) {
      return 100 * megabyte;
    }

    return 8 * megabyte;
  }

  /// Returns this guilds shard
  IShard get shard {
    if (this.client is! NyxxWebsocket) {
      throw new UnsupportedError("Cannot use this property with NyxxRest");
    }

    return (client as NyxxWebsocket).shardManager.shards.firstWhere((_shard) => _shard.guilds.contains(this.id));
  }

  /// Creates an instance of [Guild]
  Guild(this.client, RawApiMap raw, [bool guildCreate = false]) : super(Snowflake(raw["id"])) {
    this.name = raw["name"] as String;
    this.region = raw["region"] as String;
    this.afkTimeout = raw["afk_timeout"] as int;
    this.mfaLevel = raw["mfa_level"] as int;
    this.verificationLevel = raw["verification_level"] as int;
    this.notificationLevel = raw["default_message_notifications"] as int;

    this.icon = raw["icon"] as String?;
    this.discoverySplash = raw["discoverySplash"] as String?;
    this.splash = raw["splash"] as String?;
    this.embedEnabled = raw["embed_enabled"] as bool?;

    this.systemChannelFlags = raw["system_channel_flags"] as int;
    this.premiumTier = PremiumTier.from(raw["premium_tier"] as int);
    this.premiumSubscriptionCount = raw["premium_subscription_count"] as int?;
    this.preferredLocale = raw["preferred_locale"] as String;

    this.owner = UserCacheable(client, Snowflake(raw["owner_id"]));

    this.roles = const SnowflakeCache<IRole>();
    if (raw["roles"] != null) {
      raw["roles"].forEach((o) {
        final role = Role(client, o as RawApiMap, this.id);
        this.roles[role.id] = role;
      });
    }

    this.emojis = const SnowflakeCache();
    if (raw["emojis"] != null) {
      raw["emojis"].forEach((dynamic o) {
        final emoji = GuildEmoji(client, o as RawApiMap, this.id);
        this.emojis[emoji.id] = emoji;
      });
    }

    if (raw["embed_channel_id"] != null) {
      this.embedChannel = ChannelCacheable(client, Snowflake(raw["embed_channel_id"]));
    }

    if (raw["system_channel_id"] != null) {
      this.systemChannel = ChannelCacheable(client, Snowflake(raw["system_channel_id"]));
    }

    this.features = (raw["features"] as List<dynamic>).map((e) => GuildFeature.from(e.toString()));

    if (raw["permissions"] != null) {
      this.currentUserPermissions = Permissions(raw["permissions"] as int);
    } else {
      this.currentUserPermissions = null;
    }

    if (raw["afk_channel_id"] != null) {
      this.afkChannel = ChannelCacheable(client, Snowflake(raw["afk_channel_id"]));
    }

    this.members = const SnowflakeCache();
    this.voiceStates = const SnowflakeCache();

    this.guildNsfwLevel = GuildNsfwLevel.from(raw["nsfw_level"] as int);

    this.stickers = [
      if (raw["stickers"] != null)
        for (final rawSticker in raw["stickers"])
          GuildSticker(rawSticker as RawApiMap, client)
    ];

    if (!guildCreate) return;

    raw["channels"].forEach((o) {
      final channel = Channel.deserialize(this.client, o as RawApiMap, this.id);
      client.channels[channel.id] = channel;
    });

    if (client.cacheOptions.memberCachePolicyLocation.objectConstructor) {
      raw["members"].forEach((o) {
        final member = Member(client, o as RawApiMap, this.id);
        if (client.cacheOptions.memberCachePolicy.canCache(member)) {
          this.members[member.id] = member;
        }
      });
    }

    if (raw["voice_states"] != null) {
      raw["voice_states"].forEach((o) {
        final state = VoiceState(client, o as RawApiMap);
        this.voiceStates[state.user.id] = state;
      });
    }

    if (raw["rules_channel_id"] != null) {
      this.rulesChannel = ChannelCacheable(client, Snowflake(raw["rules_channel_id"]));
    }

    if (raw["public_updates_channel_id"] != null) {
      this.publicUpdatesChannel = CacheableTextChannel<ITextChannel>(client, Snowflake(raw["public_updates_channel_id"]));
    }

    this.stageInstances = [
      if (raw["stage_instances"] != null)
        for (final rawInstance in raw["stage_instances"])
          StageChannelInstance(this.client, rawInstance as RawApiMap)
    ];
  }

  /// The guild's icon, represented as URL.
  /// If guild doesn't have icon it returns null.
  String? iconURL({String format = "webp", int size = 128}) =>
      client.httpEndpoints.getGuildIconUrl(this.id, this.icon, format, size);

  /// URL to guild's splash.
  /// If guild doesn't have splash it returns null.
  String? splashURL({String format = "webp", int size = 128}) =>
      client.httpEndpoints.getGuildSplashURL(this.id, this.splash, format, size);

  /// URL to guilds discovery splash
  /// If guild doesn't have splash it returns null.
  String? discoveryURL({String format = "webp", int size = 128}) =>
      client.httpEndpoints.getGuildDiscoveryURL(this.id, this.splash, format: format, size: size);

  /// Allows to download [Guild] widget aka advert png
  /// Possible options for [style]: shield (default), banner1, banner2, banner3, banner4
  String guildWidgetUrl([String style = "shield"]) =>
      client.httpEndpoints.getGuildWidgetUrl(this.id, style);

  /// Fetches all stickers of current guild
  Stream<IGuildSticker> fetchStickers() =>
      client.httpEndpoints.fetchGuildStickers(this.id);

  /// Fetch sticker with given [id]
  Future<IGuildSticker> fetchSticker(Snowflake id) =>
      client.httpEndpoints.fetchGuildSticker(this.id, id);

  /// Fetches all roles that are in the server.
  Stream<IRole> fetchRoles() =>
      client.httpEndpoints.fetchGuildRoles(this.id);

  /// Creates sticker in current guild
  Future<IGuildSticker> createSticker(StickerBuilder builder) =>
      client.httpEndpoints.createGuildSticker(this.id, builder);

  /// Fetches emoji from API
  Future<IBaseGuildEmoji> fetchEmoji(Snowflake emojiId) =>
      client.httpEndpoints.fetchGuildEmoji(this.id, emojiId);

  /// Allows to create new guild emoji. [name] is required and you have to specify one of other parameters: [imageFile], [imageBytes] or [encodedImage].
  /// [imageBytes] can be useful if you want to create image from http response.
  ///
  /// ```
  /// var emojiFile = new File("weed.png");
  /// vare emoji = await guild.createEmoji("weed, image: emojiFile");
  /// ```
  Future<IBaseGuildEmoji> createEmoji(String name, {List<SnowflakeEntity>? roles, AttachmentBuilder? emojiAttachment}) =>
      client.httpEndpoints.createEmoji(this.id, name, roles: roles, emojiAttachment: emojiAttachment);

  /// Returns [int] indicating the number of members that would be removed in a prune operation.
  Future<int> pruneCount(int days, {Iterable<Snowflake>? includeRoles}) =>
      client.httpEndpoints.guildPruneCount(this.id, days, includeRoles: includeRoles);

  /// Prunes the guild, returns the amount of members pruned.
  Future<int> prune(int days, {Iterable<Snowflake>? includeRoles, String? auditReason}) =>
      client.httpEndpoints.guildPrune(this.id, days, includeRoles: includeRoles, auditReason: auditReason);

  /// Get"s the guild's bans.
  Stream<IBan> getBans() => client.httpEndpoints.getGuildBans(this.id);

  /// Change self nickname in guild
  Future<void> modifyCurrentMember({String? nick}) async =>
      client.httpEndpoints.modifyCurrentMember(this.id, nick: nick);

  /// Gets single [Ban] object for given [bannedUserId]
  Future<IBan> getBan(Snowflake bannedUserId) async =>
      client.httpEndpoints.getGuildBan(this.id, bannedUserId);

  /// Change guild owner.
  Future<IGuild> changeOwner(SnowflakeEntity memberEntity, {String? auditReason}) =>
      client.httpEndpoints.changeGuildOwner(this.id, memberEntity);

  /// Leaves the guild.
  Future<void> leave() async =>
      client.httpEndpoints.leaveGuild(this.id);

  /// Returns list of Guilds invites
  Stream<IInvite> fetchGuildInvites() =>
      client.httpEndpoints.fetchGuildInvites(this.id);

  /// Returns Audit logs.
  /// https://discordapp.com/developers/docs/resources/audit-log
  ///
  /// ```
  /// var logs = await guild.getAuditLogs(actionType: 1);
  /// ```
  Future<IAuditLog> fetchAuditLogs({Snowflake? userId, int? actionType, Snowflake? before, int? limit}) =>
      client.httpEndpoints.fetchAuditLogs(this.id, userId: userId, actionType: actionType, before: before, limit: limit);

  /// Creates new role
  ///
  /// ```
  /// var rb = new RoleBuilder()
  ///   ..name = "Dartyy"
  ///   ..color = DiscordColor.fromInt(0xFF04F2)
  ///   ..hoist = true;
  ///
  /// var role = await guild.createRole(roleBuilder);
  /// ```
  Future<IRole> createRole(RoleBuilder roleBuilder, {String? auditReason}) =>
      client.httpEndpoints.createGuildRole(this.id, roleBuilder, auditReason: auditReason);

  /// Returns list of available [VoiceRegion]s
  Stream<IVoiceRegion> getVoiceRegions() =>
      client.httpEndpoints.fetchGuildVoiceRegions(this.id);

  /// Moves channel
  Future<void> moveChannel(IChannel channel, int position, {String? auditReason}) =>
      client.httpEndpoints.moveGuildChannel(this.id, channel.id, position, auditReason: auditReason);


  /// Bans a user and allows to delete messages from [deleteMessageDays] number of days.
  /// ```
  ///
  /// await guild.ban(member);
  /// ```
  Future<void> ban(SnowflakeEntity user, {int deleteMessageDays = 0, String? auditReason}) =>
      client.httpEndpoints.guildBan(this.id, user.id, deleteMessageDays: deleteMessageDays, auditReason: auditReason);


  /// Kicks user from guild. Member is removed from guild and he is able to rejoin
  ///
  /// ```
  /// await guild.kick(member);
  /// ```
  Future<void> kick(SnowflakeEntity user, {String? auditReason}) =>
      client.httpEndpoints.guildKick(this.id, user.id, auditReason: auditReason);

  /// Unbans a user by ID.
  Future<void> unban(Snowflake id, Snowflake userId) =>
      client.httpEndpoints.guildUnban(this.id, userId);

  /// Edits the guild.
  Future<IGuild> edit(
      {String? name,
        int? verificationLevel,
        int? notificationLevel,
        SnowflakeEntity? afkChannel,
        int? afkTimeout,
        String? icon,
        String? auditReason}) =>
      client.httpEndpoints.editGuild(this.id,
          name: name,
          verificationLevel: verificationLevel,
          notificationLevel: notificationLevel,
          afkChannel: afkChannel,
          afkTimeout: afkTimeout,
          icon: icon,
          auditReason: auditReason
      );

  /// Fetches member from API
  Future<IMember> fetchMember(Snowflake memberId) =>
      client.httpEndpoints.fetchGuildMember(this.id, memberId);

  /// Allows to fetch guild members. In future will be restricted with `Privileged Intents`.
  /// [after] is used to continue from specified user id.
  /// By default limits to one user - use [limit] parameter to change that behavior.
  Stream<IMember> fetchMembers({int limit = 1, Snowflake? after}) =>
      client.httpEndpoints.fetchGuildMembers(this.id, limit: limit, after: after);

  /// Returns a [Stream] of [IMember]s objects whose username or nickname starts with a provided string.
  /// By default limits to one entry - can be changed with [limit] parameter.
  Stream<IMember> searchMembers(String query, {int limit = 1}) =>
      client.httpEndpoints.searchGuildMembers(this.id, query, limit: limit);

  /// Returns a [Stream] of [IMember]s objects whose username or nickname starts with a provided string.
  /// By default limits to one entry - can be changed with [limit] parameter.
  Stream<IMember> searchMembersGateway(String query, {int limit = 0}) async* {
    final nonce = "$query${id.toString()}";
    this.shard.requestMembers(this.id, query: query, limit: limit, nonce: nonce);

    final first = (await this.shard.onMemberChunk.take(1).toList()).first;

    for (final member in first.members) {
      yield member;
    }

    if (first.chunkCount > 1) {
      await for (final event in this.shard.onMemberChunk.where((event) => event.nonce == nonce).take(first.chunkCount - 1)) {
        for (final member in event.members) {
          yield member;
        }
      }
    }
  }

  /// Fetches guild preview for this guild. Allows to download approx member count in guild
  Future<IGuildPreview> fetchGuildPreview() async =>
      this.client.httpEndpoints.fetchGuildPreview(this.id);

  /// Request members from gateway. Requires privileged intents in order to work.
  void requestChunking() => this.shard.requestMembers(this.id);

  /// Allows to create new guild channel
  Future<IChannel> createChannel(ChannelBuilder channelBuilder) =>
    this.client.httpEndpoints.createGuildChannel(this.id, channelBuilder);

  /// Deletes the guild.
  Future<void> delete() =>
      client.httpEndpoints.deleteGuild(this.id);
}
