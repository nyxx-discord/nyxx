part of nyxx;

/// A mini guild object with permissions for [OAuth2Info].
class OAuth2Guild extends SnowflakeEntity {
  /// The permissions you have on that guild.
  late final Permissions permissions;

  /// The guild's icon hash.
  late final String icon;

  /// The guild's name
  late final String name;

  OAuth2Guild._new(RawApiMap raw) : super(Snowflake(raw["id"] as String)) {
    this.permissions = Permissions.fromInt(raw["permissions"] as int);
    this.icon = raw["icon"] as String;
    this.name = raw["name"] as String;
  }

  /// Returns a string representation of this object.
  @override
  String toString() => this.name;

  /// Returns url to guilds icon
  String? iconUrl({String format = "png", int size = 512}) =>
    "https://cdn.discordapp.com/icons/${this.id.toString()}/$icon.$format?size=$size";
}
