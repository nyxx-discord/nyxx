import '../../discord.dart';

/// A mini channel object for invites.
class InviteChannel {
  /// The channel's ID.
  String id;

  /// The channel's name.
  String name;

  /// The channel's type.
  String type;

  /// A timestamp for the channel was created.
  DateTime createdAt;

  /// Constructs a new [InviteChannel].
  InviteChannel(Map<String, dynamic> data) {
    this.id = data['id'];
    this.name = data['name'];
    this.type = data['type'];
    this.createdAt = getDate(this.id);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
