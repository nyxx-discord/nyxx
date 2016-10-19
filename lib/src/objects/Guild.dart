part of discord;

/// A guild.
class Guild extends _BaseObj {
  /// The guild's name.
  String name;

  /// The guild's ID.
  String id;

  /// The guild's icon hash.
  String icon;

  /// The guild's icon URL.
  String iconURL;

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

  /// The shard that the guild is on.
  Shard shard;

  Guild._new(Client client, Map<String, dynamic> data,
      [this.available = true, bool guildCreate = false])
      : super(client) {
    if (this.available) {
      this.name = data['name'];
      this.id = data['id'];
      this.icon = data['icon'];
      this.iconURL =
          "${_Constants.host}/guilds/${this.id}/icons/${this.icon}.jpg";
      this.region = data['region'];
      this.embedChannelID = data['embed_channel_id'];
      this.afkTimeout = data['afk_timeout'];
      this.memberCount = data['member_count'];
      this.verificationLevel = data['verification_level'];
      this.notificationLevel = data['default_message_notifications'];
      this.mfaLevel = data['mfa_level'];
      this.embedEnabled = data['embed_enabled'];
      this.ownerID = data['owner_id'];
      this.createdAt = _Util.getDate(this.id);

      this.roles = new Map<String, Role>();
      data['roles'].forEach((Map<String, dynamic> o) {
        new Role._new(this._client, o, this);
      });

      this.shard = this._client.shards[
          "${(int.parse(this.id) >> 22) % this._client._options.shardCount}"];

      if (guildCreate) {
        this.members = new Map<String, Member>();
        this.channels = new Map<String, GuildChannel>();

        data['members'].forEach((Map<String, dynamic> o) {
          new Member._new(client, o, this);
        });

        data['channels'].forEach((Map<String, dynamic> o) {
          if (o['type'] == 0) {
            new TextChannel._new(client, o, this);
          } else {
            new VoiceChannel._new(client, o, this);
          }
        });

        data['presences'].forEach((Map<String, dynamic> o) {
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
        this.afkChannel = this.channels[data['afk_channel_id']];
      }

      client.guilds[this.id] = this;
    }
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }

  /// Prunes the guild, returns the amount of members pruned.
  Future<int> prune(int days) async {
    _HttpResponse r =
        await this._client._http.post("/guilds/$id/prune", {"days": days});
    return r.json as int;
  }

  /// Get's the guild's bans.
  Future<Map<String, User>> getBans() async {
    _HttpResponse r = await this._client._http.get("/guilds/$id/bans");
    Map<String, dynamic> map = <String, dynamic>{};
    r.json.forEach((Map<String, dynamic> o) {
      final User user =
          new User._new(_client, o['user'] as Map<String, dynamic>);
      map[user.id] = user;
    });
    return map;
  }

  /// Leaves the guild.
  Future<Null> leave() async {
    await this._client._http.delete("/users/@me/guilds/$id");
    return null;
  }

  /// Creates an empty role.
  Future<Role> createRole() async {
    _HttpResponse r = await this._client._http.post("/guilds/$id/roles", {});
    return new Role._new(_client, r.json as Map<String, dynamic>, this);
  }

  /// Creates a channel.
  Future<dynamic> createChannel(String name, String type,
      {int bitrate: 64000, int userLimit: 0}) async {
    _HttpResponse r = await this._client._http.post("/guilds/$id/channels", {
      "name": name,
      "type": type,
      "bitrate": bitrate,
      "user_limit": userLimit
    });

    if (r.json['type'] == 0) {
      return new TextChannel._new(
          _client, r.json as Map<String, dynamic>, this);
    } else {
      return new VoiceChannel._new(
          _client, r.json as Map<String, dynamic>, this);
    }
  }

  /// Bans a user by ID.
  Future<Null> ban(String id, [int deleteMessageDays = 0]) async {
    await this._client._http.put("/guilds/${this.id}/bans/$id",
        {"delete-message-days": deleteMessageDays});
    return null;
  }

  /// Unbans a user by ID.
  Future<Null> unban(String id) async {
    await this._client._http.delete("/guilds/${this.id}/bans/$id");
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
    _HttpResponse r = await this._client._http.patch("/guilds/${this.id}", {
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
    return new Guild._new(this._client, r.json as Map<String, dynamic>);
  }

  /// Gets a [Member] object. Adds it to `Guild.members` if
  /// not already there.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Guild.getMember("user id");
  Future<Member> getMember(dynamic member) async {
    final String id = _Util.resolve('member', member);

    if (this.members[member] != null) {
      return this.members[member];
    } else {
      final _HttpResponse r =
          await this._client._http.get('/guilds/${this.id}/members/$id');

      final Member m =
          new Member._new(this._client, r.json as Map<String, dynamic>, this);
      return m;
    }
  }

  /// Invites a bot to a guild. Only usable by user accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is a bot.
  ///     Guild.oauth2Authorize("app id");
  Future<Null> oauth2Authorize(dynamic app, [int permissions = 0]) async {
    if (!this._client.user.bot) {
      final String id = _Util.resolve('app', app);

      await this._client._http.post(
          '/oauth2/authorize?client_id=$id&scope=bot', <String, dynamic>{
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
    _HttpResponse r = await this._client._http.get("/guilds/$id/webhooks");
    Map<String, dynamic> map = <String, dynamic>{};
    r.json.forEach((Map<String, dynamic> o) {
      Webhook webhook = new Webhook._fromApi(this._client, o);
      map[webhook.id] = webhook;
    });
    return map;
  }
}
