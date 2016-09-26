import '../../discord.dart';

/// A mini guild object with permissions for [OAuth2Info].
class OAuth2Guild {
  /// A map of all of the properties.
  Map<String, dynamic> map = <String, dynamic>{};

  /// The permissions you have on that guild.
  int permissions;

  /// The guild's icon hash.
  String icon;

  /// The guild's ID.
  String id;

  /// The guild's name
  String name;

  /// A timestamp for when the guild was created.
  double createdAt;

  /// Constructs a new [OAuth2Guild].
  OAuth2Guild(Map<String, dynamic> data) {
    this.permissions = data['permissions'];
    this.map['permissions'] = this.permissions;

    this.icon = data['icon'];
    this.map['icon'] = this.icon;

    this.id = data['id'];
    this.map['id'] = this.id;

    this.name = data['name'];
    this.map['name'] = this.name;

    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;
    this.map['createdAt'] = this.createdAt;
  }

  /// Returns a string representation of this object.
  String toString() {
    return this.name;
  }
}
