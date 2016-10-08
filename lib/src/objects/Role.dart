part of discord;

/// A role.
class Role {
  /// The client.
  Client client;

  /// A map of all of the properties.
  Map<String, dynamic> map = <String, dynamic>{};

  /// The role's name.
  String name;

  /// The role's ID.
  String id;

  /// The role's color, null if no color.
  int color;

  /// The role's position.
  int position;

  /// If the role is pinned in the user listing.
  bool hoist;

  /// Whether or not the role is managed by an integration.
  bool managed;

  /// Whether or not the role is mentionable.
  bool mentionable;

  /// The role's permissions.
  Permissions permissions;

  /// A timestamp for when the channel was created.
  DateTime createdAt;

  Role._new(this.client, Map<String, dynamic> data) {
    this.id = this.map['id'] = data['id'];
    this.name = this.map['name'] = data['name'];
    this.position = this.map['position'] = data['position'];
    this.hoist = this.map['hoist'] = data['hoist'];
    this.managed = this.map['managed'] = data['managed'];
    this.mentionable = this.map['mentionable'] = data['mentionable'];
    this.permissions =
        this.map['permissions'] = new Permissions.fromInt(data['permissions']);
    this.createdAt = this.map['createdAt'] = this.client._util.getDate(this.id);

    if (data['color'] == 0) {
      this.color = this.map['color'] = null;
    } else {
      this.color = this.map['color'] = data['color'];
    }
  }
}
