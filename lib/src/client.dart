import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'objects.dart';
import 'http.dart';

/// The base class.
/// It contains all of the methods.
class Client {
  var _socket;
  int _lastS = null;
  String _sessionID;
  API _api = new API();
  Map _handlers = {
    "ready": [],
    "message": [],
    "messageDelete": [],
    "messageEdit": [],
    "debug": [],
    "loginError": [],
    "guildCreate": [],
    "guildUpdate": [],
    "guildDelete": [],
    "guildBanAdd": [],
    "guildBanRemove": [],
    "guildMemberAdd": [],
    "guildMemberRemove": [],
    "guildMemberUpdate": [],
    "channelCreate": [],
    "channelUpdate": [],
    "channelDelete": [],
    "typing": []
  };

  /// The token passed into the constructor.
  String token;

  /// The client's options.
  ClientOptions options;

  /// The logged in user.
  ClientUser user;

  /// The bot's OAuth2 app.
  ClientOAuth2Application app;

  /// A map of all the guilds the bot is in, by id.
  Map<String, Guild> guilds = {};

  /// A map of all the channels the bot is in, by id. Either a [GuildChannel] or
  /// [PrivateChannel].
  Map<String, Object> channels = {};

  /// A map of all of the users the bot can see, by id. Does not always have
  /// offline users without forceFetchUsers enabled.
  Map<String, User> users = {};

  /// Whether or not the client is ready.
  bool ready = false;

  void _heartbeat() {
    this._socket.add(JSON.encode({"op": 1,"d": this._lastS}));
  }

