import 'dart:convert';
import 'dart:async';
import 'client.dart';
import 'package:http/http.dart' as http;

/// The HTTP manager for the client.
class HTTP {
  /// The base API URL.
  String host = "https://discordapp.com/api";

  /// A map of headers that get sent on each HTTP request.
  Map<String, String> headers;

  /// Makes a new HTTP manager.
  HTTP(Client client) {
    this.headers = <String, String>{'User-Agent': 'Discord Dart (https://github.com/Hackzzila/Discord-Dart, ${client.version})', 'Content-Type': 'application/json'};
  }

  /// Sends a GET request.
  Future<http.Response> get(String uri) async {
    return await http.get("${this.host}/$uri", headers: this.headers);
  }

  /// Sends a POST request.
  Future<http.Response> post(String uri, Object content) async {
    return await http.post("${this.host}/$uri", body: JSON.encode(content), headers: this.headers);
  }

  /// Sends a PATCH request.
  Future<http.Response> patch(String uri, Object content) async {
    return await http.patch("${this.host}/$uri", body: JSON.encode(content), headers: this.headers);
  }

  /// Sends a DELETE request.
  Future<http.Response> delete(String uri) async {
    return await http.delete("${this.host}/$uri", headers: this.headers);
  }
}
