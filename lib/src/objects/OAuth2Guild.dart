import '../../objects.dart';

/// A mini guild object with permissions for [OAuth2Info].
class OAuth2Guild {
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

  OAuth2Guild(Map data) {
    this.permissions = data['permissions'];
    this.icon = data['icon'];
    this.id = data['id'];
    this.name = data['name'];
    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;
  }
}
