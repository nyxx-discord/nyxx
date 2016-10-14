part of discord;

/// A channel.
class Channel extends _BaseObj {
  /// The channel's ID.
  String id;

  /// The channel's type.
  String type;

  /// A timestamp for when the channel was created.
  DateTime createdAt;

  Channel._new(Client client, Map<String, dynamic> data, this.type)
      : super(client) {
    this.id = data['id'];
    this.createdAt = this._client._util.getDate(this.id);

    client.channels[this.id] = this;
  }

  /// Deletes the channel.
  Future<Null> delete() async {
    await this._client._http.delete("/channels/${this.id}");
    return null;
  }
}
