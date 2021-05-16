part of nyxx;

class CategoryGuildChannel extends GuildChannel {
  CategoryGuildChannel._new(INyxx client, Map<String, dynamic> raw, [Snowflake? guildId])
      : super._new(client, raw, guildId);
}
