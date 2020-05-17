part of nyxx;

/// Emoji object. Handles Unicode emojis and custom ones.
/// Always check if object is partial via [partial] field before accessing fields or methods,
/// due any of field can be null or empty
class GuildEmoji extends Emoji implements SnowflakeEntity, GuildEntity {
  late Nyxx client;

  @override

  /// Emoji guild
  late final Guild guild;

  @override

  /// Snowflake id of emoji
  late final Snowflake id;

  /// Roles this emoji is whitelisted to
  late final List<Role> roles;

  /// whether this emoji must be wrapped in colons
  late final bool requireColons;

  /// whether this emoji is managed
  late final bool managed;

  /// whether this emoji is animated
  late final bool animated;

  /// True if emoji is partial.
  /// Always check before accessing fields or methods, due any of field can be null or empty
  late final bool partial;

  /// Creates full emoji object
  GuildEmoji._new(Map<String, dynamic> raw, this.guild, this.client) : super("") {
    this.id = Snowflake(raw['id'] as String);

    this.name = raw['name'] as String;
    this.requireColons = raw['require_colons'] as bool? ?? false;
    this.managed = raw['managed'] as bool? ?? false;
    this.animated = raw['animated'] as bool? ?? false;

    this.roles = [];
    if (raw['roles'] != null) {
      for (var roleId in raw['roles']) {
        var role = this.guild.roles[Snowflake(roleId)];

        if (role != null) {
          this.roles.add(role);
        }
      }
    }

    this.partial = false;
  }

  /// Creates partial object - only [id] and [name]
  GuildEmoji._partial(Map<String, dynamic> raw) : super(raw['name'] as String) {
    this.id = Snowflake(raw['id'] as String);
    this.partial = true;
  }

  Future<GuildEmoji> edit({String? name, List<Snowflake>? roles}) async {
    if (name == null && roles == null) {
      return Future.error("Both name and roles fields cannot be null");
    }

    var body = <String, dynamic>{
      if (name != null) "name": name,
      if (roles != null) "roles": roles.map((r) => r.toString())
    };

    var response = await client._http._execute(
        BasicRequest._new("/guilds/${guild.id.toString()}/emojis/${this.id.toString()}", method: "PATCH", body: body));

    if (response is HttpResponseSuccess) {
      return GuildEmoji._new(response.jsonBody as Map<String, dynamic>, guild, client);
    }

    return Future.error(response);
  }

  Future<void> delete() async {
    return client._http._execute(
        BasicRequest._new("/guilds/${this.guild.id.toString()}/emojis/${this.id.toString()}", method: "DELETE"));
  }

  /// Encodes Emoji to API format
  @override
  String encode() => "$name:$id";

  /// Formats Emoji to message format
  @override
  String format() => animated ? "<a:$name:$id>" : "<:$name:$id>";

  /// Returns cdn url to emoji
  String get cdnUrl => "https://cdn.discordapp.com/emojis/${this.id}${animated ? ".gif" : ".png"}";

  /// Returns encoded string ready to send via message.
  @override
  String toString() => format();

  @override
  bool operator ==(other) => other is Emoji && other.name == this.name;

  @override
  int get hashCode => ((super.hashCode * 37 + id.hashCode) * 37 + name.hashCode);

  @override
  DateTime get createdAt => id.timestamp;
}
