part of nyxx;

/// [Guild] object represents single `Discord Server`.
/// Guilds are a collection of members, channels, and roles that represents one community.
///
/// ---------
///
/// [channels] property is Map of [Channel]s but it can be cast to specific Channel subclasses. Example with getting all [CachelessTextChannel]s in [Guild]:
/// ```
/// var textChannels = channels.where((channel) => channel is MessageChannel) as List<TextChannel>;
/// ```
/// If you want to get [icon] or [splash] of [Guild] use `iconURL()` method - [icon] property returns only hash, same as [splash] property.
class Guild extends SnowflakeEntity implements Disposable {
  /// Reference to [Nyxx] instance
  Nyxx client;

  /// The guild's name.
  late final String name;

  /// The guild's icon hash.
  late String? icon;

  /// Splash hash
  late String? splash;

  /// Discovery splash hash
  late String? discoverySplash;

  /// System channel where system messages are sent
  late final CachelessTextChannel? systemChannel;

  /// enabled guild features
  late final List<String> features;

  /// The guild's afk channel ID, null if not set.
  late CacheVoiceChannel? afkChannel;

  /// The guild's voice region.
  late String region;

  /// The channel ID for the guild's widget if enabled.
  late final CacheGuildChannel? embedChannel;

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
  late final CacheGuildChannel? rulesChannel;

  /// The guild owner's ID
  late final User? owner;

  /// The guild's members.
  late final Cache<Snowflake, Member> members;

  /// The guild's channels.
  late final ChannelCache channels;

  /// The guild's roles.
  late final Cache<Snowflake, Role> roles;

  /// Guild custom emojis
  late final Cache<Snowflake, GuildEmoji> emojis;

  /// Boost level of guild
  late final PremiumTier premiumTier;

  /// The number of boosts this server currently has
  late final int? premiumSubscriptionCount;

  /// the preferred locale of a "PUBLIC" guild used
  /// in server discovery and notices from Discord; defaults to "en-US"
  late final String preferredLocale;

  /// the id of the channel where admins and moderators
  /// of "PUBLIC" guilds receive notices from Discord
  late final CacheGuildChannel? publicUpdatesChannel;

  /// Permission of current(bot) user in this guild
  Permissions? currentUserPermissions;

  /// Users state cache
  late final Cache<Snowflake, VoiceState> voiceStates;

  /// Returns url to this guild.
  String get url => "https://discordapp.com/channels/${this.id.toString()}";

  /// Getter for @everyone role
  Role get everyoneRole => roles.values.firstWhere((r) => r.name == "@everyone");

  /// Returns member object for bot user
  Member? get selfMember => members[client.self.id];

  /// Upload limit for this guild in bytes
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

