part of nyxx;

/// [Guild] object represents single `Discord Server`.
/// Guilds are a collection of members, channels, and roles that represents one community.
///
/// ---------
///
/// [channels] property is Map of [Channel]s but it can be cast to specific Channel subclasses. Example with getting all [TextChannel]s in [Guild]:
/// ```
/// var textChannels = channels.where((channel) => channel is MessageChannel) as List<TextChannel>;
/// ```
/// If you want to get [icon] or [splash] of [Guild] use `iconURL()` method - [icon] property returns only hash, same as [splash] property.
class Guild extends SnowflakeEntity implements Disposable {
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
  late final TextChannel? systemChannel;

  /// enabled guild features
  late final List<String> features;

  /// The guild's afk channel ID, null if not set.
  late VoiceChannel? afkChannel;

  /// The guild's voice region.
  late String region;

  /// The channel ID for the guild's widget if enabled.
  late final GuildChannel? embedChannel;

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
  late final GuildChannel? rulesChannel;

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
  late final GuildChannel? publicUpdatesChannel;

  /// Permission of current(bot) user in this guild
  Permissions? currentUserPermissions;

  /// Users state cache
  late final Cache<Snowflake, VoiceState> voiceStates;

  /// Returns url to this guild.
  String get url => "https://discordapp.com/channels/${this.id.toString()}";

  Role get everyoneRole =>
      roles.values.firstWhere((r) => r.name == "@everyone");

  /// Returns member object for bot user
  Member? get selfMember => members[client.self.id];

  Guild._new(this.client, Map<String, dynamic> raw,
      [this.available = true, bool guildCreate = false])
      : super(Snowflake(raw['id'] as String)) {
    if (!this.available) return;

    this.name = raw['name'] as String;
    this.region = raw['region'] as String;
    this.afkTimeout = raw['afk_timeout'] as int;
    this.mfaLevel = raw['mfa_level'] as int;
    this.verificationLevel = raw['verification_level'] as int;
    this.notificationLevel = raw['default_message_notifications'] as int;

    this.icon = raw['icon'] as String?;
    this.discoverySplash = raw['discoverySplash'] as String?;
    this.splash = raw['splash'] as String?;
    this.embedEnabled = raw['embed_enabled'] as bool?;

    if (raw['roles'] != null) {
      this.roles = _SnowflakeCache<Role>();
      raw['roles'].forEach((o) {
        var role = Role._new(o as Map<String, dynamic>, this, client);
        this.roles[role.id] = role;
      });
    }

    if (raw['emojis'] != null) {
      this.emojis = _SnowflakeCache();
      raw['emojis'].forEach((dynamic o) {
        var emoji = GuildEmoji._new(o as Map<String, dynamic>, this, client);
        this.emojis[emoji.id] = emoji;
      });
    }

    if (raw.containsKey('embed_channel_id'))
      this.embedChannel =
          client.channels[Snowflake(raw['embed_channel_id'] as String)]
              as GuildChannel;

    if (raw['system_channel_id'] != null) {
      var snow = Snowflake(raw['system_channel_id'] as String);
      if (this.channels.hasKey(snow))
        this.systemChannel = this.channels[snow] as TextChannel;
    }

    this.features = (raw['features'] as List<dynamic>).cast<String>();

    if (raw['permissions'] != null) {
      this.currentUserPermissions =
          Permissions.fromInt(raw['permissions'] as int);
    }

    if (raw['afk_channel_id'] != null) {
      var snow = Snowflake(raw['afk_channel_id'] as String);
      if (this.channels.hasKey(snow))
        this.afkChannel = this.channels[snow] as VoiceChannel;
    }

    this.systemChannelFlags = raw['system_channel_flags'] as int;
    this.premiumTier = PremiumTier.from(raw['premium_tier'] as int);
    this.premiumSubscriptionCount = raw['premium_subscription_count'] as int?;
    this.preferredLocale =  raw['preferred_locale'] as String;

    if (!guildCreate) return;

    this.channels = ChannelCache._new();
    raw['channels'].forEach((o) {
      late GuildChannel channel;

      if (o['type'] == 0 || o['type'] == 5 || o['type'] == 6)
        channel = TextChannel._new(o as Map<String, dynamic>, this, client);
      else if (o['type'] == 2)
        channel = VoiceChannel._new(o as Map<String, dynamic>, this, client);
      else if (o['type'] == 4)
        channel = CategoryChannel._new(o as Map<String, dynamic>, this, client);

      this.channels[channel.id] = channel;
      client.channels[channel.id] = channel;
    });

    this.members = _SnowflakeCache();
    if (client._options.cacheMembers) {
      raw['members'].forEach((o) {
        final member = _StandardMember(o as Map<String, dynamic>, this, client);
        this.members[member.id] = member;
        client.users[member.id] = member;
      });
    }

    raw['presences'].forEach((o) {
      var member = this.members[Snowflake(o['user']['id'] as String)];
      if (member != null) {
        member.status = ClientStatus._new(
            MemberStatus.from(o['client_status']['desktop'] as String),
            MemberStatus.from(o['client_status']['web'] as String),
            MemberStatus.from(o['client_status']['mobile'] as String));
        if (o['game'] != null) {
          member.presence = Presence._new(o['game'] as Map<String, dynamic>);
        }
      }
    });

    this.owner = this.members[Snowflake(raw['owner_id'] as String)];

    this.voiceStates = _SnowflakeCache();
    if (raw['voice_states'] != null) {
      raw['voice_states'].forEach((o) {
        var state = VoiceState._new(o as Map<String, dynamic>, client, this);

        if (state.user != null)
          this.voiceStates[state.user!.id] = state;
      });
    }

    if(raw['rules_channel_id'] != null) {
      this.rulesChannel = this.channels[Snowflake(raw['rules_channel_id'])] as GuildChannel?;
    }

    if(raw['public_updates_channel_id'] != null) {
      this.publicUpdatesChannel = this.channels[Snowflake(raw['public_updates_channel_id'])] as GuildChannel?;
    }
  }