  Future _handleMsg(msg) async {
    var json = JSON.decode(msg);

    this._handlers['debug'].forEach((function) => function(json));

    if (json['s'] != null) {
      this._lastS = json['s'];
    }

    //const ms = const JSON.decode(msg)["d"]["heartbeat_interval"];

    if (json["op"] == 10) {
      const heartbeat_interval = const Duration(milliseconds: 41250);
      new Timer.periodic(heartbeat_interval, (Timer t) => this._heartbeat());

      this._socket.add(JSON.encode({
        "op": 2,
        "d": {
          "token": this.token,
          "properties": {
            "\$browser": "Discord Dart"
          },
          "large_threshold": 100,
          "compress": false
        }
      }));
    }

    else if (json['op'] == 9) {
      this._handlers['loginError'].forEach((function) => function());
    }

    /*else if (json['op'] == 7) {
      this._socket.add(JSON.encode({
        "token": this.token,
        "session_id": this._sessionID,
        "seq": this._lastS
      }));
    }*/

    else if (json["op"] == 0) {
      if (json['t'] == "READY") {
        this._sessionID = json['d']['session_id'];
        this.user = new ClientUser(json['d']['user']);

        json['d']['guilds'].forEach((o) {
          this.guilds[o['id']] = null;
        });

        json['d']['private_channels'].forEach((o) {
          PrivateChannel channel = new PrivateChannel(o);
          this.channels[channel.id] = channel;
        });

        if (this.user.bot) {
          this._api.headers['Authorization'] = "Bot ${this.token}";

          var r = await this._api.get('oauth2/applications/@me');
          Map res = JSON.decode(r.body);
          if (r.statusCode == 200) {
            this.app = new ClientOAuth2Application(res);
          }
        } else {
          this._api.headers['Authorization'] = this.token;
        }

        //this._handlers['ready'].forEach((function) => function());
      }

      else if (json['t'] == "MESSAGE_CREATE") {
        if (this.ready) {
          Message message = new Message(this, json['d']);
          this._handlers['message'].forEach((function) => function(message));
        }
      }

      else if (json['t'] == "MESSAGE_DELETE") {
        if (this.ready) {
          this._handlers['messageDelete'].forEach((function) => function(json['d']['id'], json['d']['channel_id']));
        }
      }

      else if (json['t'] == "MESSAGE_UPDATE") {
        if (this.ready) {
          if (!json['d'].containsKey('embeds')) {
            Message message = new Message(this, json['d']);
            this._handlers['messageEdit'].forEach((function) => function(message));
          }
        }
      }

      else if (json['t'] == "GUILD_CREATE") {
        Guild guild = new Guild(this, json['d'], true, true);
        this.guilds[guild.id] = guild;

        guild.channels.forEach((i, v) {
          this.channels[v.id] = v;
        });

        guild.members.forEach((i, v) {
          this.users[v.user.id] = v.user;
        });

        if (!this.ready) {
          bool match = true;
          this.guilds.forEach((i, o) {
            if (o == null) {
              match = false;
            }
          });

          if (match == true) {
            this.ready = true;
            this._handlers['ready'].forEach((function) => function());
          }
        } else {
          this._handlers['guildCreate'].forEach((function) => function(guild));
        }
      }

      else if (json['t'] == "GUILD_UPDATE") {
        if (this.ready) {
          Guild newGuild = new Guild(this, json['d']);
          Guild oldGuild = this.guilds[newGuild.id];
          newGuild.channels = oldGuild.channels;
          newGuild.members = oldGuild.members;

          this.guilds[newGuild.id] = newGuild;

          this._handlers['guildUpdate'].forEach((function) => function(oldGuild, newGuild));
        }
      }

      else if (json['t'] == "GUILD_DELETE") {
        if (this.ready) {
          if (json['d']['unavailable']) {
            Guild newGuild = new Guild(this, {}, false);
            this.guilds[json['d']['id']] = newGuild;
            this._handlers['guildDelete'].forEach((function) => function(true, newGuild));
          } else {
            Guild guild = this.guilds[json['d']['id']];
            this.guilds.remove(json['d']['id']);
            this._handlers['guildDelete'].forEach((function) => function(false, guild));
          }
        }
      }

      else if (json['t'] == "GUILD_BAN_ADD") {
        if (this.ready) {
          Guild guild = this.guilds[json['d']['guild_id']];
          User user = new User(json['d']['user']);
          this.users[user.id] = user;
          this._handlers['guildBanAdd'].forEach((function) => function(user, guild));
        }
      }

      else if (json['t'] == "GUILD_BAN_REMOVE") {
        if (this.ready) {
          Guild guild = this.guilds[json['d']['guild_id']];
          User user = new User(json['d']['user']);
          this.users[user.id] = user;
          this._handlers['guildBanRemove'].forEach((function) => function(user, guild));
        }
      }

      else if (json['t'] == "GUILD_MEMBER_ADD") {
        if (this.ready) {
          Guild guild = this.guilds[json['d']['guild_id']];
          Member member = new Member(json['d'], guild);
          guild.members[member.user.id] = member;
          this.users[member.user.id] = member.user;
          this._handlers['guildMemberAdd'].forEach((function) => function(member));
        }
      }

      else if (json['t'] == "GUILD_MEMBER_REMOVE") {
        if (this.ready) {
          Guild guild = this.guilds[json['d']['guild_id']];
          User user = new User(json['d']['user']);
          guild.members.remove(user.id);
          this.users[user.id] = user;
          this._handlers['guildMemberRemove'].forEach((function) => function(user, guild));
        }
      }

      else if (json['t'] == "GUILD_MEMBER_UPDATE") {
        if (this.ready) {
          Guild guild = this.guilds[json['d']['guild_id']];
          Member oldMember = guild.members[json['d']['user']['id']];
          Member newMember = new Member(json['d'], guild);
          guild.members[newMember.user.id] = newMember;
          this.users[newMember.user.id] = newMember.user;
          this._handlers['guildMemberUpdate'].forEach((function) => function(oldMember, newMember));
        }
      }

      else if (json['t'] == "CHANNEL_CREATE") {
        if (this.ready) {
          if (json['d']['type'] == 1) {
            PrivateChannel channel = new PrivateChannel(json['d']);
            this.channels[channel.id] = channel;
            this._handlers['channelCreate'].forEach((function) => function(channel));
          } else {
            Guild guild = this.guilds[json['d']['guild_id']];
            GuildChannel channel = new GuildChannel(this, json['d'], guild);
            this.channels[channel.id] = channel;
            this._handlers['channelCreate'].forEach((function) => function(channel));
          }
        }
      }

      else if (json['t'] == "CHANNEL_UPDATE") {
        if (this.ready) {
          GuildChannel oldChannel = this.channels[json['d']['id']];
          Guild guild = this.guilds[json['d']['guild_id']];
          GuildChannel newChannel = new GuildChannel(this, json['d'], guild);
          this.channels[newChannel.id] = newChannel;
          this._handlers['channelUpdate'].forEach((function) => function(oldChannel, newChannel));
        }
      }

      else if (json['t'] == "CHANNEL_DELETE") {
        if (this.ready) {
          if (json['d']['type'] == 1) {
            PrivateChannel oldChannel = new PrivateChannel(json['d']);
            this.channels.remove(oldChannel.id);
            this._handlers['channelDelete'].forEach((function) => function(oldChannel));
          } else {
            Guild guild = this.guilds[json['d']['guild_id']];
            GuildChannel oldChannel = new GuildChannel(this, json['d'], guild);
            this.channels.remove(oldChannel.id);
            this._handlers['channelDelete'].forEach((function) => function(oldChannel));
          }
        }
      }

      else if (json['t'] == "TYPING_START") {
        if (this.ready) {
          GuildChannel channel = this.channels[json['d']['channel_id']];
          User user = this.users[json['d']['user_id']];
          this._handlers['typing'].forEach((function) => function(channel, user, json['d']['timestamp']));
        }
      }
    }
  }

