part of nyxx;

/// Represents guild group channel.
class CategoryChannel extends Channel with GuildChannel {
  CategoryChannel._new(Map<String, dynamic> raw, Guild guild, Nyxx client)
      : super._new(raw, 4, client) {
    _initialize(raw, guild);
  }

  @override
  String get nameString => "[${this.guild.name}] Category Channel [${this.id}]";
}
