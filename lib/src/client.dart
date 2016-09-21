import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../objects.dart';
import '../events.dart';
import 'http.dart';
import 'package:events/events.dart' as events;
import 'package:http/http.dart' as http;


/// The base class.
/// It contains all of the methods.
class Client extends events.Events {
  WebSocket _socket;
  int _lastS;
  String _sessionID;
  API _api = new API();

  /// The token passed into the constructor.
  String token;

  /// The client's options.
  ClientOptions options;

  /// The logged in user.
  ClientUser user;

  /// The bot's OAuth2 app.
  ClientOAuth2Application app;

  /// A map of all the guilds the bot is in, by id.
  Map<String, Guild> guilds = <String, Guild>{};

  /// A map of all the channels the bot is in, by id. Either a [GuildChannel] or
  /// [PrivateChannel].
  Map<String, dynamic> channels = <String, dynamic>{};

  /// A map of all of the users the bot can see, by id. Does not always have
  /// offline users without forceFetchUsers enabled.
  Map<String, User> users = <String, User>{};

  /// Whether or not the client is ready.
  bool ready = false;

  /// Creates and logs in a new client.
  Client(this.token, [this.options]) {
    if (this.options == null) {
      this.options = new ClientOptions();
    }

    WebSocket.connect('wss://gateway.discord.gg?v=6&encoding=json').then((WebSocket socket) {
      this._socket = socket;
      this._socket.listen(this._handleMsg);
    });
  }

  void _heartbeat() {
    this._socket.add(JSON.encode(<String, dynamic>{"op": 1,"d": this._lastS}));
  }

  Future<Null> _handleMsg(String msg) async {
    Map<String, dynamic> json = JSON.decode(msg);

    if (json['s'] != null) {
      this._lastS = json['s'];
    }

    //const ms = const JSON.decode(msg)["d"]["heartbeat_interval"];

    if (json["op"] == 10) {
      const Duration heartbeatInterval = const Duration(milliseconds: 41250);
      new Timer.periodic(heartbeatInterval, (Timer t) => this._heartbeat());

      this._socket.add(JSON.encode(<String, dynamic>{
        "op": 2,
        "d": <String, dynamic>{
          "token": this.token,
          "properties": <String, dynamic>{
            "\$browser": "Discord Dart"
          },
          "large_threshold": 100,
          "compress": false
        }
      }));
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

        json['d']['guilds'].forEach((Map<String, dynamic> o) {
          this.guilds[o['id']] = null;
        });

        json['d']['private_channels'].forEach((Map<String, dynamic> o) {
          PrivateChannel channel = new PrivateChannel(o);
          this.channels[channel.id] = channel;
        });

        if (this.user.bot) {
          this._api.headers['Authorization'] = "Bot ${this.token}";

          http.Response r = await this._api.get('oauth2/applications/@me');
          Map<String, dynamic> res = JSON.decode(r.body);
          if (r.statusCode == 200) {
            this.app = new ClientOAuth2Application(res);
          }
        } else {
          this._api.headers['Authorization'] = this.token;
        }
      }

      switch (json['t']) {
        case 'MESSAGE_CREATE':
          new MessageEvent(this, json);
          break;

        case 'MESSAGE_DELETE':
          new MessageDeleteEvent(this, json);
          break;

        case 'MESSAGE_UPDATE':
          new MessageUpdateEvent(this, json);
          break;

        case 'GUILD_CREATE':
          new GuildCreateEvent(this, json);
          break;

        case 'GUILD_UPDATE':
          new GuildUpdateEvent(this, json);
          break;

        case 'GUILD_DELETE':
          new GuildDeleteEvent(this, json);
          break;

        case 'GUILD_BAN_ADD':
          new GuildBanAddEvent(this, json);
          break;

        case 'GUILD_BAN_REMOVE':
          new GuildBanRemoveEvent(this, json);
          break;

        case 'GUILD_MEMBER_ADD':
          new GuildMemberAddEvent(this, json);
          break;

        case 'GUILD_MEMBER_REMOVE':
          new GuildMemberRemoveEvent(this, json);
          break;

        case 'GUILD_MEMBER_UPDATE':
          new GuildMemberUpdateEvent(this, json);
          break;

        case 'CHANNEL_CREATE':
          new ChannelCreateEvent(this, json);
          break;

        case 'CHANNEL_UPDATE':
          new ChannelUpdateEvent(this, json);
          break;

        case 'CHANNEL_DELETE':
          new ChannelDeleteEvent(this, json);
          break;

        case 'TYPING_START':
          new TypingEvent(this, json);
          break;
      }
    }

