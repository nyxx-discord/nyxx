part of nyxx;

/// Emitted when user was updated
class UserUpdateEvent {
  /// User instance before update
  User oldUser;

  /// User instance after update
  User newUser;

  UserUpdateEvent._new(Map<String, dynamic> json) {
    this.oldUser = client.users[Snowflake(json['d']['id'] as String)];
    newUser = User._new(json['d'] as Map<String, dynamic>);
  }
}
