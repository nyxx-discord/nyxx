part of nyxx;

/// A channel.
class Channel {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The channel's ID.
  Snowflake id;

  /// The channel's type.
  String type;

  /// A timestamp for when the channel was created.
  DateTime createdAt;

  Channel._new(this.client, this.raw, this.type) {
    this.id = new Snowflake(raw['id']);
    this.createdAt = id.timestamp;

    client.channels[this.id.toString()] = this;
  }

  /// Deletes the channel.
  Future<Null> delete() async {
    await this.client.http.send('DELETE', "/channels/${this.id}");
    return null;
  }
}
