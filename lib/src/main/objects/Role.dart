part of discord;

/// A role.
class Role {
  Client _client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

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

  /// The role's guild.
  Guild guild;

  /// The role's permissions.
  Permissions permissions;

  /// A timestamp for when the channel was created.
  DateTime createdAt;

  Role._new(this._client, this.raw, this.guild) {
    this.id = raw['id'];
    this.name = raw['name'];
    this.position = raw['position'];
    this.hoist = raw['hoist'];
    this.managed = raw['managed'];
    this.mentionable = raw['mentionable'];
    this.permissions =
        new Permissions.fromInt(this._client, raw['permissions']);
    this.createdAt = Util.getDate(this.id);

    if (raw['color'] == 0) {
      this.color = null;
    } else {
      this.color = raw['color'];
    }

    this.guild.roles[this.id] = this;
  }

  /// Edits the role.
  Future<Role> edit(
      {String name: null,
      int permissions: null,
      int position: null,
      int color: null,
      bool mentionable: null,
      bool hoist: null}) async {
    HttpResponse r = await this
        ._client
        .http
        .send('PATCH', "/guilds/${this.guild.id}/roles/$id", body: {
      "name": name != null ? name : this.name,
      "permissions": permissions != null ? permissions : this.permissions.raw,
      "position": position != null ? position : this.position,
      "color": color != null ? color : this.color,
      "hoist": hoist != null ? hoist : this.hoist,
      "mentionable": mentionable != null ? mentionable : this.mentionable
    });
    return new Role._new(
        this._client, r.body.asJson() as Map<String, dynamic>, this.guild);
  }

  /// Deletes the role.
  Future<Null> delete() async {
    await this
        ._client
        .http
        .send('DELETE', "/guilds/${this.guild.id}/roles/$id");
    return null;
  }

  /// Returns a string representation of this object.
  @override
  String toString() => this.name;
}
