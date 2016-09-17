import '../objects.dart';

/// A mini channel object for invites.
class InviteChannel {
  /// The channel's ID.
  String id;

  /// The channel's name.
  String name;

  /// The channel's type.
  String type;

  /// A timestamp for the channel was created.
  double createdAt;

  InviteChannel(Map data) {
    this.id = data['id'];
    this.name = data['name'];
    this.type = data['type'];
    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;
  }
}
