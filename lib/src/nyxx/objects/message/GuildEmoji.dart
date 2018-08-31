part of nyxx;

/// Emoji object. Handles Unicode emojis and custom ones.
class GuildEmoji extends Emoji {
  /// The [Client] object
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// Emoji guild
  Guild guild;

  /// Snowflake id of emoji
  Snowflake id;

  /// Roles this emoji is whitelisted to
  List<String> rolesIds;

  /// whether this emoji must be wrapped in colons
  bool requireColons;

  /// whether this emoji is managed
  bool managed;

  /// whether this emoji is animated
  bool animated;

  /// Creates full emoji object
  GuildEmoji._new(this.client, this.raw, this.guild) : super("") {
    this.id = Snowflake(raw['id'] as String);
    this.name = raw['name'] as String;
    this.requireColons = raw['require_colons'] as bool;
    this.managed = raw['managed'] as bool;
    this.animated = raw['animated'] as bool;

    if (raw['roles'] != null) {
      this.rolesIds = List();

      raw['roles'].forEach((o) => this.rolesIds.add(o.toString()));
    }

    this.guild.emojis[this.id] = this;
  }

  /// Creates partial object - only [id] and [name]
  GuildEmoji._partial(this.raw) : super("") {
    this.id = Snowflake(raw['id'] as String);
    this.name = raw['name'] as String;
  }

  /// Encodes Emoji to API format
  @override
  String encode() => "$name:$id";

  /// Formats Emoji to message format
  @override
  String format() =>
      animated != null && animated ? "<a:$name:$id>" : "<:$name:$id>";

  /// Returns encoded string ready to send via message.
  @override
  String toString() => format();

  String cdnUrl() {
    String format = animated ? ".gif" : ".png";

    return "https://cdn.discordapp.com/emojis/${this.id}.$format";
  }

  @override
  bool operator ==(other) => other is Emoji && other.name == this.name;

  @override
  int get hashCode =>
      ((super.hashCode * 37 + id.hashCode) * 37 + name.hashCode);
}
