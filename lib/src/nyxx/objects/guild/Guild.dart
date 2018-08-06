part of nyxx;

/// [Guild] object represents single `Discord Server` instance.
/// Based on bots permissions - can preform operations of [Guild], [User]s [Role]s and many more.
///
/// [channels] property is Map of [Channel]s but i can be cast to specific Channel subclasses. Example with getting all [TextChannel]s in [Guild]:
/// ```dart
/// var textChannels = channels.where((channel) => channel is MessageChannel) as List<TextChannel>;
/// ```
/// If you want to get [icon] or [splash] of [Guild] use `iconURL()` method - [icon] property returns only hash, same as [splash] property.
class Guild extends SnowflakeEntity {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The guild's name.
  String name;

  /// The guild's icon hash.
  String icon;

  /// Splash hash
  String splash;

  /// System channel where system messages are sent
  Channel systemChannel;

  /// enabled guild features
  List<String> features;

  /// The guild's afk channel ID, null if not set.
  VoiceChannel afkChannel;

  /// The guild's voice region.
  String region;

  /// The channel ID for the guild's widget if enabled.
  Snowflake embedChannelID;

  /// The guild's default channel.
  Channel defaultChannel;

  /// The guild's AFK timeout.
  int afkTimeout;

  /// The guild's member count.
  int memberCount;

  /// The guild's verification level.
  int verificationLevel;

  /// The guild's notification level.
  int notificationLevel;

  /// The guild's MFA level.
  int mfaLevel;

  /// If the guild's widget is enabled.
  bool embedEnabled;

  /// Whether or not the guild is available.
  bool available;

  /// The guild owner's ID
  Snowflake ownerID;

  /// The guild's members.
  Map<Snowflake, Member> members;

  /// The guild's channels.
  Map<Snowflake, Channel> channels;

  /// The guild's roles.
  Map<Snowflake, Role> roles;

  /// Guild custom emojis
  Map<Snowflake, GuildEmoji> emojis;

  /// The shard that the guild is on.
  Shard shard;

  Guild._new(this.client, this.raw,
      [this.available = true, bool guildCreate = false]) : super(new Snowflake(raw['id'] as String)) {
    if (this.available) {
      this.name = raw['name'] as String;
      this.icon = raw['icon'] as String;
      this.region = raw['region'] as String;

      if (raw.containsKey('embed_channel_id'))
        this.embedChannelID = new Snowflake(raw['embed_channel_id'] as String);

      this.afkTimeout = raw['afk_timeout'] as int;
      this.memberCount = raw['member_count'] as int;
      this.verificationLevel = raw['verification_level'] as int;
      this.notificationLevel = raw['default_message_notifications'] as int;
      this.mfaLevel = raw['mfa_level'] as int;
      this.embedEnabled = raw['embed_enabled'] as bool;
      this.splash = raw['splash'] as String;
      this.ownerID = new Snowflake(raw['owner_id'] as String);

      this.emojis = new Map<Snowflake, GuildEmoji>();
      raw['emojis'].forEach((dynamic o) {
        new GuildEmoji._new(this.client, o as Map<String, dynamic>, this);
      });

      this.roles = new Map<Snowflake, Role>();
      raw['roles'].forEach((dynamic o) {
        new Role._new(this.client, o as Map<String, dynamic>, this);
      });

      this.shard = this.client.shards[(int.parse(this.id.toString()) >> 22) %
          this.client._options.shardCount];

      if (guildCreate) {
        this.members = new Map<Snowflake, Member>();
        this.channels = new Map<Snowflake, Channel>();

        raw['members'].forEach((dynamic o) {
          new Member._new(client, o as Map<String, dynamic>, this);
        });

        raw['channels'].forEach((dynamic o) {
          if (o['type'] == 0)
            new TextChannel._new(client, o as Map<String, dynamic>, this);
          else if (o['type'] == 2)
            new VoiceChannel._new(client, o as Map<String, dynamic>, this);
          else if (o['type'] == 4)
            new GroupChannel._new(client, o as Map<String, dynamic>, this);
        });

        raw['presences'].forEach((dynamic o) {
          Member member = this.members[o['user']['id']];
          if (member != null) {
            member.status = o['status'] as String;
            if (o['game'] != null) {
              member.game =
                  new Game._new(client, o['game'] as Map<String, dynamic>);
            }
          }
        });

        this.defaultChannel = this.channels[this.id];
        this.afkChannel = this.channels[new Snowflake(raw['afk_channel_id'] as String)] as VoiceChannel;
      }

      this.systemChannel = this.channels[new Snowflake(raw['system_channel_id'] as String)];

      if (raw['features'] != null) {
        this.features = new List();
        raw['features'].forEach((dynamic i) {
          this.features.add(i.toString());
        });
      }

      client.guilds[this.id] = this;
      shard.guilds[this.id] = this;
    }
  }

