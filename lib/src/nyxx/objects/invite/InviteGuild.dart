part of nyxx;

/// A mini guild object for invites.
class InviteGuild extends SnowflakeEntity {
  /// The [Nyxx] object.
  Nyxx client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The guild's name.
  String name;

  /// The guild's spash if any.
  String spash;

  InviteGuild._new(this.client, this.raw)
      : super(Snowflake(raw['id'] as String)) {
    this.name = raw['name'] as String;
    this.spash = raw['splash_hash'] as String;
  }

  /// Get full guild object
  Guild getGuild() => client.guilds[id];

  /// Returns a string representation of this object.
  @override
  String toString() => this.name;
}
