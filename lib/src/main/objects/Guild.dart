part of discord;

/// A guild.
class Guild {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The guild's name.
  String name;

  /// The guild's ID.
  String id;

  /// The guild's icon hash.
  String icon;

  /// The guild's afk channel ID, null if not set.
  VoiceChannel afkChannel;

  /// The guild's voice region.
  String region;

  /// The channel ID for the guild's widget if enabled.
  String embedChannelID;

  /// The guild's default channel.
  GuildChannel defaultChannel;

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

  /// A timestamp for when the guild was created.
  DateTime createdAt;

  /// If the guild's widget is enabled.
  bool embedEnabled;

  /// Whether or not the guild is available.
  bool available;

  /// The guild owner's ID
  String ownerID;

  /// The guild's members.
  Map<String, Member> members;

  /// The guild's channels.
  Map<String, GuildChannel> channels;

  /// The guild's roles.
  Map<String, Role> roles;

  Map<String, Emoji> emojis;
  
  /// The shard that the guild is on.
  Shard shard;

  Guild._new(this.client, this.raw,
      [this.available = true, bool guildCreate = false]) {
    if (this.available) {
      this.name = raw['name'];
      this.id = raw['id'];
      this.icon = raw['icon'];
      this.region = raw['region'];
      this.embedChannelID = raw['embed_channel_id'];
      this.afkTimeout = raw['afk_timeout'];
      this.memberCount = raw['member_count'];
      this.verificationLevel = raw['verification_level'];
      this.notificationLevel = raw['default_message_notifications'];
      this.mfaLevel = raw['mfa_level'];
      this.embedEnabled = raw['embed_enabled'];
      this.ownerID = raw['owner_id'];
      this.createdAt = Util.getDate(this.id);

      this.emojis = new Map<String, Emoji>();
      raw['emojis'].forEach((Map<String, dynamic> o) {
        new Emoji._new(this.client, o, this);
      });
      
      this.roles = new Map<String, Role>();
      raw['roles'].forEach((Map<String, dynamic> o) {
        new Role._new(this.client, o, this);
      });

      this.shard = this
          .client
          .shards[(int.parse(this.id) >> 22) % this.client._options.shardCount];

      if (guildCreate) {
        this.members = new Map<String, Member>();
        this.channels = new Map<String, GuildChannel>();

        raw['members'].forEach((Map<String, dynamic> o) {
          new Member._new(client, o, this);
        });

        raw['channels'].forEach((Map<String, dynamic> o) {
          if (o['type'] == 0) {
            new TextChannel._new(client, o, this);
          } else {
            new VoiceChannel._new(client, o, this);
          }
        });

        raw['presences'].forEach((Map<String, dynamic> o) {
          Member member = this.members[o['user']['id']];
          if (member != null) {
            member.status = o['status'];
            if (o['game'] != null) {
              member.game =
                  new Game._new(client, o['game'] as Map<String, dynamic>);
            }
          }
        });

        this.defaultChannel = this.channels[this.id];
        this.afkChannel = this.channels[raw['afk_channel_id']];
      }

      client.guilds[this.id] = this;
      shard.guilds[this.id] = this;
    }
  }

  /// The guild's icon, represented as URL.
  String iconURL({String format: 'webp', int size: 128}) {
    if (this.icon == null)
      return 'https://cdn.${_Constants.host}/icons/${this.id}/${this.icon}.$format?size=$size';

    return null;
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }

  /// Prunes the guild, returns the amount of members pruned.
  Future<int> prune(int days) async {
    HttpResponse r = await this
        .client
        .http
        .send('POST', "/guilds/$id/prune", body: {"days": days});
    return r.body.asJson() as int;
  }

  /// Get's the guild's bans.
  Future<Map<String, User>> getBans() async {
    HttpResponse r = await this.client.http.send('GET', "/guilds/$id/bans");
    Map<String, dynamic> map = <String, dynamic>{};
    r.body.asJson().forEach((Map<String, dynamic> o) {
      final User user =
          new User._new(client, o['user'] as Map<String, dynamic>);
      map[user.id] = user;
    });
    return map;
  }

