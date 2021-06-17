part of nyxx_lavalink;

/// A exception object that can be sent by lavalink at certain endpoints
class LavalinkException {
  /// Exception message
  final String message;
  /// Exception severity
  final String severity;

  LavalinkException._fromJson(Map<String, dynamic> json)
  : message = json["message"] as String,
    severity = json["severity"] as String;
}
