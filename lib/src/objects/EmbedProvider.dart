part of discord;

/// A message embed provider.
class EmbedProvider extends _BaseObj {
  /// The embed provider's name.
  String name;

  /// The embed provider's URL.
  String url;

  EmbedProvider._new(Client client, Map<String, dynamic> data) : super(client) {
    this.name = this._map['name'] = data['name'];
    this.url = this._map['url'] = data['url'];
    this._map['key'] = this.url;
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
