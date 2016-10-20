part of discord;

/// A mini channel object for invites.
class InviteChannel extends _BaseObj {
  /// The channel's ID.
  String id;

  /// The channel's name.
  String name;

  /// The channel's type.
  String type;

  /// A timestamp for the channel was created.
  DateTime createdAt;

  InviteChannel._new(Client client, Map<String, dynamic> data) : super(client) {
    this.id = data['id'];
    this.name = data['name'];
    this.type = data['type'];
    this.createdAt = Util.getDate(this.id);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