  Guild._new(this.client, Map<String, dynamic> raw, [this.available = true, bool guildCreate = false])
      : super(Snowflake(raw["id"] as String)) {
    if (!this.available) return;

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

    this.channels = ChannelCache._new();

    if (raw["roles"] != null) {
      this.roles = _SnowflakeCache<Role>();
      raw["roles"].forEach((o) {
        final role = Role._new(o as Map<String, dynamic>, this, client);
        this.roles[role.id] = role;
      });
    }

    this.emojis = _SnowflakeCache();
    if (raw["emojis"] != null) {
      raw["emojis"].forEach((dynamic o) {
        final emoji = GuildEmoji._new(o as Map<String, dynamic>, this, client);
        this.emojis[emoji.id] = emoji;
      });
    }

    if (raw.containsKey("embed_channel_id")) {
      this.embedChannel = client.channels[Snowflake(raw["embed_channel_id"])] as CacheGuildChannel;
    }

    if (raw["system_channel_id"] != null) {
      final id = Snowflake(raw["system_channel_id"] as String);
      if (this.channels.hasKey(id)) {
        this.systemChannel = this.channels[id] as CachelessTextChannel;
      }
    }

    this.features = (raw["features"] as List<dynamic>).cast<String>();

    if (raw["permissions"] != null) {
      this.currentUserPermissions = Permissions.fromInt(raw["permissions"] as int);
    }

    if (raw["afk_channel_id"] != null) {
      final id = Snowflake(raw["afk_channel_id"] as String);
      if (this.channels.hasKey(id)) {
        this.afkChannel = this.channels[id] as CacheVoiceChannel;
      }
    }

    this.systemChannelFlags = raw["system_channel_flags"] as int;
    this.premiumTier = PremiumTier.from(raw["premium_tier"] as int);
    this.premiumSubscriptionCount = raw["premium_subscription_count"] as int?;
    this.preferredLocale = raw["preferred_locale"] as String;

    this.members = _SnowflakeCache();

    if (!guildCreate) return;

    raw["channels"].forEach((o) {
      final channel = Channel._deserialize(o as Map<String, dynamic>, this.client, this);

      this.channels[channel.id] = channel;
      client.channels[channel.id] = channel;
    });

    if (client._options.cacheMembers) {
      raw["members"].forEach((o) {
        final member = Member._standard(o as Map<String, dynamic>, this, client);
        this.members[member.id] = member;
        client.users[member.id] = member;
      });
    }

    raw["presences"].forEach((o) {
      final member = this.members[Snowflake(o["user"]["id"] as String)];
      if (member != null) {
        member.status = ClientStatus._deserialize(o["client_status"] as Map<String, dynamic>);

        if (o["game"] != null) {
          member.presence = Activity._new(o["game"] as Map<String, dynamic>);
        }
      }
    });

    this.owner = this.members[Snowflake(raw["owner_id"] as String)];

    this.voiceStates = _SnowflakeCache();
    if (raw["voice_states"] != null) {
      raw["voice_states"].forEach((o) {
        final state = VoiceState._new(o as Map<String, dynamic>, client, this);

        if (state.user != null) this.voiceStates[state.user!.id] = state;
      });
    }

    if (raw["rules_channel_id"] != null) {
      this.rulesChannel = this.channels[Snowflake(raw["rules_channel_id"])] as CacheGuildChannel?;
    }

    if (raw["public_updates_channel_id"] != null) {
      this.publicUpdatesChannel = this.channels[Snowflake(raw["public_updates_channel_id"])] as CacheGuildChannel?;
    }
  }

  /// The guild"s icon, represented as URL.
  /// If guild doesn"t have icon it returns null.
  String? iconURL({String format = "webp", int size = 128}) {
    if (this.icon != null) return "https://cdn.${Constants.cdnHost}/icons/${this.id}/${this.icon}.$format?size=$size";

    return null;
  }

  /// URL to guild"s splash.
  /// If guild doesn"t have splash it returns null.
  String? splashURL({String format = "webp", int size = 128}) {
    if (this.splash != null) {
      return "https://cdn.${Constants.cdnHost}/splashes/${this.id}/${this.splash}.$format?size=$size";
    }

    return null;
  }

  /// URL to guild"s splash.
  /// If guild doesn"t have splash it returns null.
  String? discoveryURL({String format = "webp", int size = 128}) {
    if (this.splash != null) {
      return "https://cdn.${Constants.cdnHost}/discovery-splashes/${this.id}/${this.splash}.$format?size=$size";
    }

    return null;
  }

  /// Allows to download [Guild] widget aka advert png
  /// Possible options for [style]: shield (default), banner1, banner2, banner3, banner4
  String guildWidgetUrl([String style = "shield"]) =>
    "http://cdn.${Constants.cdnHost}/guilds/${this.id.toString()}/widget.png?style=$style";

  /// Returns a string representation of this object - Guild name.
  @override
  String toString() => this.name;