  String _resolve(String to, Object object) {
    if (to == "channel") {
      if (object is Message) {
        return object.channel.id;
      } else if (object is GuildChannel) {
        return object.id;
      } else if (object is PrivateChannel) {
        return object.id;
      } else if (object is Guild) {
        return object.defaultChannel.id;
      } else {
        return object;
      }
    }

    else if (to == "message") {
      if (object is Message) {
        return object.id;
      } else {
        return object;
      }
    }

    else if (to == "guild") {
      if (object is Message) {
        return object.guild.id;
      } else if (object is GuildChannel) {
        return object.guild.id;
      } else if (object is Guild) {
        return object.id;
      } else {
        return object;
      }
    }

    else if (to == "user") {
      if (object is Message) {
        return object.author.id;
      } else if (object is User) {
        return object.id;
      } else if (object is Member) {
        return object.user.id;
      } else {
        return object;
      }
    }

    else if (to == "member") {
      if (object is Message) {
        return object.author.id;
      } else if (object is User) {
        return object.id;
      } else if (object is Member) {
        return object.user.id;
      } else {
        return object;
      }
    }

    else if (to == "app") {
      if (object is User) {
        return object.id;
      } else if (object is Member) {
        return object.user.id;
      } else {
        return object;
      }
    }

    else {
      return null;
    }
  }

  Client(String token, [ClientOptions options]) {
    if (options == null) {
      this.options = new ClientOptions();
    } else {
      this.options = options;
    }

    this.token = token;

    WebSocket.connect('wss://gateway.discord.gg?v=6&encoding=json').then((socket) {
      this._socket = socket;
      this._socket.listen(this._handleMsg);
    });
  }

  /// Used for registering event handlers.
  ///
  /// Returns the index of the current handler.
  ///     Client.onEvent("message", (m) {
  ///       print(m.content);
  ///     })
  int onEvent(String event, function) {
    if (this._handlers.keys.contains(event)) {
      this._handlers[event].add(function);
      return this._handlers[event].indexOf(function);
    } else {
      throw new Exception("invalid event handler '$event'");
    }
  }

  /// Sends a message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.sendMessage("channel id", "My content!");
  Future<Message> sendMessage(Object channel, String content, [MessageOptions options]) async {
    if (this.ready) {
      if (options == null) {
        options = new MessageOptions();
      }

      if (options.disableEveryone || (options.disableEveryone == null && this.options.disableEveryone)) {
        content = content.replaceAll("@everyone", "@\u200Beveryone").replaceAll("@here", "@\u200Bhere");
      }

      String id = this._resolve("channel", channel);

      var r = await this._api.post('channels/$id/messages', {"content": content, "tts": options.tts, "nonce": options.nonce});
      Map res = JSON.decode(r.body);

      if (r.statusCode == 200) {
        return new Message(this, res);
      } else {
        throw new Exception("${res['code']}: ${res['message']}");
      }
    } else {
      throw new Exception("the client isn't ready");
    }
  }

  /// Deletes a message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.sendMessage("channel id", "message id");
  Future<bool> deleteMessage(Object channel, Object message) async {
    if (this.ready) {
      channel = this._resolve('channel', channel);
      message = this._resolve('message', message);

      var r = await this._api.delete('channels/$channel/messages/$message');

      if (r.statusCode == 204) {
        return true;
      } else {
        throw new Exception("'deleteMessage' error.");
      }
    } else {
      throw new Exception("the client isn't ready");
    }
  }

