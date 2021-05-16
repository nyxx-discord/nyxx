part of nyxx;

/// Returns guild  even if the user is not in the guild.
/// This endpoint is only for Public guilds.
class GuildPreview extends SnowflakeEntity {
  /// Reference to client
  final INyxx client;

  /// Guild name
  late final String name;

  /// Hash of guild icon. To get url use [iconURL]
  String? iconHash;

  /// Hash of guild spash image. To get url use [splashURL]
  String? splashHash;

  /// Hash of guild discovery image. To get url use [discoveryURL]
  String? discoveryHash;

  /// List of guild's emojis
  late final List<GuildEmoji> emojis;

  /// List of guild's features
  late final Iterable<GuildFeature> features;

  /// Approximate number of members in this guild
  late final int approxMemberCount;

  /// Approximate number of online members in this guild
  late final int approxOnlineMembers;

  /// The description for the guild
  String? description;

  GuildPreview._new(this.client, Map<String, dynamic> raw) : super(Snowflake(raw["id"])) {
    this.name = raw["name"] as String;

    if (this.iconHash != null) {
      this.iconHash = raw["icon"] as String;
    }

    if (this.splashHash != null) {
      this.splashHash = raw["splash"] as String;
    }

    if (this.discoveryHash != null) {
      this.discoveryHash = raw["discovery_splash"] as String;
    }

    this.emojis = [
      for (var rawEmoji in raw["emojis"]) GuildEmoji._new(client, rawEmoji as Map<String, dynamic>, this.id)
    ];

    this.features = (raw["features"] as List<dynamic>).map((e) => GuildFeature.from(e.toString()));

    this.approxMemberCount = raw["approximate_member_count"] as int;
    this.approxOnlineMembers = raw["approximate_presence_count"] as int;

    this.description = raw["description"] as String?;
  }

  /// The guild's icon, represented as URL.
  /// If guild doesn't have icon it returns null.
  String? iconURL({String format = "webp", int size = 128}) {
    if (this.iconHash != null) {
      return "https://cdn.${Constants.cdnHost}/icons/$id/$iconHash.$format?size=$size";
    }

    return null;
  }

  /// URL to guild's splash.
  /// If guild doesn't have splash it returns null.
  String? splashURL({String format = "webp", int size = 128}) {
    if (this.splashHash != null) {
      return "https://cdn.${Constants.cdnHost}/splashes/$id/$splashHash.$format?size=$size";
    }

    return null;
  }

  /// URL to guild's splash.
  /// If guild doesn't have splash it returns null.
  String? discoveryURL({String format = "webp", int size = 128}) {
    if (this.discoveryHash != null) {
      return "https://cdn.${Constants.cdnHost}/discovery-splashes/$id/$discoveryHash.$format?size=$size";
    }

    return null;
  }
}
