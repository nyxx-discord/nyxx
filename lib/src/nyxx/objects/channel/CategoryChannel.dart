part of nyxx;

/// Represents guild group channel.
class CategoryChannel extends Channel with GuildChannel {
  CategoryChannel._new(Map<String, dynamic> raw, Guild guild)
      : super._new(raw, 4) {
    _initialize(raw, guild);
  }
}
