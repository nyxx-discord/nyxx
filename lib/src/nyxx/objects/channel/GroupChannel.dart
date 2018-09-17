part of nyxx;

/// Represents guild group channel.
class GroupChannel extends Channel with GuildChannel {
  GroupChannel._new(Map<String, dynamic> raw, Guild guild)
      : super._new(raw, 4) {
    _initialize(raw, guild);
  }
}
