part of nyxx;

/// The allowed mention field allows for more granular control over mentions without various hacks to the message content.
/// This will always validate against message content to avoid phantom pings (e.g. to ping everyone, you must still have @everyone in the message content), and check against user/bot permissions.
///
/// If class is only instantiated without any modifications to its fields, by default it will suppress all mentions.
class AllowedMentions implements Builder {
  bool _allowEveryone = false;
  bool _allowUsers = false;
  bool _allowRoles = false;
  bool _allowReply = false;

  final List<Snowflake> _users = [];
  final List<Snowflake> _roles = [];

  /// Allow @everyone and @here if [everyone] is true
  /// Allow @user if [users] is true
  /// Allow @role if [roles] is true
  void allow({bool reply = false, bool everyone = false, bool users = false, bool roles = false}) {
    this._allowEveryone = everyone;
    this._allowUsers = users;
    this._allowRoles = roles;
    this._allowReply = reply;
  }

  /// Suppress mentioning specific user by its id
  void suppressUser(Snowflake userId) {
    this._users.add(userId);
  }

  /// Suppress mentioning multiple users by their ids
  void suppressUsers(Iterable<Snowflake> userIds) {
    this._users.addAll(userIds);
  }

  /// Suppress mentioning specific role by its id
  void suppressRole(Snowflake roleId) {
    this._roles.add(roleId);
  }

  /// Suppress mentioning multiple roles by their ids
  void suppressRoles(Iterable<Snowflake> roleIds) {
    this._roles.addAll(roleIds);
  }

  // TODO: spread collections???
  @override
  Map<String, dynamic> _build() {
    final map = <String, dynamic>{};
    map["parse"] = [];

    if (_allowEveryone) {
      (map["parse"] as List).add("everyone");
    }

    if (_allowRoles) {
      (map["parse"] as List).add("roles");
    }

    if (_allowUsers) {
      (map["parse"] as List).add("users");
    }

    if (_users.isNotEmpty) {
      if (!_allowUsers) {
        throw ArgumentError(
            "Invalid configuration of allowed mentions! Allowed `user` and blacklisted users at the same time!");
      }

      map["users"] = _users.map((e) => e.id.toString());
    }

    if (_roles.isNotEmpty) {
      if (!_allowRoles) {
        throw ArgumentError(
            "Invalid configuration of allowed mentions! Allowed `roles` and blacklisted roles at the same time!");
      }

      map["roles"] = _roles.map((e) => e.id.toString());
    }

    map["replied_user"] = this._allowReply;

    return map;
  }
}
