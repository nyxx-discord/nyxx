part of nyxx;

/// Represents guild group channel.
class GroupChannel extends Channel with GuildChannel {
  GroupChannel._new(Map<String, dynamic> data, Guild guild)
      : super._new(data, 4) {
    _initialize(data, guild);
  }
}
