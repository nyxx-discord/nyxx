import 'dart:convert';
import 'dart:async';
import '../discord.dart';
import 'internal.dart';
import 'package:http/http.dart' as http;

/// The base class.
/// It contains all of the methods.
class Client {
  /// The token passed into the constructor.
  String token;

  /// The client's options.
  ClientOptions options;

  /// The logged in user.
  ClientUser user;

  /// The bot's OAuth2 app.
  ClientOAuth2Application app;

  /// All of the guilds the bot is in.
  Collection<Guild> guilds;

  /// All of the channels the bot is in. Either a [GuildChannel] or
  /// [PrivateChannel].
  Collection<dynamic> channels;

  /// All of the users the bot can see. Does not always have offline users
  /// without forceFetchUsers enabled.
  Collection<User> users;

  /// Whether or not the client is ready.
  bool ready = false;

  /// The current version.
  String version = "0.11.1+dev";

  /// The client's internals.
  InternalClient internal;

  /// The client's SS manager, null if the client is not sharded, [SSServer] if
  /// the current shard is 0, [SSClient] otherwise.
  dynamic ss;

  /// Emitted when the client is ready.
  Stream<ReadyEvent> onReady;

  /// Emitted when a message is received.
  Stream<MessageEvent> onMessage;

  /// Emitted when a message is edited.
  Stream<MessageUpdateEvent> onMessageUpdate;

  /// Emitted when a message is deleted.
  Stream<MessageDeleteEvent> onMessageDelete;

  /// Emitted when a channel is created.
  Stream<ChannelCreateEvent> onChannelCreate;

  /// Emitted when a channel is updated.
  Stream<ChannelUpdateEvent> onChannelUpdate;

  /// Emitted when a channel is deleted.
  Stream<ChannelDeleteEvent> onChannelDelete;

  /// Emitted when a member is banned.
  Stream<GuildBanAddEvent> onGuildBanAdd;

  /// Emitted when a user is unbanned.
  Stream<GuildBanRemoveEvent> onGuildBanRemove;

  /// Emitted when the client joins a guild.
  Stream<GuildCreateEvent> onGuildCreate;

  /// Emitted when a guild is updated..
  Stream<GuildUpdateEvent> onGuildUpdate;

  /// Emitted when the client leaves a guild.
  Stream<GuildDeleteEvent> onGuildDelete;

  /// Emitted when a guild becomes unavailable.
  Stream<GuildUnavailableEvent> onGuildUnavailable;

  /// Emitted when a member joins a guild.
  Stream<GuildMemberAddEvent> onGuildMemberAdd;

  /// Emitted when a member is updated.
  Stream<GuildMemberUpdateEvent> onGuildMemberUpdate;

  /// Emitted when a user leaves a guild.
  Stream<GuildMemberRemoveEvent> onGuildMemberRemove;

  /// Emitted when a user starts typing.
  Stream<TypingEvent> onTyping;

  /// Creates and logs in a new client.
  Client(this.token, [this.options]) {
    if (this.options == null) {
      this.options = new ClientOptions();
    }

    this.guilds = new Collection<Guild>();
    this.channels = new Collection<dynamic>();
    this.users = new Collection<User>();

    new InternalClient(this);

    if (this.options.shardCount > 1) {
      if (this.options.shardId == 0) {
        this.ss = new SSServer(this);
      } else {
        this.ss = new SSClient(this);
      }
    }
  }

  /// Destroys the websocket connection, SS connection or server, and all streams.
  Future<Null> destroy() async {
    await this.internal.ws.socket.close();
    this.internal.http.http.close();
    await this.internal.events.destroy();
    if (this.ss is SSServer) {
      await this.ss.close();
    } else if (this.ss is SSClient) {
      this.ss.destroy();
    }
    return null;
  }

  /// Gets a [User] object.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.getUser("user id");
  Future<User> getUser(dynamic user) async {
    if (this.ready) {
      final String id = this.internal.util.resolve('user', user);

      final http.Response r = await this.internal.http.get('users/$id');
      final res = JSON.decode(r.body) as Map<String, dynamic>;

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
      final http.Response r = await this.internal.http.get('invites/$code');
      final res = JSON.decode(r.body) as Map<String, dynamic>;

      if (r.statusCode == 200) {
        return new Invite(this, res);
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
      final String id = this.internal.util.resolve('app', app);

      final http.Response r = await this
          .internal
          .http
          .get('oauth2/authorize?client_id=$id&scope=bot');
      final res = JSON.decode(r.body) as Map<String, dynamic>;

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
