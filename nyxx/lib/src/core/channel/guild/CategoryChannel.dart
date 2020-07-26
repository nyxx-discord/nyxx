part of nyxx;

/// Represents guild group channel.
class CategoryChannel extends CachelessGuildChannel {
  CategoryChannel._new(Map<String, dynamic> raw, Snowflake guildId, Nyxx client) : super._new(raw, 4, guildId, client);
}
