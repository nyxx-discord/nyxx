part of nyxx;

/// A message embed.
/// Can contain null elements.
class Embed implements Convertable<EmbedBuilder> {
  /// The embed's title.
  String? title;

  /// The embed's type
  String? type;

  /// The embed's description.
  String? description;

  /// The embed's URL
  String? url;

  /// Timestamp of embed content
  DateTime? timestamp;

  /// Color of embed
  DiscordColor? color;

  /// Embed's footer
  EmbedFooter? footer;

  /// The embed's thumbnail, if any.
  EmbedThumbnail? thumbnail;

  /// The embed's provider, if any.
  EmbedProvider? provider;

  /// Embed image
  EmbedThumbnail? image;

  /// Embed video
  EmbedVideo? video;

  /// Embed author
  EmbedAuthor? author;

  /// Map of fields of embed. Map(name, field)
  late final List<EmbedField> fields;

  Embed._new(Map<String, dynamic> raw) {
    if (raw['title'] != null) {
      this.title = raw['title'] as String;
    }

    if (raw['url'] != null) {
      this.url = raw['url'] as String;
    }

    if (raw['type'] != null) {
      this.type = raw['type'] as String;
    }

    if (raw['description'] != null) {
      this.description = raw['description'] as String;
    }

    if (raw['timestamp'] != null) {
      this.timestamp = DateTime.parse(raw['timestamp'] as String);
    }

    if (raw['color'] != null) {
      this.color = DiscordColor.fromInt(raw['color'] as int);
    }

    if (raw['author'] != null) {
      this.author = EmbedAuthor._new(raw['author'] as Map<String, dynamic>);
    }

    if (raw['video'] != null) {
      this.video = EmbedVideo._new(raw['video'] as Map<String, dynamic>);
    }

    if (raw['image'] != null) {
      this.image = EmbedThumbnail._new(raw['image'] as Map<String, dynamic>);
    }

    if (raw['footer'] != null) {
      this.footer = EmbedFooter._new(raw['footer'] as Map<String, dynamic>);
    }

    if (raw['thumbnail'] != null) {
      this.thumbnail = EmbedThumbnail._new(raw['thumbnail'] as Map<String, dynamic>);
    }

    if (raw['provider'] != null) {
      this.provider = EmbedProvider._new(raw['provider'] as Map<String, dynamic>);
    }

    fields = [
      if (raw['fields'] != null)
        for (var obj in raw['fields']) EmbedField._new(obj as Map<String, dynamic>)
    ];
  }

  /// Returns a string representation of this object.
  @override
  String toString() => this.title ?? "";

  @override
  int get hashCode =>
      title.hashCode * 37 +
      type.hashCode * 37 +
      description.hashCode * 37 +
      timestamp.hashCode * 37 +
      color.hashCode * 37 +
      footer.hashCode * 37 +
      thumbnail.hashCode * 37 +
      provider.hashCode * 37 +
      image.hashCode * 37 +
      video.hashCode * 37 +
      author.hashCode * 37 +
      fields.map((f) => f.hashCode * 37).reduce((f, s) => f + s);

  @override
  EmbedBuilder toBuilder() {
    return EmbedBuilder()
      ..title = this.title
      ..type = this.type
      ..description = this.description
      ..url = this.url
      ..timestamp = this.timestamp
      ..color = this.color
      ..footer = this.footer?.toBuilder()
      ..thumbnailUrl = this.thumbnail?.url
      ..imageUrl = this.image?.url
      ..author = this.author?.toBuilder()
      .._fields = this.fields.map((field) => field.toBuilder()).toList();
  }

  @override
  bool operator ==(other) => other is EmbedVideo ? other.url == this.url : false;
}
