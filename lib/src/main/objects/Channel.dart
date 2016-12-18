part of discord;

/// A channel.
class Channel {
  Client _client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The channel's ID.
  String id;

  /// The channel's type.
  String type;

  /// A timestamp for when the channel was created.
  DateTime createdAt;

  Channel._new(this._client, this.raw, this.type) {
    this.id = raw['id'];
    this.createdAt = Util.getDate(this.id);

    _client.channels[this.id] = this;
  }

  /// Deletes the channel.
  Future<Null> delete() async {
    await this._client.http.send('DELETE', "/channels/${this.id}");
    return null;
  }
}
