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
    "loginError": []
  };

  /// The token passed into the constructor.
  String token;

  /// The client's options.
  ClientOptions options;

  /// The logged in user.
  ClientUser user;

  /// The bot's OAuth2 app.
  ClientOAuth2Application app;

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

        this._handlers['ready'].forEach((function) => function());
      }

      else if (json['t'] == "MESSAGE_CREATE") {
        Message message = new Message(json['d']);
        this._handlers['message'].forEach((function) => function(message));
      }

      else if (json['t'] == "MESSAGE_DELETE") {
        this._handlers['messageDelete'].forEach((function) => function(json['d']['id'], json['d']['channel_id']));
      }

      else if (json['t'] == "MESSAGE_UPDATE") {
        if (!json['d'].containsKey('embeds')) {
          Message message = new Message(json['d']);
          this._handlers['messageEdit'].forEach((function) => function(message));
        }
      }

      /*else if (json['t'] == "GUILD_CREATE") {
        Guild guild = new Guild(json['d'], true);
        this.guilds[guild.id] =  guild;

        //this._handlers['message'].forEach((function) => function(message));
      }*/
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
  Future<Message> sendMessage(String channel, String content, [MessageOptions options]) async {
    if (options == null) {
      options = new MessageOptions();
    }

    if (options.disableEveryone || (options.disableEveryone == null && this.options.disableEveryone)) {
      content = content.replaceAll("@everyone", "@\u200Beveryone").replaceAll("@here", "@\u200Bhere");
    }

    var r = await this._api.post('channels/$channel/messages', {"content": content, "tts": options.tts, "nonce": options.nonce});
    Map res = JSON.decode(r.body);

    if (r.statusCode == 200) {
      return new Message(res);
    } else {
      throw new Exception("${res['code']}: ${res['message']}");
    }
  }

  /// Deletes a message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.sendMessage("channel id", "message id");
  Future<bool> deleteMessage(String channel, String message) async {
    var r = await this._api.delete('channels/$channel/messages/$message');

    if (r.statusCode == 204) {
      return true;
    } else {
      throw new Exception("'deleteMessage' error.");
    }
  }

  /// Edits a message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.sendMessage("channel id", "message id", "My edited content!");
  Future<Message> editMessage(String channel, String message, String content) async {
    var r = await this._api.patch('channels/$channel/messages/$message', {"content": content});
    Map res = JSON.decode(r.body);

    if (r.statusCode == 200) {
      return new Message(res);
    } else {
      throw new Exception("${res['code']}:${res['message']}");
    }
  }

  /// Gets a [Channel] object.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.getChannel("channel id");
  Future<Channel> getChannel(String id) async {
    var r = await this._api.get('channels/$id');
    Map res = JSON.decode(r.body);
    if (r.statusCode == 200) {
      return new Channel(res);
    } else {
      throw new Exception("${res['code']}:${res['message']}");
    }
  }

  /// Gets a [Guild] object.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.getGuild("guild id");
  Future<Guild> getGuild(String id) async {
    var r = await this._api.get('guilds/$id');
    Map res = JSON.decode(r.body);
    if (r.statusCode == 200) {
      return new Guild(res, false);
    } else {
      throw new Exception("${res['code']}:${res['message']}");
    }
  }

  /// Gets a [Member] object.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.getMember("guild id", "user id");
  Future<Member> getMember(String guild, String member) async {
    var r = await this._api.get('guilds/$guild/members/$member');
    Map res = JSON.decode(r.body);
    if (r.statusCode == 200) {
      return new Member(res);
    } else {
      throw new Exception("${res['code']}:${res['message']}");
    }
  }

  /// Gets a [User] object.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.getUser("user id");
  Future<User> getUser(String id) async {
    var r = await this._api.get('users/$id');
    Map res = JSON.decode(r.body);
    if (r.statusCode == 200) {
      return new User(res);
    } else {
      throw new Exception("${res['code']}:${res['message']}");
    }
  }

  /// Gets an [Invite] object.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.getInvite("invite code");
  Future<Invite> getInvite(String code) async {
    var r = await this._api.get('invites/$code');
    Map res = JSON.decode(r.body);
    if (r.statusCode == 200) {
      return new Invite(res);
    } else {
      throw new Exception("${res['code']}:${res['message']}");
    }
  }

  /// Gets a [Message] object. Only usable by bot accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is not a bot.
  ///     Client.getMessage("channel id", "message id");
  Future<Message> getMessage(String channel, String message) async {
    if (this.user.bot) {
      var r = await this._api.get('channels/$channel/messages/$message');
      Map res = JSON.decode(r.body);
      if (r.statusCode == 200) {
        return new Message(res);
      } else {
        throw new Exception("${res['code']}:${res['message']}");
      }
    } else {
      throw new Exception("'getMessage' is only usable by bot accounts.");
    }
  }

  /// Gets an [OAuth2Info] object. Only usable by user accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is a bot.
  ///     Client.getOAuth2Info("app id");
  Future<OAuth2Info> getOAuth2Info(String id) async {
    if (!this.user.bot) {
      var r = await this._api.get('oauth2/authorize?client_id=$id&scope=bot');
      Map res = JSON.decode(r.body);
      if (r.statusCode == 200) {
        return new OAuth2Info(res);
      } else {
        throw new Exception("${res['code']}:${res['message']}");
      }
    } else {
      throw new Exception("'getMessage' is only usable by user accounts.");
    }
  }

  /// Gets an [OAuth2Info] object. Only usable by user accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is a bot.
  ///     Client.getOAuth2Info("app id");
  Future<bool> oauth2Authorize(String app, String guild, [int permissions = 0]) async {
    if (!this.user.bot) {
      var r = await this._api.post('oauth2/authorize?client_id=$app&scope=bot', {"guild_id": guild, "permissions": permissions, "authorize": true});
      Map res = JSON.decode(r.body);
      if (r.statusCode == 200) {
        return true;
      } else {
        throw new Exception("${res['code']}:${res['message']}");
      }
    } else {
      throw new Exception("'getMessage' is only usable by user accounts.");
    }
  }
}