  /// The guild's icon, represented as URL.
  /// If guild doesn't have icon it returns null.
  String? iconURL({String format = 'webp', int size = 128}) {
    if (this.icon != null)
      return 'https://cdn.${_Constants.host}/icons/${this.id}/${this.icon}.$format?size=$size';

    return null;
  }

  /// URL to guild's splash.
  /// If guild doesn't have splash it returns null.
  String? splashURL({String format = 'webp', int size = 128}) {
    if (this.splash != null)
      return 'https://cdn.${_Constants.host}/splashes/${this.id}/${this.splash}.$format?size=$size';

    return null;
  }

  /// Returns a string representation of this object - Guild name.
  @override
  String toString() => this.name;

  /// Gets Guild Emoji based on Id
  ///
  /// ```
  /// var emoji = await guild.getEmoji(Snowflake("461449676218957824"));
  /// ```
  Future<GuildEmoji> getEmoji(Snowflake emojiId) async {
    if (emojis.hasKey(emojiId)) return emojis[emojiId] as GuildEmoji;

    HttpResponse r = await client._http
        .send('GET', "/guilds/$id/emojis/${emojiId.toString()}");

    return GuildEmoji._new(r.body as Map<String, dynamic>, this, client);
  }

  /// Allows to create new guild emoji. [name] is required and you have to specify one of two other parameters: [image] or [imageBytes].
  /// [imageBytes] can be useful if you want to create image from http response.
  ///
  /// ```
  /// var emojiFile = new File('weed.png');
  /// vare emoji = await guild.createEmoji("weed, image: emojiFile");
  /// ```
  Future<GuildEmoji> createEmoji(String name,
      {List<Role>? roles, File? image, List<int>? imageBytes}) async {
    if (image != null && await image.length() > 256000)
      return Future.error(
          "Emojis and animated emojis have a maximum file size of 256kb.");

    var encoded =
        base64.encode(image == null ? imageBytes : await image.readAsBytes());
    var res = await client._http
        .send("POST", "/guilds/${this.id.toString()}/emojis", body: {
      "name": name,
      "image": encoded,
      "roles": roles != null ? roles.map((r) => r.id.toString()) : ""
    });

    return GuildEmoji._new(res.body as Map<String, dynamic>, this, client);
  }

