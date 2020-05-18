part of nyxx;

/// Ban object. Has attached reason of ban and user who was banned.
class Ban {
  /// Reason of ban
  String? reason;

  /// Banned user
  late final User user;

  Ban._new(Map<String, dynamic> raw, Nyxx client) {
    this.reason = raw["reason"] as String;

    final userId = Snowflake(raw["user"]["id"] as String);
    if (client.users.hasKey(userId)) {
      this.user = client.users[userId] as User;
    } else {
      this.user = User._new(raw["user"] as Map<String, dynamic>, client);
    }
  }
}
