import 'dart:async';
import 'dart:convert';
import '../../discord.dart';
import 'package:http/http.dart' as http;

/// A guild.
class Guild {
  /// The client.
  Client client;

  /// A map of all of the properties.
  Map<String, dynamic> map = <String, dynamic>{};

  /// The guild's name.
  String name;

  /// The guild's ID.
  String id;

  /// The guild's icon hash.
  String icon;

  /// The guild's afk channel ID, null if not set.
  String afkChannelID;

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
  double createdAt;

  /// If the guild's widget is enabled.
  bool embedEnabled;

  /// Whether or not the guild is available.
  bool available = true;

  /// The guild owner's ID
  String ownerID;

  /// The guild's members.
  Map<String, Member> members = <String, Member>{};

  /// The guild's channels.
  Map<String, GuildChannel> channels = <String, GuildChannel>{};

  /// Constructs a new [Guild].
  Guild(this.client, Map<String, dynamic> data, [this.available, bool guildCreate = false]) {
    if (this.available) {
      this.name = data['name'];
      this.map['name'] = this.name;

      this.id = data['id'];
      this.map['id'] = this.id;

      this.icon = data['icon'];
      this.map['icon'] = this.icon;

      this.afkChannelID = data['afk_channel_id'];
      this.map['afkChannelID'] = this.afkChannelID;

      this.region = data['region'];
      this.map['region'] = this.region;

      this.embedChannelID = data['embed_channel_id'];
      this.map['embedChannelID'] = this.embedChannelID;

      this.afkTimeout = data['afk_timeout'];
      this.map['afkTimeout'] = this.afkTimeout;

      this.memberCount = data['member_count'];
      this.map['memberCount'] = this.memberCount;

      this.verificationLevel = data['verification_level'];
      this.map['verificationLevel'] = this.verificationLevel;

      this.notificationLevel = data['default_message_notifications'];
      this.map['notificationLevel'] = this.notificationLevel;

      this.mfaLevel = data['mfa_level'];
      this.map['mfaLevel'] = this.mfaLevel;

      this.embedEnabled = data['embed_enabled'];
      this.map['embedEnabled'] = this.embedEnabled;

      this.ownerID = data['owner_id'];
      this.map['ownerID'] = this.ownerID;

      this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;
      this.map['createdAt'] = this.createdAt;


      if (guildCreate) {
        //this.roles = JSON.decode(data['roles']);
        data['members'].forEach((Map<String, dynamic> o) {
          final Member member = new Member(o, this);
          this.members[member.user.id] = member;
        });
        this.map['members'] = this.members;

        data['channels'].forEach((Map<String, dynamic> o) {
          final GuildChannel channel = new GuildChannel(client, o, this);
          this.channels[channel.id] = channel;
        });
        this.map['channels'] = this.channels;

        this.defaultChannel = this.channels[this.id];
        this.map['defaultChannel'] = this.defaultChannel;
      }
    }
  }

  /// Gets a [Member] object. Adds it to `Client.guilds["guild id"].members` if
  /// not already there.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Guild.getMember("user id");
  Future<Member> getMember(dynamic member) async {
    if (this.client.ready) {
      final String id = this.client.resolve('member', member);

      if (this.members[member] != null) {
        return this.members[member];
      } else {
        final http.Response r = await this.client.http.get('guilds/${this.id}/members/$id');
        final Map<String, dynamic> res = JSON.decode(r.body);

        if (r.statusCode == 200) {
          final Member m = new Member(res, this);
          this.members[m.user.id] = m;
          return m;
        } else {
          throw new Exception("${res['code']}:${res['message']}");
        }
      }
    } else {
      throw new Exception("the client isn't ready");
    }
  }

  /// Invites a bot to a guild. Only usable by user accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is a bot.
  ///     Guild.oauth2Authorize("app id");
  Future<bool> oauth2Authorize(dynamic app, [int permissions = 0]) async {
    if (this.client.ready) {
      if (!this.client.user.bot) {
        final String id = this.client.resolve('app', app);

        final http.Response r = await this.client.http.post('oauth2/authorize?client_id=$id&scope=bot', <String, dynamic>{"guild_id": this.id, "permissions": permissions, "authorize": true});
        final Map<String, dynamic> res = JSON.decode(r.body);

        if (r.statusCode == 200) {
          return true;
        } else {
          throw new Exception("${res['code']}:${res['message']}");
        }
      } else {
        throw new Exception("'oauth2Authorize' is only usable by user accounts.");
      }
    } else {
      throw new Exception("the client isn't ready");
    }
  }
}
