import '../../discord.dart';

/// A mini guild object for invites.
class InviteGuild {
  /// The client.
  Client client;

  /// The guild's ID.
  String id;

  /// The guild's name.
  String name;

  /// The guild's spash if any.
  String spash;

  /// A timestamp for when the guild was created.
  DateTime createdAt;

  /// Constructs a new [InviteGuild].
  InviteGuild(this.client, Map<String, dynamic> data) {
    this.id = data['id'];
    this.name = data['name'];
    this.spash = data['splash_hash'];
    this.createdAt = this.client.internal.util.getDate(this.id);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
