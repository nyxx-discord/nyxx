part of nyxx;

// TODO: ???
/// Emitted when user was updated
class UserUpdateEvent {
  /// User instance after update
  late final User user;

  UserUpdateEvent._new(RawApiMap json, Nyxx client) {
    this.user = User._new(client, json["d"] as RawApiMap);
  }
}
