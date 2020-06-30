part of nyxx;

abstract class IGuildEmoji extends Emoji implements SnowflakeEntity {
  /// True if emoji is partial.
  final bool partial;

  /// Snowflake id of emoji
  @override
  late final Snowflake id;

  @override
  DateTime get createdAt => id.timestamp;

  IGuildEmoji._new(Map<String, dynamic> raw, this.partial) : super._new(raw["name"] as String?) {
    this.id = Snowflake(raw["id"] as String);
  }
}

class PartialGuildEmoji extends IGuildEmoji {
  PartialGuildEmoji._new(Map<String, dynamic> raw) : super._new(raw, true);

  /// Encodes Emoji to API format
  @override
  String encode() => "$id";

  /// Formats Emoji to message format
  @override
  String format() => "<:$id>";

  /// Returns cdn url to emoji
  String get cdnUrl => "https://cdn.discordapp.com/emojis/${this.id}.png";

  /// Returns encoded string ready to send via message.
  @override
  String toString() => format();
}

/// Emoji object. Handles Unicode emojis and custom ones.
/// Always check if object is partial via [partial] field before accessing fields or methods,
/// due any of field can be null or empty
class GuildEmoji extends IGuildEmoji implements SnowflakeEntity, GuildEntity {
  /// Reference tp [Nyxx] object
  Nyxx client;

  /// Emojis guild
  @override
  late final Guild? guild;

  /// Emojis guild id
  @override
  late final Snowflake guildId;

  /// Roles which can use this emote
  late final Iterable<IRole> roles;

  /// whether this emoji must be wrapped in colons
  late final bool requireColons;

  /// whether this emoji is managed
  late final bool managed;

  /// whether this emoji is animated
  late final bool animated;

  /// Creates full emoji object
  GuildEmoji._new(Map<String, dynamic> raw, this.guildId, this.client) : super._new(raw, false) {
    this.guild = client.guilds[this.guildId];

    this.requireColons = raw["require_colons"] as bool? ?? false;
    this.managed = raw["managed"] as bool? ?? false;
    this.animated = raw["animated"] as bool? ?? false;

    this.roles = [
      if (raw["roles"] != null)
        for (final roleId in raw["roles"])
          IRole._new(Snowflake(roleId), this.guildId, client)
    ];
  }

  /// Allows to edit emoji
  Future<GuildEmoji> edit({String? name, List<Snowflake>? roles}) async {
    if (name == null && roles == null) {
      return Future.error(ArgumentError("Both name and roles fields cannot be null"));
    }

    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (roles != null) "roles": roles.map((r) => r.toString())
    };

    final response = await client._http._execute(
        BasicRequest._new("/guilds/${this.guildId}/emojis/${this.id.toString()}", method: "PATCH", body: body));

    if (response is HttpResponseSuccess) {
      return GuildEmoji._new(response.jsonBody as Map<String, dynamic>, this.guildId, client);
    }

    return Future.error(response);
  }

  /// Deletes emoji
  Future<void> delete() async =>
    client._http._execute(
        BasicRequest._new("/guilds/${this.guildId}/emojis/${this.id.toString()}", method: "DELETE"));

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
  int get hashCode => (super.hashCode * 37 + id.hashCode) * 37 + name.hashCode;

  @override
  DateTime get createdAt => id.timestamp;
}
