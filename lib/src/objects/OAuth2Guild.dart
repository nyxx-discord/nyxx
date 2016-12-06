part of discord;

/// A mini guild object with permissions for [OAuth2Info].
class OAuth2Guild {
  Client _client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The permissions you have on that guild.
  Permissions permissions;

  /// The guild's icon hash.
  String icon;

  /// The guild's ID.
  String id;

  /// The guild's name
  String name;

  /// A timestamp for when the guild was created.
  DateTime createdAt;

  OAuth2Guild._new(this._client, this.raw) {
    this.permissions = new Permissions.fromInt(_client, raw['permissions']);
    this.icon = raw['icon'];
    this.id = raw['id'];
    this.name = raw['name'];
    this.createdAt = Util.getDate(this.id);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