  /// Gets Guild Emoji based on Id
  ///
  /// ```
  /// var emoji = await guild.getEmoji(Snowflake("461449676218957824"));
  /// ```
  Future<GuildEmoji> getEmoji(Snowflake emojiId, [bool useCache = true]) async {
    if (emojis.hasKey(emojiId) && useCache) return emojis[emojiId] as GuildEmoji;

    final response = await client._http._execute(BasicRequest._new("/guilds/$id/emojis/${emojiId.toString()}"));

    if (response is HttpResponseSuccess) {
      return GuildEmoji._new(response.jsonBody as Map<String, dynamic>, this, client);
    }

    return Future.error(response);
  }

  /// Allows to create new guild emoji. [name] is required and you have to specify one of two other parameters: [image] or [imageBytes].
  /// [imageBytes] can be useful if you want to create image from http response.
  ///
  /// ```
  /// var emojiFile = new File("weed.png");
  /// vare emoji = await guild.createEmoji("weed, image: emojiFile");
  /// ```
  Future<GuildEmoji> createEmoji(String name, {List<Role>? roles, File? image, List<int>? imageBytes}) async {
    if (image != null && await image.length() > 256000) {
      return Future.error("Emojis and animated emojis have a maximum file size of 256kb.");
    }

    if (image == null && imageBytes == null) {
      return Future.error("Both imageData and file fields cannot be null");
    }

    final body = <String, dynamic>{
      "name": name,
      "image": base64.encode(image == null ? imageBytes! : await image.readAsBytes()),
      if (roles != null) "roles": roles.map((r) => r.id.toString())
    };

    final response = await client._http
        ._execute(BasicRequest._new("/guilds/${this.id.toString()}/emojis", method: "POST", body: body));

    if (response is HttpResponseSuccess) {
      return GuildEmoji._new(response.jsonBody as Map<String, dynamic>, this, client);
    }

    return Future.error(response);
  }

  /// Returns [int] indicating the number of members that would be removed in a prune operation.
  Future<int> pruneCount(int days, {Iterable<Snowflake>? includeRoles}) async {
    final response = await client._http._execute(BasicRequest._new("/guilds/$id/prune", queryParams: {
      "days": days.toString(),
      if (includeRoles != null) "include_roles": includeRoles.map((e) => e.id.toString())
    }));

    if (response is HttpResponseSuccess) {
      return response.jsonBody["pruned"] as int;
    }

    return Future.error(response);
  }

  /// Prunes the guild, returns the amount of members pruned.
  /// https://discordapp.com/developers/docs/resources/guild#get-guild-prune-count
  Future<int> prune(int days, {Iterable<Snowflake>? includeRoles, String? auditReason}) async {
    final response = await client._http._execute(BasicRequest._new("/guilds/$id/prune",
        method: "POST",
        auditLog: auditReason,
        queryParams: {
          "days": days.toString(),
          if (includeRoles != null) "include_roles": includeRoles.map((e) => e.id.toString())
        }));

    if (response is HttpResponseSuccess) {
      return response.jsonBody["pruned"] as int;
    }

    return Future.error(response);
  }

