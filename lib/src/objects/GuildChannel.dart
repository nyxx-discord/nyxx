import '../../discord.dart';

/// A guild channel.
class GuildChannel extends Channel {
  /// The channel's name.
  String name;

  /// The guild that the channel is in.
  Guild guild;

  /// The channel's position in the channel list.
  int position;

  /// Constructs a new [GuildChannel].
  GuildChannel(
      Client client, Map<String, dynamic> data, this.guild, String type)
      : super(client, data, type) {
    this.name = this.map['name'] = data['name'];
    this.position = this.map['position'] = data['position'];
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
