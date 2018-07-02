part of nyxx;

/// A guild channel.
class GuildChannel extends Channel {
  /// The channel's name.
  String name;

  /// The guild that the channel is in.
  Guild guild;

  /// The channel's position in the channel list.
  int position;

  /// Parent channel id;
  String parentId;

  /// Indicates if channel is NSFW
  bool nsfw;

  GuildChannel._new(
      Client client, Map<String, dynamic> data, this.guild, String type)
      : super._new(client, data, type) {
    this.name = raw['name'];
    this.position = raw['position'];

    //this.id = raw['id'];
    if(raw.containsKey('parent_id'))
      this.parentId = new Snowflake(raw['parent_id']);
    this.nsfw = raw['nsfw'];

    this.guild.channels[this.id.toString()] = this;
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
