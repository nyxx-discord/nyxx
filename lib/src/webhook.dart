import 'dart:async';
import 'dart:convert';
import '../discord.dart';
import 'internal/util.dart';
import 'package:http/http.dart' as http_lib;

/// The HTTP manager for the client.
class HTTP {
  /// The base API URL.
  String host;

  /// A map of headers that get sent on each HTTP request.
  Map<String, String> headers;

  /// The HTTP client.
  http_lib.Client http;

  /// Makes a new HTTP manager.
  HTTP(Client client) {
    this.http = new http_lib.Client();
    this.headers = <String, String>{
      'User-Agent':
          'Discord Dart Webhooks (https://github.com/Hackzzila/Discord-Dart, ${client.version})',
      'Content-Type': 'application/json'
    };
  }

  /// Sends a GET request.
  Future<http_lib.Response> get() async {
    return await this.http.get(this.host, headers: this.headers);
  }

  /// Sends a POST request.
  Future<http_lib.Response> post(Object content) async {
    return await this.http.post(this.host,
        body: JSON.encode(content), headers: this.headers);
  }

  /// Sends a PATCH request.
  Future<http_lib.Response> patch(Object content) async {
    return await this.http.patch(this.host,
        body: JSON.encode(content), headers: this.headers);
  }

  /// Sends a DELETE request.
  Future<http_lib.Response> delete() async {
    return await this.http.delete(this.host, headers: this.headers);
  }
}


/// A webhook client.
class Client  {
  /// The HTTP client.
  HTTP http;

  /// The version.
  String version = "0.11.1+dev";

  /// Emitted when data is received about the webhook and all properties are filled.
  Stream<Null> onReady;

   /// The webhook's name.
  String name;

  /// The webhook's id.
  String id;

  /// The webhook's token.
  String token;

  /// The webhook's channel id.
  String channelId;

  /// The webhook's guild id.
  String guildId;

  /// When the webhook was created;
  DateTime createdAt;

  /// Sets up a new webhook client.
  Client({url, id, token}) {
    StreamController<Null> onReady = new StreamController.broadcast();
    this.onReady = onReady.stream; 
    this.http = new HTTP(this);
    if (url == null) {
      this.http.host = "https://discordapp.com/api/webhooks/$id/$token";
    } else {
      this.http.host = url;
    }
    
    this.http.get().then((http_lib.Response r) {
      if (r.statusCode == 200) {
        dynamic data = JSON.decode(r.body);
        this.name= data['name'];
        this.id = data['id'];
        this.token = data['token'];
        this.channelId = data['channel_id'];
        this.guildId  = data['guild_id'];    

        Util util = new Util();
        this.createdAt = util.getDate(this.id);
        onReady.add(null);
      } else {
        throw new HttpError(r);
      }
    });
  }

  /// Sends a message with the webhook.
  Future<Null> sendMessage({String content, Null file, List<Map<String, dynamic>> embeds, String username, String avatarUrl, bool tts}) async {
    http_lib.Response r = await this.http.post({"content": content, "username": username, "avatar_url": avatarUrl, "tts": tts, "embeds": embeds});
    if (r.statusCode == 204) {
      return null;
    } else {
      throw new HttpError(r);
    }
  }

  /// Deletes the webhook.
  Future<Null> delete() async {
    http_lib.Response r = await this.http.delete();
    if (r.statusCode == 204) {
      return null;
    } else {
      throw new HttpError(r);
    }
  }

  /// Edits the webhook.
  Future<Null> edit({String name, List<int> avatar}) async {
    http_lib.Response r = await this.http.patch({"name": name, "avatar": avatar});
  
    if (r.statusCode == 200) {
      dynamic data = JSON.decode(r.body);
      this.name= data['name'];
      this.id = data['id'];
      this.token = data['token'];
      this.channelId = data['channel_id'];
      this.guildId  = data['guild_id'];    

      Util util = new Util();
      this.createdAt = util.getDate(this.id);
    } else {
      throw new HttpError(r);
    }
  }
}