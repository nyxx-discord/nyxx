part of nyxx;

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
  late Cacheable<Snowflake, VoiceGuildChannel>? afkChannel;

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
  late final Cacheable<Snowflake, TextChannel>? rulesChannel;

  /// The guild owner's ID
  late final Cacheable<Snowflake, User> owner;

  /// The guild's members.
  late final Cache<Snowflake, Member> members;

  /// The guild's channels.
  Iterable<GuildChannel> get channels => this.client.channels.find((item) => item is GuildChannel && item.guild.id == this.id).cast();

  /// The guild's roles.
  late final Cache<Snowflake, Role> roles;

  /// Guild custom emojis
  late final Cache<Snowflake, IGuildEmoji> emojis;

  /// Boost level of guild
  late final PremiumTier premiumTier;

  /// The number of boosts this server currently has
  late final int? premiumSubscriptionCount;

  /// the preferred locale of a "PUBLIC" guild used
  /// in server discovery and notices from Discord; defaults to "en-US"
  late final String preferredLocale;

  /// the id of the channel where admins and moderators
  /// of "PUBLIC" guilds receive notices from Discord
  late final CacheableTextChannel<TextChannel>? publicUpdatesChannel;

  /// Permission of current(bot) user in this guild
  late final Permissions? currentUserPermissions;

  /// Users state cache
  late final Cache<Snowflake, VoiceState> voiceStates;

  /// Stage instances in the guild
  late final Iterable<StageChannelInstance> stageInstances;

  /// Nsfw level of guild
  late final GuildNsfwLevel guildNsfwLevel;

  /// Returns url to this guild.
  String get url => "https://discordapp.com/channels/${this.id.toString()}";

  /// Getter for @everyone role
  Role get everyoneRole => roles.values.firstWhere((r) => r.name == "@everyone");

  /// Returns member object for bot user
  Member? get selfMember {
    if (this.client is! Nyxx) {
      throw new UnsupportedError("Cannot use this property with NyxxRest");
    }

    return members[(client as Nyxx).self.id];
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
  Shard get shard {
    if (this.client is! Nyxx) {
      throw new UnsupportedError("Cannot use this property with NyxxRest");
    }

    return (client as Nyxx).shardManager.shards.firstWhere((_shard) => _shard.guilds.contains(this.id));
  }

  Guild._new(this.client, Map<String, dynamic> raw, [bool guildCreate = false]) : super(Snowflake(raw["id"])) {
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

    this.owner = _UserCacheable(client, Snowflake(raw["owner_id"]));

    this.roles = _SnowflakeCache<Role>();
    if (raw["roles"] != null) {
      raw["roles"].forEach((o) {
        final role = Role._new(client, o as Map<String, dynamic>, this.id);
        this.roles[role.id] = role;
      });
    }

    this.emojis = _SnowflakeCache();
    if (raw["emojis"] != null) {
      raw["emojis"].forEach((dynamic o) {
        final emoji = GuildEmoji._new(client, o as Map<String, dynamic>, this.id);
        this.emojis[emoji.id] = emoji;
      });
    }

    if (raw["embed_channel_id"] != null) {
      this.embedChannel = _ChannelCacheable(client, Snowflake(raw["embed_channel_id"]));
    }

    if (raw["system_channel_id"] != null) {
      this.systemChannel = _ChannelCacheable(client, Snowflake(raw["system_channel_id"]));
    }

    this.features = (raw["features"] as List<dynamic>).map((e) => GuildFeature.from(e.toString()));

    if (raw["permissions"] != null) {
      this.currentUserPermissions = Permissions.fromInt(raw["permissions"] as int);
    } else {
      this.currentUserPermissions = null;
    }

    if (raw["afk_channel_id"] != null) {
      this.afkChannel = _ChannelCacheable(client, Snowflake(raw["afk_channel_id"]));
    }

    this.members = _SnowflakeCache();
    this.voiceStates = _SnowflakeCache();

    this.guildNsfwLevel = GuildNsfwLevel.from(raw["nsfw_level"] as int);

    if (!guildCreate) return;

    raw["channels"].forEach((o) {
      final channel = IChannel._deserialize(this.client, o as Map<String, dynamic>, this.id);
      client.channels[channel.id] = channel;
    });

    if (client._cacheOptions.memberCachePolicyLocation.objectConstructor) {
      raw["members"].forEach((o) {
        final member = Member._new(client, o as Map<String, dynamic>, this.id);
        if (client._cacheOptions.memberCachePolicy.canCache(member)) {
          this.members[member.id] = member;
        }
      });
    }

    // TODO: do we need that?
    // raw["presences"].forEach((o) {
    //   final member = this.members[Snowflake(o["user"]["id"] as String)];
    //   if (member != null) {
    //     member.status = ClientStatus._deserialize(o["client_status"] as Map<String, dynamic>);
    //
    //     if (o["game"] != null) {
    //       member.presence = Activity._new(o["game"] as Map<String, dynamic>);
    //     }
    //   }
    // });

    if (raw["voice_states"] != null) {
      raw["voice_states"].forEach((o) {
        final state = VoiceState._new(client, o as Map<String, dynamic>);
        this.voiceStates[state.user.id] = state;
      });
    }

    if (raw["rules_channel_id"] != null) {
      this.rulesChannel = _ChannelCacheable(client, Snowflake(raw["rules_channel_id"]));
    }

    if (raw["public_updates_channel_id"] != null) {
      this.publicUpdatesChannel = CacheableTextChannel<TextChannel>._new(client, Snowflake(raw["public_updates_channel_id"]));
    }

    this.stageInstances = [
      if (raw["stage_instances"] != null)
        for (final rawInstance in raw["stage_instances"])
          StageChannelInstance._new(this.client, rawInstance as Map<String, dynamic>)
    ];
  }

  /// The guild's icon, represented as URL.
  /// If guild doesn't have icon it returns null.
  String? iconURL({String format = "webp", int size = 128}) =>
      client._httpEndpoints.getGuildIconUrl(this.id, this.icon, format, size);

  /// URL to guild's splash.
  /// If guild doesn't have splash it returns null.
  String? splashURL({String format = "webp", int size = 128}) =>
      client._httpEndpoints.getGuildSplashURL(this.id, this.splash, format, size);

  /// URL to guilds discovery splash
  /// If guild doesn't have splash it returns null.
  String? discoveryURL({String format = "webp", int size = 128}) =>
      client._httpEndpoints.getGuildDiscoveryURL(this.id, this.splash, format: format, size: size);

  /// Allows to download [Guild] widget aka advert png
  /// Possible options for [style]: shield (default), banner1, banner2, banner3, banner4
  String guildWidgetUrl([String style = "shield"]) =>
      client._httpEndpoints.getGuildWidgetUrl(this.id, style);

  /// Fetches emoji from API
  Future<IGuildEmoji> fetchEmoji(Snowflake emojiId) =>
      client._httpEndpoints.fetchGuildEmoji(this.id, emojiId);

  /// Allows to create new guild emoji. [name] is required and you have to specify one of other parameters: [imageFile], [imageBytes] or [encodedImage].
  /// [imageBytes] can be useful if you want to create image from http response.
  ///
  /// ```
  /// var emojiFile = new File("weed.png");
  /// vare emoji = await guild.createEmoji("weed, image: emojiFile");
  /// ```
  Future<GuildEmoji> createEmoji(String name, {List<SnowflakeEntity>? roles, File? imageFile, List<int>? imageBytes, String? encodedImage, String? encodedExtension}) =>
      client._httpEndpoints.createEmoji(this.id, name, roles: roles, imageFile: imageFile, imageBytes: imageBytes, encodedImage: encodedImage, encodedExtension: encodedExtension);

  /// Returns [int] indicating the number of members that would be removed in a prune operation.
  Future<int> pruneCount(int days, {Iterable<Snowflake>? includeRoles}) =>
      client._httpEndpoints.guildPruneCount(this.id, days, includeRoles: includeRoles);

  /// Prunes the guild, returns the amount of members pruned.
  Future<int> prune(int days, {Iterable<Snowflake>? includeRoles, String? auditReason}) =>
      client._httpEndpoints.guildPrune(this.id, days, includeRoles: includeRoles, auditReason: auditReason);

  /// Get"s the guild's bans.
  Stream<Ban> getBans() => client._httpEndpoints.getGuildBans(this.id);

  /// Change self nickname in guild
  Future<void> changeSelfNick(String nick) async =>
      client._httpEndpoints.changeGuildSelfNick(this.id, nick);

  /// Gets single [Ban] object for given [bannedUserId]
  Future<Ban> getBan(Snowflake bannedUserId) async =>
      client._httpEndpoints.getGuildBan(this.id, bannedUserId);

  /// Change guild owner.
  Future<Guild> changeOwner(SnowflakeEntity memberEntity, {String? auditReason}) =>
      client._httpEndpoints.changeGuildOwner(this.id, memberEntity);

  /// Leaves the guild.
  Future<void> leave() async =>
      client._httpEndpoints.leaveGuild(this.id);

  /// Returns list of Guilds invites
  Stream<Invite> fetchGuildInvites() =>
      client._httpEndpoints.fetchGuildInvites(this.id);

  /// Returns Audit logs.
  /// https://discordapp.com/developers/docs/resources/audit-log
  ///
  /// ```
  /// var logs = await guild.getAuditLogs(actionType: 1);
  /// ```
  Future<AuditLog> fetchAuditLogs({Snowflake? userId, int? actionType, Snowflake? before, int? limit}) =>
      client._httpEndpoints.fetchAuditLogs(this.id, userId: userId, actionType: actionType, before: before, limit: limit);

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
  Future<Role> createRole(RoleBuilder roleBuilder, {String? auditReason}) =>
      client._httpEndpoints.createGuildRole(this.id, roleBuilder, auditReason: auditReason);

  /// Returns list of available [VoiceRegion]s
  Stream<VoiceRegion> getVoiceRegions() =>
      client._httpEndpoints.fetchGuildVoiceRegions(this.id);

  /// Moves channel
  Future<void> moveChannel(IChannel channel, int position, {String? auditReason}) =>
      client._httpEndpoints.moveGuildChannel(this.id, channel.id, position, auditReason: auditReason);


  /// Bans a user and allows to delete messages from [deleteMessageDays] number of days.
  /// ```
  ///
  /// await guild.ban(member);
  /// ```
  Future<void> ban(SnowflakeEntity user, {int deleteMessageDays = 0, String? auditReason}) =>
      client._httpEndpoints.guildBan(this.id, user.id, deleteMessageDays: deleteMessageDays, auditReason: auditReason);


  /// Kicks user from guild. Member is removed from guild and he is able to rejoin
  ///
  /// ```
  /// await guild.kick(member);
  /// ```
  Future<void> kick(SnowflakeEntity user, {String? auditReason}) =>
      client._httpEndpoints.guildKick(this.id, user.id, auditReason: auditReason);

  /// Unbans a user by ID.
  Future<void> unban(Snowflake id, Snowflake userId) =>
      client._httpEndpoints.guildUnban(this.id, userId);

  /// Edits the guild.
  Future<Guild> edit(
      {String? name,
        int? verificationLevel,
        int? notificationLevel,
        SnowflakeEntity? afkChannel,
        int? afkTimeout,
        String? icon,
        String? auditReason}) =>
      client._httpEndpoints.editGuild(this.id,
          name: name,
          verificationLevel: verificationLevel,
          notificationLevel: notificationLevel,
          afkChannel: afkChannel,
          afkTimeout: afkTimeout,
          icon: icon,
          auditReason: auditReason
      );

  /// Fetches member from API
  Future<Member> fetchMember(Snowflake memberId) =>
      client._httpEndpoints.fetchGuildMember(this.id, memberId);

  /// Allows to fetch guild members. In future will be restricted with `Privileged Intents`.
  /// [after] is used to continue from specified user id.
  /// By default limits to one user - use [limit] parameter to change that behavior.
  Stream<Member> fetchMembers({int limit = 1, Snowflake? after}) =>
      client._httpEndpoints.fetchGuildMembers(this.id, limit: limit, after: after);

  /// Returns a [Stream] of [Member]s objects whose username or nickname starts with a provided string.
  /// By default limits to one entry - can be changed with [limit] parameter.
  Stream<Member> searchMembers(String query, {int limit = 1}) =>
      client._httpEndpoints.searchGuildMembers(this.id, query, limit: limit);

  /// Returns a [Stream] of [Member]s objects whose username or nickname starts with a provided string.
  /// By default limits to one entry - can be changed with [limit] parameter.
  Stream<Member> searchMembersGateway(String query, {int limit = 0}) async* {
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
  Future<GuildPreview> fetchGuildPreview() async =>
      this.client.httpEndpoints.fetchGuildPreview(this.id);

  /// Request members from gateway. Requires privileged intents in order to work.
  void requestChunking() => this.shard.requestMembers(this.id);

  /// Allows to create new guild channel
  Future<IChannel> createChannel(ChannelBuilder channelBuilder) =>
    this.client.httpEndpoints.createGuildChannel(this.id, channelBuilder);

  /// Deletes the guild.
  Future<void> delete() =>
      client._httpEndpoints.deleteGuild(this.id);
}
