part of nyxx;

/// A mini channel object for invites.
class InviteChannel {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The channel's ID.
  Snowflake id;

  /// The channel's name.
  String name;

  /// The channel's type.
  String type;

  /// A timestamp for the channel was created.
  DateTime createdAt;

  InviteChannel._new(this.client, this.raw) {
    this.id = new Snowflake(raw['id'] as String);
    this.name = raw['name'] as String;
    this.type = raw['type'] as String;
    this.createdAt = id.timestamp;
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