  /// Edits a message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.sendMessage("channel id", "message id", "My edited content!");
  Future<Message> editMessage(Object channel, Object message, String content, [MessageOptions options]) async {
    if (this.ready) {
      if (options == null) {
        options = new MessageOptions();
      }

      if (options.disableEveryone || (options.disableEveryone == null && this.options.disableEveryone)) {
        content = content.replaceAll("@everyone", "@\u200Beveryone").replaceAll("@here", "@\u200Bhere");
      }

      channel = this._resolve('channel', channel);
      message = this._resolve('message', message);

      var r = await this._api.patch('channels/$channel/messages/$message', {"content": content});
      Map res = JSON.decode(r.body);

      if (r.statusCode == 200) {
        return new Message(this, res);
      } else {
        throw new Exception("${res['code']}:${res['message']}");
      }
    } else {
      throw new Exception("the client isn't ready");
    }
  }

  /// Gets a [Member] object. Adds it to `Client.guilds["guild id"].members` if
  /// not already there.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.getMember("guild id", "user id");
  Future<Member> getMember(Object guild, Object member) async {
    if (this.ready) {

      guild = this._resolve('guild', guild);
      member = this._resolve('member', member);

      if (this.guilds[guild].members[member] != null) {
        return this.guilds[guild].members[member];
      } else {
        var r = await this._api.get('guilds/$guild/members/$member');
        Map res = JSON.decode(r.body);
        if (r.statusCode == 200) {
          Member m = new Member(res, this.guilds[guild]);
          this.guilds[guild].members[m.user.id] = m;
          return m;
        } else {
          throw new Exception("${res['code']}:${res['message']}");
        }
      }
    } else {
      throw new Exception("the client isn't ready");
    }
  }

  /// Gets a [User] object.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.getUser("user id");
  Future<User> getUser(Object user) async {
    if (this.ready) {
      user = this._resolve('user', user);

      var r = await this._api.get('users/$user');
      Map res = JSON.decode(r.body);
      if (r.statusCode == 200) {
        return new User(res);
      } else {
        throw new Exception("${res['code']}:${res['message']}");
      }
    } else {
      throw new Exception("the client isn't ready");
    }
  }

  /// Gets an [Invite] object.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.getInvite("invite code");
  Future<Invite> getInvite(String code) async {
    if (this.ready) {
      var r = await this._api.get('invites/$code');
      Map res = JSON.decode(r.body);
      if (r.statusCode == 200) {
        return new Invite(res);
      } else {
        throw new Exception("${res['code']}:${res['message']}");
      }
    } else {
      throw new Exception("the client isn't ready");
    }
  }

  /// Gets a [Message] object. Only usable by bot accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is not a bot.
  ///     Client.getMessage("channel id", "message id");
  Future<Message> getMessage(Object channel, String message) async {
    if (this.ready) {
      if (this.user.bot) {
        channel = this._resolve('channel', channel);
        message = this._resolve('message', message);

        var r = await this._api.get('channels/$channel/messages/$message');
        Map res = JSON.decode(r.body);
        if (r.statusCode == 200) {
          return new Message(this, res);
        } else {
          throw new Exception("${res['code']}:${res['message']}");
        }
      } else {
        throw new Exception("'getMessage' is only usable by bot accounts.");
      }
    } else {
      throw new Exception("the client isn't ready");
    }
  }

  /// Gets an [OAuth2Info] object.
  ///
  /// Throws an [Exception] if the HTTP request errored
  ///     Client.getOAuth2Info("app id");
  Future<OAuth2Info> getOAuth2Info(Object app) async {
    if (this.ready) {
      app = this._resolve('app', app);

      var r = await this._api.get('oauth2/authorize?client_id=$app&scope=bot');
      Map res = JSON.decode(r.body);
      if (r.statusCode == 200) {
        return new OAuth2Info(res);
      } else {
        throw new Exception("${res['code']}:${res['message']}");
      }
    } else {
      throw new Exception("the client isn't ready");
    }
  }

  /// Invites a bot to a guild. Only usable by user accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is a bot.
  ///     Client.oauth2Authorize("app id", "guild id");
  Future<bool> oauth2Authorize(Object app, Object guild, [int permissions = 0]) async {
    if (this.ready) {
      if (!this.user.bot) {
        app = this._resolve('app', app);
        guild = this._resolve('guild', guild);

        var r = await this._api.post('oauth2/authorize?client_id=$app&scope=bot', {"guild_id": guild, "permissions": permissions, "authorize": true});
        Map res = JSON.decode(r.body);
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
