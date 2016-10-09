part of discord;

/// A message embed.
class Embed extends _BaseObj {
  /// The embed's URL
  String url;

  /// The embed's type
  String type;

  /// The embed's description.
  String description;

  /// The embed's title.
  String title;

  /// The embed's thumbnail, if any.
  EmbedThumbnail thumbnail;

  /// The embed's provider, if any.
  EmbedProvider provider;

  Embed._new(Client client, Map<String, dynamic> data) : super(client) {
    this.url = this._map['url'] = data['url'];
    this.type = this._map['type'] = data['type'];
    this.description = this._map['description'] = data['description'];

    if (data.containsKey('thumbnail')) {
      this.thumbnail = this._map['thumbnail'] = new EmbedThumbnail._new(
          this._client, data['thumbnail'] as Map<String, dynamic>);
    }
    if (data.containsKey('provider')) {
      this.provider = this._map['provider'] = new EmbedProvider._new(
          this._client, data['provider'] as Map<String, dynamic>);
    }
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.title;
  }
}
