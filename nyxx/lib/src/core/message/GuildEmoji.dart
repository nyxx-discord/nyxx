part of nyxx;
abstract class IGuildEmoji extends SnowflakeEntity implements IEmoji {
  /// True if emoji is partial.
  bool get isPartial;

  /// Returns cdn url to emoji
  String get cdnUrl => "https://cdn.discordapp.com/emojis/${this.id}.png";

  IGuildEmoji._new(Map<String, dynamic> raw): super(Snowflake(raw["id"]));

  @override
  String formatForMessage() => "<:$id>";

  @override
  String encodeForAPI() => id.toString();

  /// Returns encoded string ready to send via message.
  @override
  String toString() => this.formatForMessage();
}

class GuildEmojiPartial extends IGuildEmoji implements IEmoji {
  @override
  bool get isPartial => true;

  GuildEmojiPartial._new(Map<String, dynamic> raw): super._new(raw);
}

class GuildEmoji extends GuildEmojiPartial implements IEmoji {
  /// Reference to client
  final Nyxx client;

  /// Reference to guild where emoji belongs to
  late final Cacheable<Snowflake, Guild> guild;

  /// Roles which can use this emote
  late final Iterable<Cacheable<Snowflake, Role>> roles;

  /// whether this emoji must be wrapped in colons
  late final bool requireColons;

  /// whether this emoji is managed
  late final bool managed;

  /// whether this emoji is animated
  late final bool animated;

  @override
  bool get isPartial => false;

  GuildEmoji._new(this.client, Map<String, dynamic> raw, Snowflake guildId): super._new(raw) {
    this.guild = _GuildCacheable(client, guildId);

    this.requireColons = raw["require_colons"] as bool? ?? false;
    this.managed = raw["managed"] as bool? ?? false;
    this.animated = raw["animated"] as bool? ?? false;
    this.roles = [
      for (final roleId in raw["roles"])
        _RoleCacheable(client, Snowflake(roleId), guild)
    ];
  }

  /// Allows to delete guild emoji
  Future<void> delete() =>
      client._httpEndpoints.deleteGuildEmoji(this.guild.id, this.id);

  /// Allows to edit guild emoji
  Future<void> edit({String? name, List<Snowflake>? roles}) =>
      client._httpEndpoints.editGuildEmoji(this.guild.id, this.id, name: name, roles: roles);
}
