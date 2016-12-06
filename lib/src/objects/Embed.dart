part of discord;

/// A message embed.
class Embed {
  Client _client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

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

  Embed._new(this._client, this.raw) {
    this.url = raw['url'];
    this.type = raw['type'];
    this.description = raw['description'];

    if (raw.containsKey('thumbnail')) {
      this.thumbnail = new EmbedThumbnail._new(
          this._client, raw['thumbnail'] as Map<String, dynamic>);
    }
    if (raw.containsKey('provider')) {
      this.provider = new EmbedProvider._new(
          this._client, raw['provider'] as Map<String, dynamic>);
    }
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.title;
  }
}
