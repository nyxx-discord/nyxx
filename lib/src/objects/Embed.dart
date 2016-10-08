part of discord;

/// A message embed.
class Embed {
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

  /// Constructs a new [Embed].
  Embed(Map<String, dynamic> data) {
    this.url = data['url'];
    this.type = data['type'];
    this.description = data['description'];

    if (data.containsKey('thumbnail')) {
      this.thumbnail =
          new EmbedThumbnail(data['thumbnail'] as Map<String, dynamic>);
    }
    if (data.containsKey('provider')) {
      this.provider =
          new EmbedProvider(data['provider'] as Map<String, dynamic>);
    }
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.title;
  }
}
