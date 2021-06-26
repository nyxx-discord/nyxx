part of nyxx_lavalink;

/// A exception object that can be sent by lavalink at certain endpoints
class LavalinkException {
  /// Exception message
  late final String message;
  /// Exception severity
  late final String severity;

  LavalinkException._fromJson(Map<String, dynamic> json) {
    this.message = json["message"] as String;
    this.severity = json["severity"] as String;
  }
}
