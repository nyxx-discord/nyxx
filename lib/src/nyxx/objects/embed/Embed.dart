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
    if (raw['title'] != null) this.title = raw['title'] as String;
    if (raw['url'] != null) this.url = raw['url'] as String;
    if (raw['type'] != null) this.type = raw['type'] as String;
    if (raw['description'] != null)
      this.description = raw['description'] as String;
    if (raw['timestamp'] != null)
      this.timestamp = DateTime.parse(raw['timestamp'] as String);
    if (raw['color'] != null) this.color = raw['color'] as int;
    if (raw['author'] != null)
      this.author = EmbedAuthor._new(raw['author'] as Map<String, dynamic>);
    if (raw['video'] != null)
      this.video = EmbedVideo._new(raw['video'] as Map<String, dynamic>);
    if (raw['image'] != null)
      this.image = EmbedThumbnail._new(raw['image'] as Map<String, dynamic>);
    if (raw['footer'] != null)
      this.footer = EmbedFooter._new(raw['footer'] as Map<String, dynamic>);
    if (raw['thumbnail'] != null)
      this.thumbnail =
          EmbedThumbnail._new(raw['thumbnail'] as Map<String, dynamic>);
    if (raw['provider'] != null)
      this.provider =
          EmbedProvider._new(raw['provider'] as Map<String, dynamic>);
    if (raw['fields'] != null) {
      fields = Map();
      raw['fields'].forEach((dynamic o) {
        EmbedField._new(o as Map<String, dynamic>, this);
      });
    }
  }

  /// Returns a string representation of this object.
  @override
  String toString() => this.title;
}
