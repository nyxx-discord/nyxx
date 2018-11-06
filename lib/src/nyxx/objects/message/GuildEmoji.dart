part of nyxx;

/// Emoji object. Handles Unicode emojis and custom ones.
class GuildEmoji extends Emoji implements SnowflakeEntity, GuildEntity, Nameable {

  @override
  /// Emoji guild
  Guild guild;

  @override
  /// Snowflake id of emoji
  Snowflake id;

  /// Roles this emoji is whitelisted to
  List<Role> roles;

  /// whether this emoji must be wrapped in colons
  bool requireColons;

  /// whether this emoji is managed
  bool managed;

  /// whether this emoji is animated
  bool animated;

  /// Creates full emoji object
  GuildEmoji._new(Map<String, dynamic> raw, this.guild) : super("") {
    this.id = Snowflake(raw['id'] as String);
    this.name = raw['name'] as String;
    this.requireColons = raw['require_colons'] as bool;
    this.managed = raw['managed'] as bool;
    this.animated = raw['animated'] as bool;

    if (raw['roles'] != null) {
      this.roles = List();

      raw['roles'].forEach(
          (o) => this.roles.add(this.guild.roles[Snowflake(o as String)]));
    }

    guild.emojis[id] = this;
  }

  /// Creates partial object - only [id] and [name]
  GuildEmoji._partial(Map<String, dynamic> raw) : super(raw['name'] as String) {
    this.id = Snowflake(raw['id'] as String);
  }

  Future<GuildEmoji> edit({String name, List<Snowflake> roles}) async {
    var res = await client._http.send(
        "PATCH", "/guilds/${guild.id.toString()}/emojis/${this.id.toString()}",
        body: {"name": name, roles: roles.map((r) => r.toString())});

    return GuildEmoji._new(res.body as Map<String, dynamic>, guild);
  }

  Future<void> delete() async {
    await _client._http.send("DELETE",
        "/guilds/${this.guild.id.toString()}/emojis/${this.id.toString()}");
  }

  /// Encodes Emoji to API format
  @override
  String encode() => "$name:$id";

  /// Formats Emoji to message format
  @override
  String format() =>
      animated != null && animated ? "<a:$name:$id>" : "<:$name:$id>";

  /// Returns cdn url to emoji
  String get cdnUrl =>
      "https://cdn.discordapp.com/emojis/${this.id}${animated ? ".gif" : ".png"}";

  /// Returns encoded string ready to send via message.
  @override
  String toString() => format();

  @override
  bool operator ==(other) => other is Emoji && other.name == this.name;

  @override
  int get hashCode =>
      ((super.hashCode * 37 + id.hashCode) * 37 + name.hashCode);

  @override
  DateTime get createdAt => id.timestamp;

  @override
  String get nameString => "Guild Emoji ${name} [${this.guild.name}] [${this.id}]";
}
