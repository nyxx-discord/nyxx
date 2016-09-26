import 'dart:convert';
import 'dart:async';
import 'http.dart';
import 'ws.dart';
import '../discord.dart';
import 'package:events/events.dart' as events;
import 'package:http/http.dart' as http;

/// The base class.
/// It contains all of the methods.
class Client extends events.Events {
  /// The token passed into the constructor.
  String token;

  /// The client's options.
  ClientOptions options;

  /// The logged in user.
  ClientUser user;

  /// The bot's OAuth2 app.
  ClientOAuth2Application app;

  /// All of the guilds the bot is in.
  Collection guilds;

  /// All of the channels the bot is in. Either a [GuildChannel] or
  /// [PrivateChannel].
  Collection channels;

  /// All of the users the bot can see. Does not always have offline users
  /// without forceFetchUsers enabled.
  Collection users;

  /// Whether or not the client is ready.
  bool ready = false;

  /// The current version.
  String version = "0.8.0";

  /// The client's HTTP manager, this is for use internally.
  HTTP http;

  /// The client's WS manager, this is for use internally.
  WS ws;

  /// Creates and logs in a new client.
  Client(this.token, [this.options]) {
    this.guilds = new Collection();
    this.channels = new Collection();
    this.users = new Collection();

    this.http = new HTTP(this);
    this.ws = new WS(this);

    if (this.options == null) {
      this.options = new ClientOptions();
    }
  }

  /// Resolves an object into a target object, this is for use internally.
  String resolve(String to, dynamic object) {
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
        return object.toString();
      }
    }

    else if (to == "message") {
      if (object is Message) {
        return object.id;
      } else {
        return object.toString();
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
        return object.toString();
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
        return object.toString();
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
        return object.toString();
      }
    }

    else if (to == "app") {
      if (object is User) {
        return object.id;
      } else if (object is Member) {
        return object.user.id;
      } else {
        return object.toString();
      }
    }

    else {
      return null;
    }
  }

  /// Gets a [User] object.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.getUser("user id");
  Future<User> getUser(dynamic user) async {
    if (this.ready) {
      final String id = this.resolve('user', user);

      final http.Response r = await this.http.get('users/$id');
      final Map<String, dynamic> res = JSON.decode(r.body);

      if (r.statusCode == 200) {
        return new User(this, res);
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
      final http.Response r = await this.http.get('invites/$code');
      final Map<String, dynamic> res = JSON.decode(r.body);

      if (r.statusCode == 200) {
        return new Invite(res);
      } else {
        throw new Exception("${res['code']}:${res['message']}");
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
      final String id = this.resolve('app', app);

      final http.Response r = await this.http.get('oauth2/authorize?client_id=$id&scope=bot');
      final Map<String, dynamic> res = JSON.decode(r.body);

      if (r.statusCode == 200) {
        return new OAuth2Info(this, res);
      } else {
        throw new Exception("${res['code']}:${res['message']}");
      }
    } else {
      throw new Exception("the client isn't ready");
    }
  }
}
