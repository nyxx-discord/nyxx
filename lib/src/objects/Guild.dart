import 'dart:async';
import 'dart:convert';
import '../client.dart';
import '../../objects.dart';
import 'package:http/http.dart' as http;

/// A guild.
class Guild {
  /// The client.
  Client client;

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
  Guild(this.client, Map<String, dynamic> data, [bool available = true, bool guildCreate = false]) {
    if (available) {
      this.name = data['name'];
      this.id = data['id'];
      this.icon = data['icon'];
      this.afkChannelID = data['afk_channel_id'];
      this.region = data['region'];
      this.embedChannelID = data['embed_channel_id'];
      this.afkTimeout = data['afk_timeout'];
      this.memberCount = data['member_count'];
      this.verificationLevel = data['verification_level'];
      this.notificationLevel = data['default_message_notifications'];
      this.mfaLevel = data['mfa_level'];
      this.embedEnabled = data['embed_enabled'];
      this.ownerID = data['owner_id'];
      this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;

      if (guildCreate) {
        //this.roles = JSON.decode(data['roles']);
        data['members'].forEach((Map<String, dynamic> o) {
          Member member = new Member(o, this);
          this.members[member.user.id] = member;
        });

        data['channels'].forEach((Map<String, dynamic> o) {
          GuildChannel channel = new GuildChannel(client, o, this);
          this.channels[channel.id] = channel;
        });

        this.defaultChannel = this.channels[this.id];
      }
    } else {
      this.available = false;
    }
  }

  /// Gets a [Member] object. Adds it to `Client.guilds["guild id"].members` if
  /// not already there.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Guild.getMember("user id");
  Future<Member> getMember(dynamic member) async {
    if (this.client.ready) {
      member = this.client.resolve('member', member);

      if (this.members[member] != null) {
        return this.members[member];
      } else {
        http.Response r = await this.client.http.get('guilds/${this.id}/members/$member');
        Map<String, dynamic> res = JSON.decode(r.body);
        if (r.statusCode == 200) {
          Member m = new Member(res, this);
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
        app = this.client.resolve('app', app);

        http.Response r = await this.client.http.post('oauth2/authorize?client_id=$app&scope=bot', <String, dynamic>{"guild_id": this.id, "permissions": permissions, "authorize": true});
        Map<String, dynamic> res = JSON.decode(r.body);
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
