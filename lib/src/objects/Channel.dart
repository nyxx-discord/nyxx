import '../../discord.dart';

/// A channel.
class Channel {
  /// The client.
  Client client;

  /// A map of all of the properties.
  Map<String, dynamic> map = <String, dynamic>{};

  /// The channel's ID.
  String id;

  /// The channel's type.
  String type;

  /// A timestamp for when the channel was created.
  DateTime createdAt;

  /// Constructs a new [Channel].
  Channel(this.client, Map<String, dynamic> data, this.type) {
    this.id = this.map['id'] = data['id'];
    this.createdAt =
        this.map['createdAt'] = this.client.internal.util.getDate(this.id);
  }
}
