import '../../discord.dart';

/// A user.
class Webhook {
  /// The client.
  Client client;

  /// A map of all of the properties.
  Map<String, dynamic> map = <String, dynamic>{};

  /// The webhook's name.
  String name;

  /// The webhook's id.
  String id;

  /// The webhook's token.
  String token;

  /// The webhook's channel id.
  String channelId;

  /// The webhook's channel, if the client has that channel in it's cache.
  TextChannel channel;

  /// The webhook's guild id.
  String guildId;

  /// The webhook's guild, if the client has that guild in it's cache.
  Guild guild;

  /// When the webhook was created;
  DateTime createdAt;

  /// Constructs a new [User].
  Webhook(this.client, Map<String, dynamic> data) {
    this.name = this.map['name'] = data['name'];
    this.id = this.map['id'] = data['id'];
    this.token = this.map['token'] = data['token'];
    this.channelId = this.map['channelId'] = data['channel_id'];
    this.guildId = this.map['guildId'] = data['guild_id'];    
    this.createdAt =
        this.map['createdAt'] = this.client.internal.util.getDate(this.id);

    this.channel = this.client.channels[this.channelId];
    this.guild = this.client.guilds[this.guildId];
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
