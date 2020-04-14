part of nyxx;

/// The allowed mention field allows for more granular control over mentions without various hacks to the message content.
/// This will always validate against message content to avoid phantom pings (e.g. to ping everyone, you must still have @everyone in the message content), and check against user/bot permissions.
///
/// If class is only instantiated without any modifications to its fields, by default it will suppress all mentions.
class AllowedMentions implements Builder {
  bool _allowEveryone = false;
  bool _allowUsers = false;
  bool _allowRoles = false;

  List<Snowflake> _users = [];
  List<Snowflake> _roles = [];

  /// Allow @everyone and @here if [everyone] is true
  /// Allow @user if [users] is true
  /// Allow @role if [roles] is true
  AllowedMentions allow({bool everyone = false, bool users = false, bool roles = false}) {
    this._allowEveryone = everyone;
    this._allowUsers = users;
    this._allowRoles = roles;

    return this;
  }

  /// Suppress mentioning specific user by its id
  AllowedMentions suppressUser(Snowflake userId) {
    this._users.add(userId);
    return this;
  }

  /// Suppress mentioning multiple users by their ids
  AllowedMentions suppressUsers(Iterable<Snowflake> userIds) {
    this._users.addAll(userIds);
    return this;
  }

  /// Suppress mentioning specific role by its id
  AllowedMentions suppressRole(Snowflake roleId) {
    this._roles.add(roleId);
    return this;
  }

  /// Suppress mentioning multiple roles by their ids
  AllowedMentions suppressRoles(Iterable<Snowflake> roleIds) {
    this._roles.addAll(roleIds);
    return this;
  }

  @override
  Map<String, dynamic> _build() {
    var map = Map<String, dynamic>();
    map['parse'] = [];

    if(_allowEveryone) {
      (map['parse'] as List).add("everyone");
    }

    if(_allowRoles) {
      (map['parse'] as List).add("roles");
    }

    if(_allowUsers) {
      (map['parse'] as List).add("users");
    }

    if(_users.isNotEmpty) {
      if(!_allowUsers) {
        throw new Exception("Invalid configuration of allowed mentions! Allowed `user` and blacklisted users at the same time!");
      }

      map['users'] = _users.map((e) => e.id.toString());
    }

    if(_roles.isNotEmpty) {
      if(!_allowRoles) {
        throw new Exception("Invalid configuration of allowed mentions! Allowed `roles` and blacklisted roles at the same time!");
      }

      map['roles'] = _roles.map((e) => e.id.toString());
    }

    return map;
  }
}
