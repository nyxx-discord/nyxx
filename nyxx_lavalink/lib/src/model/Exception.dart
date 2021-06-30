part of nyxx_lavalink;

/// A exception object that can be sent by lavalink at certain endpoints
class LavalinkException {
  /// Exception message
  late final String? message;
  /// The error message
  late final String? error;
  /// The cause of the exception
  late final String? cause;
  /// Exception severity
  late final String? severity;

  LavalinkException._fromJson(Map<String, dynamic> json) {
    if (json.containsKey("exception")) {
      this.message = json["exception"]["message"] as String?;
      this.severity = json["exception"]["severity"] as String?;
      this.cause = json["exception"]["cause"] as String?;
    } else {
      this.error = json["error"] as String?;
    }
  }
}
