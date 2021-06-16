part of nyxx;

/// Ban object. Has attached reason of ban and user who was banned.
class Ban {
  /// Reason of ban
  String? reason;

  /// Banned user
  late final User user;

  Ban._new(RawApiMap raw, INyxx client) {
    this.reason = raw["reason"] as String;
    this.user = User._new(client, raw["user"] as RawApiMap);
  }
}
