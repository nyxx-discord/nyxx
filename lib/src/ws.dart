import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../discord.dart';
import 'package:http/http.dart' as http;

/// The WS manager for the client.
class WS {
  /// The base websocket URL.
  String gateway;

  /// The client that the WS manager belongs to.
  Client client;

  /// The websocket connection.
  WebSocket socket;

  /// The last sequence sent to the WS manager.
  int sequence;

  /// The session ID.
  String sessionID;

  /// Makes a new WS manager.
  WS(this.client) {
    this.client.http.get('gateway').then((http.Response r) {
      this.gateway = JSON.decode(r.body)['url'];
      this.connect();
    }).catchError((Error err) {
      throw new Exception("could not get '/gateway'");
    });
  }

  void connect([bool resume = true]) {
    if (this.socket != null) {
      this.socket.close();
    }
    WebSocket.connect('${this.gateway}?v=6&encoding=json').then((WebSocket socket) {
      this.socket = socket;
      this.socket.listen((String msg) => this._handleMsg(msg, resume), onDone: () => this._handleErr());
    });
  }

  void send(int op, dynamic d) {
    this.socket.add(JSON.encode(<String, dynamic>{
      "op": op,
      "d": d
    }));
  }

  void heartbeat() {
    this.send(1, this.sequence);
  }

  Future<Null> _handleMsg(String msg, bool resume) async {
    final Map<String, dynamic> json = JSON.decode(msg);

    if (json['s'] != null) {
      this.sequence = json['s'];
    }

    if (json["op"] == 10) {
      const Duration heartbeatInterval = const Duration(milliseconds: 41250);
      new Timer.periodic(heartbeatInterval, (Timer t) => this.heartbeat());

      if (this.sessionID == null || !resume) {
        this.client.ready = false;
        this.send(2, <String, dynamic>{
          "token": this.client.token,
          "properties": <String, dynamic>{
            "\$browser": "Discord Dart"
          },
          "large_threshold": 100,
          "compress": false,
          "shard": [this.client.options.shardId, this.client.options.shardCount]
        });
      } else if (resume) {
        this.send(6, <String, dynamic>{
          "token": this.client.token,
          "session_id": this.sessionID,
          "seq": this.sequence
        });
      }
    }

    else if (json["op"] == 9) {
      this.connect(false);
    }

    else if (json["op"] == 0) {
      if (json['t'] == "READY") {
        this.sessionID = json['d']['session_id'];
        this.client.user = new ClientUser(json['d']['user']);

        json['d']['guilds'].forEach((Map<String, dynamic> o) {
          this.client.guilds.map[o['id']] = null;
        });

        json['d']['private_channels'].forEach((Map<String, dynamic> o) {
          this.client.channels.add(new PrivateChannel(client, o));
        });

        if (this.client.user.bot) {
          this.client.http.headers['Authorization'] = "Bot ${this.client.token}";

          final http.Response r = await this.client.http.get('oauth2/applications/@me');
          final Map<String, dynamic> res = JSON.decode(r.body);

          if (r.statusCode == 200) {
            this.client.app = new ClientOAuth2Application(client, res);
          }
        } else {
          this.client.http.headers['Authorization'] = this.client.token;
        }
      }

      switch (json['t']) {
        case 'MESSAGE_CREATE':
          new MessageEvent(this.client, json);
          break;

        case 'MESSAGE_DELETE':
          new MessageDeleteEvent(this.client, json);
          break;

        case 'MESSAGE_UPDATE':
          new MessageUpdateEvent(this.client, json);
          break;

        case 'GUILD_CREATE':
          new GuildCreateEvent(this.client, json);
          break;

        case 'GUILD_UPDATE':
          new GuildUpdateEvent(this.client, json);
          break;

        case 'GUILD_DELETE':
          new GuildDeleteEvent(this.client, json);
          break;

        case 'GUILD_BAN_ADD':
          new GuildBanAddEvent(this.client, json);
          break;

        case 'GUILD_BAN_REMOVE':
          new GuildBanRemoveEvent(this.client, json);
          break;

        case 'GUILD_MEMBER_ADD':
          new GuildMemberAddEvent(this.client, json);
          break;

        case 'GUILD_MEMBER_REMOVE':
          new GuildMemberRemoveEvent(this.client, json);
          break;

        case 'GUILD_MEMBER_UPDATE':
          new GuildMemberUpdateEvent(this.client, json);
          break;

        case 'CHANNEL_CREATE':
          new ChannelCreateEvent(this.client, json);
          break;

        case 'CHANNEL_UPDATE':
          new ChannelUpdateEvent(this.client, json);
          break;

        case 'CHANNEL_DELETE':
          new ChannelDeleteEvent(this.client, json);
          break;

        case 'TYPING_START':
          new TypingEvent(this.client, json);
          break;
      }
    }

    return null;
  }

  void _handleErr() {
    switch (this.socket.closeCode) {
      case 1005:
        return;

      case 4004:
        throw new Exception("invalid token");

      case 4010:
        throw new Exception("invalid shard");

      case 4007:
        new WebSocketErrorEvent(this.client, this.socket.closeCode);
        this.connect(false);
        return;

      case 4009:
        new WebSocketErrorEvent(this.client, this.socket.closeCode);
        this.connect(false);
        return;

      default:
        new WebSocketErrorEvent(this.client, this.socket.closeCode);
        this.connect();
        return;
    }
  }
}
