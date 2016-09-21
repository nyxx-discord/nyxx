import '../../objects.dart';
import '../client.dart';

/// A guild channel.
class GuildChannel {
  /// The channel's name.
  String name;

  /// The channel's ID.
  String id;

  /// The channel's topic, only available if the channel is a text channel.
  String topic;

  /// The ID for the last message in the channel.
  String lastMessageID;

  /// The guild that the channel is in.
  Guild guild;

  /// The channel's type, 0 for text, 2 for voice.
  int type;

  /// The channel's position in the channel list.
  int position;

  /// The channel's bitrate, only available if the channel is a voice channel.
  int bitrate;

  /// The channel's user limit, only available if the channel is a voice channel.
  int userLimit;

  /// A timestamp for when the channel was created.
  double createdAt;

  /// Always false representing that it is a GuildChannel.
  bool isPrivate = false;

  GuildChannel(Client client, Map data, Guild guild) {
    this.name = data['name'];
    this.id = data['id'];
    this.type = data['type'];
    this.position = data['position'];
    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;
    this.topic = data['topic'];
    this.lastMessageID = data['last_message_id'];
    this.bitrate = data['bitrate'];
    this.userLimit = data['user_limit'];
    this.guild = guild;
  }
}