  /// Allows to download [Guild] widget aka advert png
  /// Possible options for [style]: shield (default), banner1, banner2, banner3, banner4
  Future<List<int>> downloadGuildWidget([String style = "shield"]) async {
    return DownloadUtils.downloadAsBytes(Uri.parse(
        "${_Constants.host}${_Constants.baseUri}/guilds/${this.id.toString()}/widget.png?style=${style}"));
  }

  /// Returns [int] indicating the number of members that would be removed in a prune operation.
  Future<int> pruneCount(int days) async {
    HttpResponse r = await client._http
        .send('GET', "/guilds/$id/prune", body: {"days": days});
    return r.body['pruned'] as int;
  }

  /// Prunes the guild, returns the amount of members pruned.
  /// https://discordapp.com/developers/docs/resources/guild#get-guild-prune-count
  Future<int> prune(int days, {String auditReason = ""}) async {
    HttpResponse r = await client._http.send('POST', "/guilds/$id/prune",
        body: {"days": days}, reason: auditReason);
    return r.body['pruned'] as int;
  }

  /// Get's the guild's bans.
  Future<List<Ban>> getBans() async {
    final r = await client._http.send('GET', "/guilds/$id/bans");

    List<Ban> lst = List();
    r.body.forEach((o) {
      lst.add(Ban._new(o as Map<String, dynamic>, client));
    });

    return lst;
  }

  /// Change self nickname in guild
  Future<void> changeSelfNick(String nick) async {
    await client._http.send(
        "PATCH", "/guilds/${this.id.toString()}/members/@me/nick",
        body: {"nick": nick});
  }

  /// Gets single [Ban] object for given [id]
  Future<Ban> getBan(Snowflake id) async {
    var r = await client._http
        .send("GET", "/guilds/${this.id.toString()}/bans/${id.toString()}");
    return Ban._new(r.body as Map<String, dynamic>, client);
  }

  /// Change guild owner.
  Future<Guild> changeOwner(Member member, {String auditReason = ""}) async {
    HttpResponse r = await client._http.send('PATCH', "/guilds/$id",
        body: {"owner_id": member.id}, reason: auditReason);

    return Guild._new(client, r.body as Map<String, dynamic>);
  }

  /// Leaves the guild.
  Future<void> leave() async {
    await client._http.send('DELETE', "/users/@me/guilds/$id");
  }

  Future<Invite> createInvite(
      {int maxAge = 0,
      int maxUses = 0,
      bool temporary = false,
      bool unique = false,
      String auditReason = ""}) async {
    var chan = this.channels.first as GuildChannel;

    if (chan == null)
      return Future.error("Cannot get any channel to create invite to");

    return chan.createInvite(
        maxUses: maxUses,
        maxAge: maxAge,
        temporary: temporary,
        unique: unique,
        auditReason: auditReason);
  }

  /// Returns list of Guilds invites
  Future<List<Invite>> getGuildInvites() async {
    HttpResponse r = await client._http.send('GET', "/guilds/$id/invites");

    var raw = r.body as List<dynamic>;
    List<Invite> tmp = List();
    raw.forEach((v) {
      tmp.add(Invite._new(v as Map<String, dynamic>, client));
    });

    return tmp;
  }

