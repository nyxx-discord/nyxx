part of nyxx;

/// Represents group channel.
class GroupChannel extends Channel with GuildChannel {
  GroupChannel._new(Client client, Map<String, dynamic> data, Guild guild)
      : super._new(client, data, "group") {
    _initialize(data, guild);
    this.guild.channels[this.id] = this;
  }
}