  /// Change guild owner
  Future<Guild> changeOwner(String id) async {
    HttpResponse r = await this.client.http.send('PATCH', "/guilds/$id",
        body: {
          "owner_id": id
        });
    final Guild g = new Guild._new(client, r.body.asJson() as Map<String, dynamic>);

    return g;
  }
  
  /// Leaves the guild.
  Future<Null> leave() async {
    await this.client.http.send('DELETE', "/users/@me/guilds/$id");
    return null;
  }

  /// Creates an empty role.
  Future<Role> createRole() async {
    HttpResponse r = await this.client.http.send('POST', "/guilds/$id/roles");
    return new Role._new(client, r.body.asJson() as Map<String, dynamic>, this);
  }

  /// Creates a channel.
  Future<dynamic> createChannel(String name, String type,
      {int bitrate: 64000, int userLimit: 0}) async {
    HttpResponse r = await this.client.http.send('POST', "/guilds/$id/channels",
        body: {
          "name": name,
          "type": type,
          "bitrate": bitrate,
          "user_limit": userLimit
        });

    if (r.body.asJson()['type'] == 0) {
      return new TextChannel._new(
          client, r.body.asJson() as Map<String, dynamic>, this);
    } else {
      return new VoiceChannel._new(
          client, r.body.asJson() as Map<String, dynamic>, this);
    }
  }
  
  /// Moves channel
  Future<Null> moveGuildChannel(String channelId, int newPosition) async {
    await this.client.http.send('PATCH', "/guilds/${this.id}/channels",
        body: {"id": id, "position": newPosition});
    return null;
  }

  /// Bans a user by ID.
  Future<Null> ban(String id, [int deleteMessageDays = 0]) async {
    await this.client.http.send('PUT', "/guilds/${this.id}/bans/$id",
        body: {"delete-message-days": deleteMessageDays});
    return null;
  }

  /// Unbans a user by ID.
  Future<Null> unban(String id) async {
    await this.client.http.send('DELETE', "/guilds/${this.id}/bans/$id");
    return null;
  }

  /// Edits the guild.
  Future<Guild> edit(
      {String name: null,
      int verificationLevel: null,
      int notificationLevel: null,
      VoiceChannel afkChannel: null,
      int afkTimeout: null,
      String icon: null}) async {
    HttpResponse r =
        await this.client.http.send('PATCH', "/guilds/${this.id}", body: {
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
    });
    return new Guild._new(this.client, r.body.asJson() as Map<String, dynamic>);
  }

  /// Gets a [Member] object. Adds it to `Guild.members` if
  /// not already there.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Guild.getMember("user id");
  Future<Member> getMember(dynamic member) async {
    final String id = Util.resolve('member', member);

    if (this.members[member] != null) {
      return this.members[member];
    } else {
      final HttpResponse r =
          await this.client.http.send('GET', '/guilds/${this.id}/members/$id');

      final Member m = new Member._new(
          this.client, r.body.asJson() as Map<String, dynamic>, this);
      return m;
    }
  }

  /// Invites a bot to a guild. Only usable by user accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is a bot.
  ///     Guild.oauth2Authorize("app id");
  Future<Null> oauth2Authorize(dynamic app, [int permissions = 0]) async {
    if (!this.client.user.bot) {
      final String id = Util.resolve('app', app);

      await this.client.http.send(
          'POST', '/oauth2/authorize?client_id=$id&scope=bot',
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
    Map<String, dynamic> map = <String, dynamic>{};
    r.body.asJson().forEach((Map<String, dynamic> o) {
      Webhook webhook = new Webhook._fromApi(this.client, o);
      map[webhook.id] = webhook;
    });
    return map;
  }

  /// Deletes the guild.
  Future<Null> delete() async {
    await this.client.http.send('DELETE', "/guilds/${this.id}");
    return null;
  }
}
