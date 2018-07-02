part of nyxx;

/// A message embed.
/// Can contain null elements.
class Embed {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The embed's title.
  String title;

  /// The embed's type
  String type;

  /// The embed's description.
  String description;

  /// The embed's URL
  String url;

  /// Timestamp of embed content
  DateTime timestamp;

  /// Color of embed
  int color;

  /// Embed's footer
  EmbedFooter footer;

  /// The embed's thumbnail, if any.
  EmbedThumbnail thumbnail;

  /// The embed's provider, if any.
  EmbedProvider provider;

  /// Embed image
  EmbedThumbnail image;

  /// Embed video
  EmbedVideo video;

  /// Embed author
  EmbedAuthor author;

  /// Map of fields of embed. Map(name, field)
  Map<String, EmbedField> fields;

  Embed._new(this.client, this.raw) {
    if (raw['title'] != null) this.title = raw['title'];

    if (raw['url'] != null) this.url = raw['url'];

    if (raw['type'] != null) this.type = raw['type'];

    if (raw['description'] != null) this.description = raw['description'];

    if (raw['timestamp'] != null)
      this.timestamp = DateTime.parse(raw['timestamp']);

    this.color = raw['color'];

    if (raw.containsKey('author'))
      this.author = new EmbedAuthor._new(raw['author'] as Map<String, dynamic>);

    if (raw.containsKey('video'))
      this.video = new EmbedVideo._new(raw['video'] as Map<String, dynamic>);

    if (raw.containsKey('image'))
      this.image =
          new EmbedThumbnail._new(raw['image'] as Map<String, dynamic>);

    if (raw.containsKey('footer'))
      this.footer = new EmbedFooter._new(raw['footer'] as Map<String, dynamic>);

    if (raw.containsKey('thumbnail'))
      this.thumbnail =
          new EmbedThumbnail._new(raw['thumbnail'] as Map<String, dynamic>);

    if (raw.containsKey('provider'))
      this.provider =
          new EmbedProvider._new(raw['provider'] as Map<String, dynamic>);

    if (raw['fields'] != null) {
      fields = new Map();
      raw['fields'].forEach((Map<String, dynamic> o) {
        new EmbedField._new(o, this);
      });
    }
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.title;
  }
}
