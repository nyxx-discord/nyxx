part of nyxx;

/// A mini guild object with permissions for [OAuth2Info].
class OAuth2Guild {
  /// The permissions you have on that guild.
  Permissions permissions;

  /// The guild's icon hash.
  String icon;

  /// The guild's ID.
  Snowflake id;

  /// The guild's name
  String name;

  /// A timestamp for when the guild was created.
  DateTime createdAt;

  OAuth2Guild._new(Map<String, dynamic> raw) {
    this.permissions = Permissions.fromInt(raw['permissions'] as int);
    this.icon = raw['icon'] as String;
    this.id = Snowflake(raw['id'] as String);
    this.name = raw['name'] as String;
    this.createdAt = id.timestamp;
  }

  /// Returns a string representation of this object.
  @override
  String toString() => this.name;
}