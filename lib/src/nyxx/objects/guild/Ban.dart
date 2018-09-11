part of nyxx;

/// Ban object. Has attached reason of ban and user who was banned
class Ban {

  /// Ban reason
  String reason;

  /// Banned user
  User user;

  /// Raw data returned from API
  Map<String, dynamic> raw;

  Ban._new(Nyxx client, this.raw) {
    this.reason = raw['reason'] as String;

    var userFlake = Snowflake(raw['user']['id'] as String);
    if(client.users.containsKey(userFlake))
      this.user = client.users[userFlake];
    else
      this.user = User._new(client, raw['user'] as Map<String, dynamic>);
  }
}