  /// Get"s the guild's bans.
  Stream<Ban> getBans() async* {
    final response = await client._http._execute(BasicRequest._new("/guilds/$id/bans"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final obj in (response as HttpResponseSuccess).jsonBody) {
      yield Ban._new(obj as Map<String, dynamic>, client);
    }
  }

  /// Change self nickname in guild
  Future<void> changeSelfNick(String nick) async =>
    client._http._execute(
        BasicRequest._new("/guilds/${this.id.toString()}/members/@me/nick", method: "PATCH", body: {"nick": nick}));

  /// Gets single [Ban] object for given [id]
  Future<Ban> getBan(Snowflake id) async {
    final response = await client._http._execute(BasicRequest._new("/guilds/${this.id.toString()}/bans/${id.toString()}"));

    if (response is HttpResponseSuccess) {
      return Ban._new(response.jsonBody as Map<String, dynamic>, client);
    }

    return Future.error(response);
  }

  /// Change guild owner.
  Future<Guild> changeOwner(Member member, {String? auditReason}) async {
    final response = await client._http._execute(
        BasicRequest._new("/guilds/$id", method: "PATCH", auditLog: auditReason, body: {"owner_id": member.id}));

    if (response is HttpResponseSuccess) {
      return Guild._new(client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }

  /// Leaves the guild.
  Future<void> leave() async =>
    client._http._execute(BasicRequest._new("/users/@me/guilds/$id", method: "DELETE"));

  /// Creates invite in first channel possible
  Future<Invite> createInvite({int maxAge = 0, int maxUses = 0, bool temporary = false, bool unique = false, String? auditReason}) async {
    final channel = this.channels.first as CacheGuildChannel?;

    if (channel == null) {
      return Future.error("Cannot get any channel to create invite to");
    }

    return channel.createInvite(
        maxUses: maxUses, maxAge: maxAge, temporary: temporary, unique: unique, auditReason: auditReason);
  }

  /// Returns list of Guilds invites
  Stream<Invite> getGuildInvites() async* {
    final response = await client._http._execute(BasicRequest._new("/guilds/$id/invites"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final raw in (response as HttpResponseSuccess).jsonBody) {
      yield Invite._new(raw as Map<String, dynamic>, client);
    }
  }

  /// Returns Audit logs.
  /// https://discordapp.com/developers/docs/resources/audit-log
  ///
  /// ```
  /// var logs = await guild.getAuditLogs(actionType: 1);
  /// ```
  Future<AuditLog> getAuditLogs({Snowflake? userId, int? actionType, Snowflake? before, int? limit}) async {
    final queryParams = <String, String>{
      if (userId != null) "user_id": userId.toString(),
      if (actionType != null) "action_type": actionType.toString(),
      if (before != null) "before": before.toString(),
      if (limit != null) "limit": limit.toString()
    };

    final response = await client._http._execute(BasicRequest._new("/guilds/${this.id}/audit-logs", queryParams: queryParams));

    if (response is HttpResponseSuccess) {
      return AuditLog._new(response.jsonBody as Map<String, dynamic>, client);
    }

    return Future.error(response);
  }

  /// Get Guild"s embed object
  Future<Embed> getGuildEmbed() async {
    final response = await client._http._execute(BasicRequest._new("/guilds/$id/embed"));

    if (response is HttpResponseSuccess) {
      return Embed._new(response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }

  /// Modify guild embed object
  Future<Embed> editGuildEmbed(EmbedBuilder embed, {String? auditReason}) async {
    final response = await client._http
        ._execute(BasicRequest._new("/guilds/$id/embed", method: "PATCH", auditLog: auditReason, body: embed._build()));

    if (response is HttpResponseSuccess) {
      return Embed._new(response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }

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
  Future<Role> createRole(RoleBuilder roleBuilder, {String? auditReason}) async {
    final response = await client._http._execute(
        BasicRequest._new("/guilds/$id/roles", method: "POST", auditLog: auditReason, body: roleBuilder._build()));

    if (response is HttpResponseSuccess) {
      return Role._new(response.jsonBody as Map<String, dynamic>, this, client);
    }

    return Future.error(response);
  }

  /// Adds [Role] to [Member]
  ///
  /// ```
  /// var role = guild.roles.values.first;
  /// var mem = guild.members.values.first;
  ///
  /// await guild.addRoleToMember(member, role);
  /// ```
  Future<void> addRoleToMember(Member user, Role role) async =>
    client._http._execute(BasicRequest._new("/guilds/$id/members/${user.id}/roles/${role.id}", method: "PUT"));

  /// Returns list of available [CacheVoiceChannel]s
  Stream<VoiceRegion> getVoiceRegions() async* {
    final response = await client._http._execute(BasicRequest._new("/guilds/$id/regions"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final raw in (response as HttpResponseSuccess).jsonBody) {
      yield VoiceRegion._new(raw as Map<String, dynamic>);
    }
  }

  /// Creates a channel. Returns null when [type] is DM or GroupDM.
  /// Also can be null if [type] is Guild Group channel and parent is specified.
  ///
  /// ```
  /// var chan = await guild.createChannel("Super duper channel", ChannelType.text, nsfw: true);
  /// ```
  Future<CacheGuildChannel> createChannel(String name, ChannelType type,
      {int? bitrate,
      String? topic,
      CategoryChannel? parent,
      bool? nsfw,
      int? userLimit,
      PermissionsBuilder? permissions,
      String? auditReason}) async {
    // Checks to avoid API panic
    if (type == ChannelType.dm || type == ChannelType.groupDm) {
      return Future.error("Cannot create DM channel.");
    }

    if (type == ChannelType.category && parent != null) {
      return Future.error("Cannot create Category Channel which have parent channel.");
    }

    // Construct body
    final body = <String, dynamic>{
      "name": name,
      "type": type._value,
      if (bitrate != null) "bitrate": bitrate,
      if (topic != null) "topic": topic,
      if (parent != null) "parent_id": parent.id.toString(),
      if (nsfw != null) "nsfw": nsfw,
      if (userLimit != null) "user_limit": userLimit,
      if (permissions != null) "permission_overwrites": permissions
    };

    final response = await client._http
        ._execute(BasicRequest._new("/guilds/$id/channels", method: "POST", body: body, auditLog: auditReason));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    final raw = (response as HttpResponseSuccess).jsonBody as Map<String, dynamic>;

    return Channel._deserialize(raw, this.client, this) as CacheGuildChannel;
  }

  /// Moves channel. Allows to move channel by absolute about with [absolute] or relatively with [relative] parameter.
  ///
  /// ```
  /// // This moves channel 2 places up
  /// await guild.moveChannel(chan, relative: -2);
  /// ```
  Future<void> moveChannel(CacheGuildChannel channel, {int? absolute, int? relative, String? auditReason}) async {
    var newPosition = 0;

    if (relative != null) {
      newPosition = channel.position + relative;
    } else if (absolute != null) {
      newPosition = absolute;
    } else {
      return Future.error("Cannot move channel by zero places");
    }

    return client._http._execute(BasicRequest._new("/guilds/${this.id}/channels",
        method: "PATCH", auditLog: auditReason, body: {"id": channel.id.toString(), "position": newPosition}));
  }

  /// Bans a user and allows to delete messages from [deleteMessageDays] number of days.
  /// ```
  ///
  /// await guild.ban(member);
  /// ```
  Future<void> ban(Member member, {int deleteMessageDays = 0, String? auditReason}) async =>
    client._http._execute(BasicRequest._new("/guilds/${this.id}/bans/${member.id.toString()}",
        method: "PUT", auditLog: auditReason, body: {"delete-message-days": deleteMessageDays}));

  /// Kicks user from guild. Member is removed from guild and he is able to rejoin
  ///
  /// ```
  /// await guild.kick(member);
  /// ```
  Future<void> kick(Member member, {String? auditReason}) async =>
    client._http._execute(BasicRequest._new("/guilds/${this.id.toString()}/members/${member.id.toString()}",
        method: "DELTE", auditLog: auditReason));

  /// Unbans a user by ID.
  Future<void> unban(Snowflake id) async =>
    client._http._execute(BasicRequest._new("/guilds/${this.id}/bans/${id.toString()}", method: "DELETE"));

  /// Edits the guild.
  Future<Guild> edit(
      {String? name,
      int? verificationLevel,
      int? notificationLevel,
      CacheVoiceChannel? afkChannel,
      int? afkTimeout,
      String? icon,
      String? auditReason}) async {
    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (verificationLevel != null) "verification_level": verificationLevel,
      if (notificationLevel != null) "default_message_notifications": notificationLevel,
      if (afkChannel != null) "afk_channel_id": afkChannel,
      if (afkTimeout != null) "afk_timeout": afkTimeout,
      if (icon != null) "icon": icon
    };

    final response = await client._http
        ._execute(BasicRequest._new("/guilds/${this.id}", method: "PATCH", auditLog: auditReason, body: body));

    if (response is HttpResponseSuccess) {
      return Guild._new(client, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }

  /// Gets a [Member] object. Caches fetched member if not cached.
  ///
  /// ```
  /// var member = guild.getMember(user);
  /// ```
  Future<Member> getMember(User user) async => getMemberById(user.id);

  /// Gets a [Member] object by id. Caches fetched member if not cached.
  ///
  /// ```
  /// var member = guild.getMember(Snowflake("302359795648954380"));
  /// ```
  Future<Member> getMemberById(Snowflake id) async {
    if (this.members.hasKey(id)) {
      return this.members[id] as Member;
    }

    final response = await client._http._execute(BasicRequest._new("/guilds/${this.id}/members/${id.toString()}"));

    if (response is HttpResponseSuccess) {
      return Member._standard(response.jsonBody as Map<String, dynamic>, this, client);
    }

    return Future.error(response);
  }

  /// Allows to fetch guild members. In future will be restricted with `Priviliged Intents`.
  /// [after] is used to continue from specified user id.
  /// By default limits to one user - use [limit] paramter to change that behavior.
  Stream<Member> getMembers({int limit = 1, Snowflake? after}) async* {
    final request = this.client._http._execute(BasicRequest._new("/guilds/${this.id.toString()}/members",
        queryParams: {"limit": limit.toString(), if (after != null) "after": after.toString()}));

    if (request is HttpResponseError) {
      yield* Stream.error(request);
    }

    for (final rawMember in (request as HttpResponseSuccess).jsonBody as List<dynamic>) {
      yield Member._standard(rawMember as Map<String, dynamic>, this, client);
    }
  }

  /// Returns a [Stream] of [Member] objects whose username or nickname starts with a provided string.
  /// By default limits to one entry - can be changed with [limit] parameter.
  Stream<Member> searchMembers(String query, {int limit = 1}) async* {
    final response = await client._http._execute(BasicRequest._new("/guilds/${this.id}/members/search",
        queryParams: {"query": query, "limit": limit.toString()}));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final Map<String, dynamic> member in (response as HttpResponseSuccess).jsonBody) {
      yield Member._standard(member, this, client);
    }
  }

  /// Returns a [Stream] of [Member] objects whose username or nickname starts with a provided string.
  /// By default limits to one entry - can be changed with [limit] parameter.
  Stream<Member> searchMembersGateway(String query, {int limit = 0}) async* {
    final nonce = "$query${id.toString()}";

    this.client.shard.requestMembers(this.id, query: query, limit: limit, nonce: nonce);

    final first = (await this.client.shard.onMemberChunk.take(1).toList()).first;

    for (final member in first.members) {
      yield member;
    }

    if (first.chunkCount > 1) {
      await for (final event in this.client.shard.onMemberChunk.where((event) => event.nonce == nonce).take(first.chunkCount - 1)) {
        for (final member in event.members) {
          yield member;
        }
      }
    }
  }

  /// Gets all of the webhooks for this channel.
  Stream<Webhook> getWebhooks() async* {
    final response = await client._http._execute(BasicRequest._new("/channels/$id/webhooks"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final raw in (response as HttpResponseSuccess).jsonBody.values) {
      yield Webhook._new(raw as Map<String, dynamic>, client);
    }
  }

  /// Deletes the guild.
  Future<void> delete() async =>
    client._http._execute(BasicRequest._new("/guilds/${this.id}", method: "DELETE"));

  @override
  Future<void> dispose() async {
    await channels.dispose();
    await members.dispose();
    await roles.dispose();
    await emojis.dispose();
    await voiceStates.dispose();
  }
}
