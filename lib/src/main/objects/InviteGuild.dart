part of discord;

/// A mini guild object for invites.
class InviteGuild {
  Client _client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The guild's ID.
  String id;

  /// The guild's name.
  String name;

  /// The guild's spash if any.
  String spash;

  /// A timestamp for when the guild was created.
  DateTime createdAt;

  InviteGuild._new(this._client, this.raw) {
    this.id = raw['id'];
    this.name = raw['name'];
    this.spash = raw['splash_hash'];
    this.createdAt = Util.getDate(this.id);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
