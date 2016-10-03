import 'dart:async';
import 'dart:convert';
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
  Future<http_lib.Response> get(String uri) async {
    return await this.http.get("${this.host}/$uri", headers: this.headers);
  }

  /// Sends a POST request.
  Future<http_lib.Response> post(String uri, Object content) async {
    print("${this.host}/$uri");
    return await this.http.post("${this.host}",
        body: JSON.encode(content), headers: this.headers);
  }

  /// Sends a PATCH request.
  Future<http_lib.Response> patch(String uri, Object content) async {
    return await this.http.patch("${this.host}/$uri",
        body: JSON.encode(content), headers: this.headers);
  }

  /// Sends a DELETE request.
  Future<http_lib.Response> delete(String uri) async {
    return await this.http.delete("${this.host}/$uri", headers: this.headers);
  }
}


/// A webhook client.
class Client  {
  /// The HTTP client.
  HTTP http;

  /// The version.
  String version = "0.11.1+dev";

  /// Sets up a new webhook client.
  Client({url, id, token}) {
    this.http = new HTTP(this);
    if (url == null) {
      this.http.host = "https://discordapp.com/api/webhooks/$id/$token";
    } else {
      this.http.host = url;
    }
  }

  Future<Null> sendMessage({String content, Null file, Null embed, String username, String avatarUrl, bool tts}) async {
    http.Response r = await this.http.post("", {"content": content, "username": username, "avatar_url": avatarUrl, "tts": tts});
    print(r.body);
    print(r.statusCode);
    return null;
  }
}