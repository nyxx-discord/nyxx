part of nyxx;

/// A mini channel object for invites.
class InviteChannel {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The channel's ID.
  String id;

  /// The channel's name.
  String name;

  /// The channel's type.
  String type;

  /// A timestamp for the channel was created.
  DateTime createdAt;

  InviteChannel._new(this.client, this.raw) {
    this.id = raw['id'];
    this.name = raw['name'];
    this.type = raw['type'];
    this.createdAt = Util.getDate(this.id);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
