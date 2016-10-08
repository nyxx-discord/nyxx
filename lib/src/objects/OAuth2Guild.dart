part of discord;

/// A mini guild object with permissions for [OAuth2Info].
class OAuth2Guild {
  /// The client.
  Client client;

  /// A map of all of the properties.
  Map<String, dynamic> map = <String, dynamic>{};

  /// The permissions you have on that guild.
  int permissions;

  /// The guild's icon hash.
  String icon;

  /// The guild's ID.
  String id;

  /// The guild's name
  String name;

  /// A timestamp for when the guild was created.
  DateTime createdAt;

  OAuth2Guild._new(this.client, Map<String, dynamic> data) {
    this.permissions = this.map['permissions'] = data['permissions'];
    this.icon = this.map['icon'] = data['icon'];
    this.id = this.map['id'] = data['id'];
    this.name = this.map['name'] = data['name'];
    this.createdAt = this.map['createdAt'] = this.client._util.getDate(this.id);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
