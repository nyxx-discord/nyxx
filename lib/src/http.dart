import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

/// The base class for the API manager.
class API {
  String _host = "https://discordapp.com/api";

  /// A list of headers to be sent on each request.
  Map<String, String> headers = <String, String>{'User-Agent': 'DiscordDart (https://github.com/Hackzzila/Discord-Dart, 0.1.0)', 'Content-Type': 'application/json'};

  /// Sends a GET request.
  Future<http.Response> get(String uri) async {
    return await http.get("${this._host}/$uri", headers: this.headers);
  }

  /// Sends a POST request.
  Future<http.Response> post(String uri, Object content) async {
    return await http.post("${this._host}/$uri", body: JSON.encode(content), headers: this.headers);
  }

  /// Sends a PATCH request.
  Future<http.Response> patch(String uri, Object content) async {
    return await http.patch("${this._host}/$uri", body: JSON.encode(content), headers: this.headers);
  }

  /// Sends a DELETE request.
  Future<http.Response> delete(String uri) async {
    return await http.delete("${this._host}/$uri", headers: this.headers);
  }
}