  /// Returns Audit logs.
  /// https://discordapp.com/developers/docs/resources/audit-log
  ///
  /// ```
  /// var logs = await guild.getAuditLogs(actionType: 1);
  /// ```
  Future<AuditLog> getAuditLogs(
      {Snowflake? userId,
      int? actionType,
      Snowflake? before,
      int limit = 50}) async {
    var query = Map<String, String>();
    if (userId != null) query['user_id'] = userId.toString();
    if (actionType != null) query['action_type'] = actionType.toString();
    if (before != null) query['before'] = before.toString();
    query['limit'] = limit.toString();

    HttpResponse r = await client._http
        .send('GET', '/guilds/${this.id}/audit-logs', queryParams: query);

    return AuditLog._new(r.body as Map<String, dynamic>, client);
  }

  /// Get Guild's embed object
  Future<Embed> getGuildEmbed() async {
    HttpResponse r = await client._http.send('GET', "/guilds/$id/embed");
    return Embed._new(r.body as Map<String, dynamic>);
  }

  /// Modify guild embed object
  Future<Embed> editGuildEmbed(EmbedBuilder embed,
      {String auditReason = ""}) async {
    HttpResponse r = await client._http.send('PATCH', "/guilds/$id/embed",
        body: embed._build(), reason: auditReason);
    return Embed._new(r.body as Map<String, dynamic>);
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
  Future<Role> createRole(RoleBuilder roleBuilder,
      {String auditReason = ""}) async {
    HttpResponse r = await client._http.send('POST', "/guilds/$id/roles",
        body: roleBuilder._build(), reason: auditReason);
    return Role._new(r.body as Map<String, dynamic>, this, client);
  }

  /// Adds [Role] to [Member]
  ///
  /// ```
  /// var role = guild.roles.values.first;
  /// var mem = guild.members.values.first;
  ///
  /// await guild.addRoleToMember(member, role);
  /// ```
  Future<void> addRoleToMember(Member user, Role role) async {
    await client._http
        .send('PUT', '/guilds/$id/members/${user.id}/roles/${role.id}');
  }

  /// Returns list of available [VoiceChannel]s
  Future<List<VoiceRegion>> getVoiceRegions() async {
    var r = await client._http.send('GET', "/guilds/$id/regions");

    var raw = r.body as List<dynamic>;
    List<VoiceRegion> tmp = List();
    raw.forEach((v) {
      tmp.add(VoiceRegion._new(v as Map<String, dynamic>));
    });

    return tmp;
  }

  /// Creates a channel. Returns null when [type] is DM or GroupDM.
  /// Also can be null if [type] is Guild Group channel and parent is specified.
  ///
  /// ```
  /// var chan = await guild.createChannel("Super duper channel", ChannelType.text, nsfw: true);
  /// ```
  Future<GuildChannel> createChannel(String name, ChannelType type,
      {int? bitrate,
      String? topic,
      CategoryChannel? parent,
      bool? nsfw,
      int? userLimit,
      PermissionsBuilder? permissions,
      String auditReason = ""}) async {
    // Checks to avoid API panic
    if (type == ChannelType.dm || type == ChannelType.groupDm) {
      return Future.error("Cannot create DM channel.");
    }

    if (type == ChannelType.category && parent != null) {
      return Future.error(
          "Cannot create Category Channel which have parent channel.");
    }

    // Construct body
    var body = <String, dynamic>{"name": name, "type": type._value};
    if (bitrate != null) body['bitrate'] = bitrate;
    if (topic != null) body['topic'] = topic;
    if (parent != null) body['parent_id'] = parent.id.toString();
    if (nsfw != null) body['nsfw'] = nsfw;
    if (userLimit != null) body['user_limit'] = userLimit;
    if (permissions != null) body['permission_overwrites'] = permissions;

    // Send request
    HttpResponse r = await client._http
        .send('POST', "/guilds/$id/channels", body: body, reason: auditReason);
    var raw = r.body;

    switch (type._value) {
      case 0:
        return TextChannel._new(raw as Map<String, dynamic>, this, client);
      case 4:
        return CategoryChannel._new(raw as Map<String, dynamic>, this, client);
      case 2:
        return VoiceChannel._new(raw as Map<String, dynamic>, this, client);
      default:
        return Future.error("Cannot create DM channel.");
    }
  }

  /// Moves channel. Allows to move channel by absolute about with [absolute] or relatively with [relative] parameter.
  ///
  /// ```
  /// // This moves channel 2 places up
  /// await guild.moveChannel(chan, relative: -2);
  /// ```
  Future<void> moveChannel(GuildChannel channel,
      {int? absolute, int? relative, String auditReason = ""}) async {

    if (absolute == null && relative == null)
      return Future.error("Cannot move channel by zero places");

    int newPosition = channel.position + relative;

    if (absolute != null) {
      newPosition = absolute;
    }

    await client._http.send('PATCH', "/guilds/${this.id}/channels",
        body: {"id": channel.id.toString(), "position": newPosition},
        reason: auditReason);
  }

  /// Bans a user and allows to delete messages from [deleteMessageDays] number of days.
  /// ```
  ///
  /// await guild.ban(member);
  /// ```
  Future<void> ban(Member member,
      {int deleteMessageDays = 0, String? auditReason}) async {
    await client._http.send(
        'PUT', "/guilds/${this.id}/bans/${member.id.toString()}",
        body: {"delete-message-days": deleteMessageDays}, reason: auditReason);
  }

  /// Kicks user from guild. Member is removed from guild and he is able to rejoin
  ///
  /// ```
  /// await guild.kick(member);
  /// ```
  Future<void> kick(Member member, {String? auditReason}) async {
    await client._http.send("DELETE",
        "/guilds/${this.id.toString()}/members/${member.id.toString()}",
        reason: auditReason);
  }

  /// Unbans a user by ID.
  Future<void> unban(Snowflake id) async {
    await client._http
        .send('DELETE', "/guilds/${this.id}/bans/${id.toString()}");
  }

  /// Edits the guild.
  Future<Guild> edit(
      {String? name,
      int? verificationLevel,
      int? notificationLevel,
      VoiceChannel? afkChannel,
      int? afkTimeout,
      String? icon,
      String? auditReason}) async {
    HttpResponse r = await client._http.send('PATCH', "/guilds/${this.id}",
        body: {
          "name": name != null ? name : this.name,
          "verification_level": verificationLevel != null
              ? verificationLevel
              : this.verificationLevel,
          "default_message_notifications": notificationLevel != null
              ? notificationLevel
              : this.notificationLevel,
          "afk_channel_id": afkChannel != null ? afkChannel : this.afkChannel,
          "afk_timeout": afkTimeout != null ? afkTimeout : this.afkTimeout,
          "icon": icon != null ? icon : this.icon
        },
        reason: auditReason);
    return Guild._new(client, r.body as Map<String, dynamic>);
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
  /// var member = guild.getMember(Snowflake('302359795648954380'));
  /// ```
  Future<Member> getMemberById(Snowflake id) async {
    if (this.members.hasKey(id)) return this.members[id] as Member;

    final r = await client._http
        .send('GET', '/guilds/${this.id}/members/${id.toString()}');

    return _StandardMember(r.body as Map<String, dynamic>, this, client);
  }

  /// Gets all of the webhooks for this guild.
  Future<Map<Snowflake, Webhook>> getWebhooks() async {
    HttpResponse r = await client._http.send('GET', "/guilds/$id/webhooks");

    Map<Snowflake, Webhook> map = Map();
    r.body.forEach((k, o) {
      var webhook = Webhook._new(o as Map<String, dynamic>, client);
      map[webhook.id] = webhook;
    });

    return map;
  }

  /// Deletes the guild.
  Future<void> delete() async {
    await client._http.send('DELETE', "/guilds/${this.id}");
  }

  @override
  Future<void> dispose() async {
    await channels.dispose();
    await members.dispose();
    await roles.dispose();
    await emojis.dispose();
    await voiceStates.dispose();
  }
}
