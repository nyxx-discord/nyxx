part of discord;

/// Emoji object. Handles Unicode emojis and custom ones. Unicode emoji dont have [id] and [name] is emoji.
class Emoji {
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
  Emoji._new(this.client, this.raw, this.guild) {
    print(this.raw);

    this.id = raw['id'];
    this.name = raw['name'];
    this.requireColons = raw['require_colons'];
    this.managed = raw['managed'];
    this.animated = raw['animated'];

    if (raw['roles'] != null) this.rolesIds = raw['roles'] as List<String>;

    this.guild.emojis[this.id] = this;
  }

  /// Creates partial object - onlu [id] and [name]
  Emoji._partial(this.raw) {
    this.id = raw['id'];
    this.name = raw['name'];
  }
}
