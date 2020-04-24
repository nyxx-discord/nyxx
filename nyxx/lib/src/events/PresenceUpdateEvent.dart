part of nyxx;

/// Sent when a member's presence updates.
class PresenceUpdateEvent {
  /// User object
  User? user;

  /// User id
  late final Snowflake userId;

  /// The new member.
  Activity? presence;

  /// Status of client
  late final ClientStatus clientStatus;

  PresenceUpdateEvent._new(Map<String, dynamic> json, Nyxx client) {
    if (json['d']['activity'] != null) {
      this.presence = Activity._new(json['d']['activity'] as Map<String, dynamic>);
    }
    this.clientStatus = ClientStatus._deserialize(json['d']['client_status'] as Map<String, dynamic>);

    this.userId = Snowflake(json['d']['user']['id']);
    this.user = client.users[this.userId];

    if (user == null && (json['d']['user'] as Map<String, dynamic>).keys.length > 1) {
      this.user = User._new(json['d']['user'] as Map<String, dynamic>, client);
    }

    if(this.user != null) {
      if(this.clientStatus != this.user!.status) {
        this.user!.status = this.clientStatus;
      }

      if(this.presence != null) {
        this.user!.presence = this.presence;
      }
    }

  }
}
