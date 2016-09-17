import '../objects.dart';

/// A channel.
class Channel {
  /// The channel's name.
  String name;

  /// The channel's ID.
  String id;

  /// The channel's topic, only available if the channel is a text channel.
  String topic;

  /// The channel's type, either `text` or `voice`.
  String type;

  /// The ID for the last message in the channel.
  String lastMessageID;

  /// The ID for the guild that the channel is in, only available if the channel
  /// is not private.
  String guildID;

  /// The channel's position in the channel list.
  int position;

  /// The channel's bitrate, only available if the channel is a voice channel.
  int bitrate;

  /// The channel's user limit, only available if the channel is a voice channel.
  int userLimit;

  /// A timestamp for when the channel was created.
  double createdAt;

  /// Whether or not the channel is a DM.
  bool isPrivate;

  Channel(Map data) {
    this.name = data['name'];
    this.id = data['id'];
    this.type = data['type'];
    this.guildID = data['guild_id'];
    this.position = data['position'];
    this.isPrivate = data['is_private'];
    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;

    if (this.type == "text") {
      this.topic = data['topic'];
      this.lastMessageID = data['last_message_id'];
    } else {
      this.bitrate = data['bitrate'];
      this.userLimit = data['user_limit'];
    }
  }
}