  /// The guild's icon, represented as URL.
  String iconURL({String format: 'webp', int size: 128}) {
    if (this.icon != null)
      return 'https://cdn.${_Constants.host}/icons/${this.id}/${this.icon}.$format?size=$size';

    return null;
  }

  String splashURL({String format: 'webp', int size: 128}) {
    if (this.splash != null)
      return 'https://cdn.discordapp.com/splashes/${this.id}/${this.splash}.$format?size=$size';

    return null;
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }

  /// Gets Guild Emoji based on Id
  Future<Emoji> getEmoji(Snowflake emojiId) async {
    HttpResponse r =
        await this.client.http.send('GET', "/guilds/$id/emojis/${emojiId.toString()}");

    return new GuildEmoji._new(
        this.client, r.body.asJson as Map<String, dynamic>, this);
  }

  /// Prunes the guild, returns the amount of members pruned.
  Future<int> prune(int days, {String auditReason = ""}) async {
    HttpResponse r = await this.client.http.send('POST', "/guilds/$id/prune",
        body: {"days": days}, reason: auditReason);
    return r.body.asJson() as int;
  }

  /// Get's the guild's bans.
  Future<Map<String, User>> getBans() async {
    HttpResponse r = await this.client.http.send('GET', "/guilds/$id/bans");
    Map<String, User> map = new Map();
    r.body.asJson().forEach((dynamic o) {
      final User user =
          new User._new(client, o['user'] as Map<String, dynamic>);
      map[user.id.toString()] = user;
    });
    return map;
  }

  /// Change guild owner
  Future<Guild> changeOwner(Member member, {String auditReason = ""}) async {
    HttpResponse r = await this.client.http.send('PATCH', "/guilds/$id",
        body: {"owner_id": member.id}, reason: auditReason);

    return new Guild._new(client, r.body.asJson() as Map<String, dynamic>);
  }

  /// Leaves the guild.
  Future<Null> leave() async {
    await this.client.http.send('DELETE', "/users/@me/guilds/$id");
    return null;
  }

  /// Returns list of Guilds invites
  Future<List<Invite>> getGuildInvites() async {
    HttpResponse r = await this.client.http.send('GET', "/guilds/$id/invites");

    var raw = r.body.asJson() as List<dynamic>;
    List<Invite> tmp = new List();
    raw.forEach((v) {
      tmp.add(new Invite._new(this.client, v as Map<String, dynamic>));
    });

    return tmp;
  }

  /// Returns Audit logs.
  Future<AuditLog> getAuditLogs(
      {Snowflake userId,
      String actionType,
      Snowflake before,
      int limit}) async {
    var query = new Map<String, String>();
    if (userId != null) query['user_id'] = userId.toString();
    if (actionType != null) query['action_type'] = actionType;
    if (before != null) query['before'] = before.toString();
    if (limit != null) query['limit'] = limit.toString();

    HttpResponse r = await this
        .client
        .http
        .send('GET', '/guilds/${this.id}/audit-logs', queryParams: query);

    return new AuditLog._new(
        this.client, r.body.asJson() as Map<String, dynamic>);
  }

  /// Get Guil's embed object
  Future<Embed> getGuildEmbed() async {
    HttpResponse r = await this.client.http.send('GET', "/guilds/$id/embed");
    return new Embed._new(this.client, r.body.asJson() as Map<String, dynamic>);
  }

  /// Modify guild embed object
  Future<Embed> editGuildEmbed(EmbedBuilder embed,
      {String auditReason = ""}) async {
    HttpResponse r = await this.client.http.send('PATCH', "/guilds/$id/embed",
        body: embed._build(), reason: auditReason);
    return new Embed._new(
      this.client,
      r.body.asJson() as Map<String, dynamic>,
    );
  }

  /// Creates new role
  Future<Role> createRole(String name,
      {PermissionsBuilder permissions,
      String color,
      bool hoist,
      bool mentionable,
      String auditReason = ""}) async {
    var tmp = <String, dynamic>{
      "name": name,
      "permissions": permissions._build()._build(),
      "color": color,
      "hoist": hoist,
      "mentionable": mentionable
    };

    HttpResponse r = await this
        .client
        .http
        .send('POST', "/guilds/$id/roles", body: tmp, reason: auditReason);
    return new Role._new(client, r.body.asJson() as Map<String, dynamic>, this);
  }

