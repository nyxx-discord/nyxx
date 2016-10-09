part of discord;

/// A mini guild object for invites.
class InviteGuild extends _BaseObj {
  /// The guild's ID.
  String id;

  /// The guild's name.
  String name;

  /// The guild's spash if any.
  String spash;

  /// A timestamp for when the guild was created.
  DateTime createdAt;

  InviteGuild._new(Client client, Map<String, dynamic> data) : super(client) {
    this.id = this._map['id'] = data['id'];
    this.name = this._map['name'] = data['name'];
    this.spash = this._map['spash'] = data['splash_hash'];
    this.createdAt =
        this._map['createdAt'] = this._client._util.getDate(this.id);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
