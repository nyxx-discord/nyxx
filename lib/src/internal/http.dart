import 'dart:convert';
import 'dart:async';
import '../../discord.dart';
import 'package:http/http.dart' as http_lib;

/// The HTTP manager for the client.
class HTTP {
  /// The base API URL.
  String host = "https://discordapp.com/api";

  /// A map of headers that get sent on each HTTP request.
  Map<String, String> headers;

  /// The HTTP client.
  http_lib.Client http;

  /// Makes a new HTTP manager.
  HTTP(Client client) {
    this.http = new http_lib.Client();
    this.headers = <String, String>{
      'User-Agent':
          'Discord Dart (https://github.com/Hackzzila/Discord-Dart, ${client.version})',
      'Content-Type': 'application/json'
    };
  }

  /// Sends a GET request.
  Future<http_lib.Response> get(String uri) async {
    return await this.http.get("${this.host}/$uri", headers: this.headers);
  }

  /// Sends a POST request.
  Future<http_lib.Response> post(String uri, Object content) async {
    return await this.http.post("${this.host}/$uri",
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