  /// Adds [Role] to [Member]
  Future<Null> addRoleToMember(Member user, Role role) async {
    await this
        .client
        .http
        .send('PUT', '/guilds/$id/members/$user.id/roles/$role.id');
    return null;
  }

  /// Returns list of available [VoiceChannel]s
  Future<List<VoiceRegion>> getVoiceRegions() async {
    var r = await this.client.http.send('GET', "/guilds/$id/regions");

    var raw = r.body.asJson() as List<dynamic>;
    List<VoiceRegion> tmp = new List();
    raw.forEach((v) {
      tmp.add(new VoiceRegion._new(v as Map<String, dynamic>));
    });

    return tmp;
  }

  /// Creates a channel.
  Future<dynamic> createChannel(String name, String type,
      {int bitrate: 64000,
      int userLimit: 0,
      String auditReason = "",
      PermissionsBuilder permissions}) async {
    HttpResponse r = await this.client.http.send('POST', "/guilds/$id/channels",
        body: {
          "name": name,
          "type": type,
          "bitrate": bitrate,
          "user_limit": userLimit,
          "permissions": permissions._build()._build()
        },
        reason: auditReason);

    if (r.body.asJson()['type'] == 0) {
      return new TextChannel._new(
          client, r.body.asJson() as Map<String, dynamic>, this);
    } else {
      return new VoiceChannel._new(
          client, r.body.asJson() as Map<String, dynamic>, this);
    }
  }

  /// Moves channel
  Future<Null> moveGuildChannel(Channel channel, int newPosition,
      {String auditReason = ""}) async {
    await this.client.http.send('PATCH', "/guilds/${this.id}/channels",
        body: {"id": channel.id.toString(), "position": newPosition}, reason: auditReason);
    return null;
  }

  /// Bans a user by ID.
  Future<Null> ban(Member member,
      {int deleteMessageDays = 0, String auditReason}) async {
    await this.client.http.send('PUT', "/guilds/${this.id}/bans/${member.id.toString()}",
        body: {"delete-message-days": deleteMessageDays}, reason: auditReason);
    return null;
  }

  /// Unbans a user by ID.
  Future<Null> unban(Snowflake id) async {
    await this.client.http.send('DELETE', "/guilds/${this.id}/bans/${id.toString()}");
    return null;
  }

  /// Edits the guild.
  Future<Guild> edit(
      {String name: null,
      int verificationLevel: null,
      int notificationLevel: null,
      VoiceChannel afkChannel: null,
      int afkTimeout: null,
      String icon: null,
      String auditReason}) async {
    HttpResponse r = await this.client.http.send('PATCH', "/guilds/${this.id}",
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
    return new Guild._new(this.client, r.body.asJson() as Map<String, dynamic>);
  }

  /// Gets a [Member] object. Adds it to `Guild.members` if
  /// not already there.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Guild.getMember("user id");
  Future<Member> getMember(User user) async {
    if (this.members[user.id.toString()] != null)
      return this.members[user.id.toString()];

    final HttpResponse r = await this
        .client
        .http
        .send('GET', '/guilds/${this.id}/members/${user.id.toString()}');

    return new Member._new(
        this.client, r.body.asJson() as Map<String, dynamic>, this);
  }

  /// Invites a bot to a guild. Only usable by user accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is a bot.
  ///     Guild.oauth2Authorize("app id");
  Future<Null> oauth2Authorize(String userId, [int permissions = 0]) async {
    if (!this.client.user.bot) {
      await this.client.http.send(
          'POST', '/oauth2/authorize?client_id=$userId&scope=bot',
          body: <String, dynamic>{
            "guild_id": this.id,
            "permissions": permissions,
            "authorize": true
          });

      return null;
    } else {
      throw new Exception("'oauth2Authorize' is only usable by user accounts.");
    }
  }

  /// Gets all of the webhooks for this guild.
  Future<Map<String, Webhook>> getWebhooks() async {
    HttpResponse r = await this.client.http.send('GET', "/guilds/$id/webhooks");
    Map<String, Webhook> map = new Map();
    r.body.asJson().forEach((dynamic o) {
      Webhook webhook =
          new Webhook._fromApi(this.client, o as Map<String, dynamic>);
      map[webhook.id.toString()] = webhook;
    });
    return map;
  }

  /// Deletes the guild.
  Future<Null> delete() async {
    await this.client.http.send('DELETE', "/guilds/${this.id}");
    return null;
  }
}
