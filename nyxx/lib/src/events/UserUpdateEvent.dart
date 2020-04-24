part of nyxx;

// TODO: ???
/// Emitted when user was updated
class UserUpdateEvent {
  /// User instance after update
  late final User user;

  UserUpdateEvent._new(Map<String, dynamic> json, Nyxx client) {
    user = User._new(json['d'] as Map<String, dynamic>, client);
  }
}
