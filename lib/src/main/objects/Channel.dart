part of discord;

/// A channel.
class Channel {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The channel's ID.
  String id;

  /// The channel's type.
  String type;

  /// A timestamp for when the channel was created.
  DateTime createdAt;

  Channel._new(this.client, this.raw, this.type) {
    this.id = raw['id'];
    this.createdAt = Util.getDate(this.id);

    client.channels[this.id] = this;
  }

  /// Deletes the channel.
  Future<Null> delete() async {
    await this.client.http.send('DELETE', "/channels/${this.id}");
    return null;
  }
}