    return null;
  }

  String _resolve(String to, dynamic object) {
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

  /// Sends a message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.sendMessage("channel id", "My content!");
  Future<Message> sendMessage(dynamic channel, String content, [MessageOptions options]) async {
    if (this.ready) {
      if (options == null) {
        options = new MessageOptions();
      }

      if (options.disableEveryone || (options.disableEveryone == null && this.options.disableEveryone)) {
        content = content.replaceAll("@everyone", "@\u200Beveryone").replaceAll("@here", "@\u200Bhere");
      }

      String id = this._resolve("channel", channel);

      http.Response r = await this._api.post('channels/$id/messages', <String, dynamic>{"content": content, "tts": options.tts, "nonce": options.nonce});
      Map<String, dynamic> res = JSON.decode(r.body);

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
  Future<bool> deleteMessage(dynamic channel, dynamic message) async {
    if (this.ready) {
      channel = this._resolve('channel', channel);
      message = this._resolve('message', message);

      http.Response r = await this._api.delete('channels/$channel/messages/$message');

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
  Future<Message> editMessage(dynamic channel, dynamic message, String content, [MessageOptions options]) async {
    if (this.ready) {
      if (options == null) {
        options = new MessageOptions();
      }

      if (options.disableEveryone || (options.disableEveryone == null && this.options.disableEveryone)) {
        content = content.replaceAll("@everyone", "@\u200Beveryone").replaceAll("@here", "@\u200Bhere");
      }

      channel = this._resolve('channel', channel);
      message = this._resolve('message', message);

      http.Response r = await this._api.patch('channels/$channel/messages/$message', <String, dynamic>{"content": content});
      Map<String, dynamic> res = JSON.decode(r.body);

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
  Future<Member> getMember(dynamic guild, dynamic member) async {
    if (this.ready) {

      guild = this._resolve('guild', guild);
      member = this._resolve('member', member);

      if (this.guilds[guild].members[member] != null) {
        return this.guilds[guild].members[member];
      } else {
        http.Response r = await this._api.get('guilds/$guild/members/$member');
        Map<String, dynamic> res = JSON.decode(r.body);
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
  Future<User> getUser(dynamic user) async {
    if (this.ready) {
      user = this._resolve('user', user);

      http.Response r = await this._api.get('users/$user');
      Map<String, dynamic> res = JSON.decode(r.body);
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
      http.Response r = await this._api.get('invites/$code');
      Map<String, dynamic> res = JSON.decode(r.body);
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
  Future<Message> getMessage(dynamic channel, String message) async {
    if (this.ready) {
      if (this.user.bot) {
        channel = this._resolve('channel', channel);
        message = this._resolve('message', message);

        http.Response r = await this._api.get('channels/$channel/messages/$message');
        Map<String, dynamic> res = JSON.decode(r.body);
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
  Future<OAuth2Info> getOAuth2Info(dynamic app) async {
    if (this.ready) {
      app = this._resolve('app', app);

      http.Response r = await this._api.get('oauth2/authorize?client_id=$app&scope=bot');
      Map<String, dynamic> res = JSON.decode(r.body);
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
  Future<bool> oauth2Authorize(dynamic app, dynamic guild, [int permissions = 0]) async {
    if (this.ready) {
      if (!this.user.bot) {
        app = this._resolve('app', app);
        guild = this._resolve('guild', guild);

        http.Response r = await this._api.post('oauth2/authorize?client_id=$app&scope=bot', <String, dynamic>{"guild_id": guild, "permissions": permissions, "authorize": true});
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
