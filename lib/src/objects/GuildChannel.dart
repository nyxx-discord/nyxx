part of discord;

/// A guild channel.
class GuildChannel extends Channel {
  /// The channel's name.
  String name;

  /// The guild that the channel is in.
  Guild guild;

  /// The channel's position in the channel list.
  int position;

  GuildChannel._new(
      Client client, Map<String, dynamic> data, this.guild, String type)
      : super._new(client, data, type) {
    this.name = this._map['name'] = data['name'];
    this.position = this._map['position'] = data['position'];

    this.guild.channels.add(this);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
