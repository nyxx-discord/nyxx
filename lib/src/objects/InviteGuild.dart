part of nyxx;

/// A mini guild object for invites.
class InviteGuild {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The guild's ID.
  Snowflake id;

  /// The guild's name.
  String name;

  /// The guild's spash if any.
  String spash;

  /// A timestamp for when the guild was created.
  DateTime createdAt;

  InviteGuild._new(this.client, this.raw) {
    this.id = new Snowflake(raw['id'] as String);
    this.name = raw['name'] as String;
    this.spash = raw['splash_hash'] as String;
    this.createdAt = id.timestamp;
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
