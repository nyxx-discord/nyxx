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
  Collection<Member> members;

  /// The guild's channels.
  Collection<GuildChannel> channels;

  /// The guild's roles.
  Collection<Role> roles;

  Guild._new(Client client, Map<String, dynamic> data,
      [this.available = true, bool guildCreate = false])
      : super(client) {
    if (this.available) {
      this.name = this._map['name'] = data['name'];
      this.id = this._map['id'] = data['id'];
      this.icon = this._map['icon'] = data['icon'];
      this.iconURL = this._map['iconURL'] =
          "https://discordapp.com/api/v6/guilds/${this.id}/icons/${this.icon}.jpg";
      this.region = this._map['region'] = data['region'];
      this.embedChannelID =
          this._map['embedChannelID'] = data['embed_channel_id'];
      this.afkTimeout = this._map['afkTimeout'] = data['afk_timeout'];
      this.memberCount = this._map['memberCount'] = data['member_count'];
      this.verificationLevel =
          this._map['verificationLevel'] = data['verification_level'];
      this.notificationLevel = this._map['notificationLevel'] =
          data['default_message_notifications'];
      this.mfaLevel = this._map['mfaLevel'] = data['mfa_level'];
      this.embedEnabled = this._map['embedEnabled'] = data['embed_enabled'];
      this.ownerID = this._map['ownerID'] = data['owner_id'];
      this.createdAt =
          this._map['createdAt'] = this._client._util.getDate(this.id);
      this._map['key'] = this.id;

      this.roles = new Collection<Role>();
      data['roles'].forEach((Map<String, dynamic> o) {
        this.roles.add(new Role._new(this._client, o, this));
      });
      this._map['roles'] = this.roles;

      if (guildCreate) {
        this.members = new Collection<Member>();
        this.channels = new Collection<GuildChannel>();

        //this.roles = JSON.decode(data['roles']);
        data['members'].forEach((Map<String, dynamic> o) {
          this.members.add(new Member._new(client, o, this));
        });
        this._map['members'] = this.members;

        data['channels'].forEach((Map<String, dynamic> o) {
          if (o['type'] == 0) {
            this.channels.add(new TextChannel._new(client, o, this));
          } else {
            this.channels.add(new VoiceChannel._new(client, o, this));
          }
        });
        this._map['channels'] = this.channels;

        this.defaultChannel = this.channels[this.id];
        this._map['defaultChannel'] = this.defaultChannel;
      }

      this.afkChannel =
          this._map['afkChannel'] = this.channels[data['afk_channel_id']];
    }
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
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
    return new Guild._new(this._client, r.json);
  }

  /// Gets a [Member] object. Adds it to `Guild.members` if
  /// not already there.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Guild.getMember("user id");
  Future<Member> getMember(dynamic member) async {
    final String id = this._client._util.resolve('member', member);

    if (this.members[member] != null) {
      return this.members[member];
    } else {
      final _HttpResponse r =
          await this._client._http.get('/guilds/${this.id}/members/$id');

      final Member m = new Member._new(this._client, r.json, this);
      this.members.add(m);
      this._map['members'] = this.members;
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
      final String id = this._client._util.resolve('app', app);

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
}
