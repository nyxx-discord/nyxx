part of nyxx;

/// An OAuth2 application.
class OAuth2Application extends SnowflakeEntity {
  /// The app's description.
  late final String description;

  /// The app's icon hash.
  late final String? icon;

  /// The app's name.
  late final String name;

  /// The app's RPC origins.
  late final List<String>? rpcOrigins;

  OAuth2Application._new(Map<String, dynamic> raw) : super(Snowflake(raw["id"] as String)) {
    this.description = raw["description"] as String;
    this.name = raw["name"] as String;

    this.icon = raw["icon"] as String?;
    this.rpcOrigins = raw["rpcOrigins"] as List<String>?;
  }

  /// Returns url to apps icon
  String? iconUrl({String format = "png", int size = 512}) {
    if (this.icon != null) {
      return "https://cdn.discordapp.com/app-icons/${this.id}/$icon.$format?size=$size";
    }

    return null;
  }

  /// Returns a string representation of this object.
  @override
  String toString() => this.name;
}
