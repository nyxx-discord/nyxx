part of nyxx;

/// Emoji object. Handles Unicode emojis and custom ones. Unicode emoji dont have [id] and [name] is emoji.
class GuildEmoji extends Emoji {
  /// The [Client] object
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// Emoji guild
  Guild guild;

  /// Snowflake id of emoji
  String id;

  /// Name of emoji
  String name;

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
    this.id = raw['id'];
    this.name = raw['name'];
    this.requireColons = raw['require_colons'];
    this.managed = raw['managed'];
    this.animated = raw['animated'];

    if (raw['roles'] != null) this.rolesIds = raw['roles'] as List<String>;

    this.guild.emojis[this.id] = this;
  }

  /// Creates partial object - only [id] and [name]
  GuildEmoji._partial(this.raw) {
    this.id = raw['id'];
    this.name = raw['name'];
  }

  @override
  String encode() => "$name:$id";
}