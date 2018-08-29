part of nyxx;

/// Represents guild group channel. 
class GroupChannel extends Channel with GuildChannel {
  GroupChannel._new(Client client, Map<String, dynamic> data, Guild guild)
      : super._new(client, data, 4) {
    _initialize(data, guild);
    this.guild.channels[this.id] = this;
  }
}
