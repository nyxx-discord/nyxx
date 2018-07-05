part of nyxx;

class GroupChannel extends Channel with GuildChannel {
  GroupChannel._new(Client client, Map<String, dynamic> data, Guild guild)
      : super._new(client, data, "group") {
    initialize(data);
    this.guild = guild;
    this.guild.channels[this.id.toString()] = this;
  }
}
