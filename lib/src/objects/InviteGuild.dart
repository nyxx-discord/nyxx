import '../../objects.dart';

/// A mini guild object for invites.
class InviteGuild {
  /// The guild's ID.
  String id;

  /// The guild's name.
  String name;

  /// The guild's spash if any.
  String spash;

  /// A timestamp for when the guild was created.
  double createdAt;

  InviteGuild(Map data) {
    this.id = data['id'];
    this.name = data['name'];
    this.spash = data['splash_hash'];
    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;
  }
}
