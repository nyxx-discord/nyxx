part of nyxx;

/// A message embed.
/// Can contain null elements.
class Embed implements IEmbed {
  /// The embed's title.
  late final String? title;

  /// The embed's type
  late final String? type;

  /// The embed's description.
  late final String? description;

  /// The embed's URL
  late final String? url;

  /// Timestamp of embed content
  late final DateTime? timestamp;

  /// Color of embed
  late final DiscordColor? color;

  /// Embed's footer
  late final IEmbedFooter? footer;

  /// The embed's thumbnail, if any.
  late final IEmbedThumbnail? thumbnail;

  /// The embed's provider, if any.
  late final IEmbedProvider? provider;

  /// Embed image
  late final IEmbedThumbnail? image;

  /// Embed video
  late final IEmbedVideo? video;

  /// Embed author
  late final IEmbedAuthor? author;

  /// Map of fields of embed. Map(name, field)
  late final List<IEmbedField> fields;

  /// Creates an instance [Embed]
  Embed(RawApiMap raw) {
    if (raw["title"] != null) {
      this.title = raw["title"] as String;
    }

    if (raw["url"] != null) {
      this.url = raw["url"] as String;
    }

    if (raw["type"] != null) {
      this.type = raw["type"] as String;
    }

    if (raw["description"] != null) {
      this.description = raw["description"] as String;
    }

    if (raw["timestamp"] != null) {
      this.timestamp = DateTime.parse(raw["timestamp"] as String);
    }

    if (raw["color"] != null) {
      this.color = DiscordColor.fromInt(raw["color"] as int);
    }

    if (raw["author"] != null) {
      this.author = EmbedAuthor(raw["author"] as RawApiMap);
    }

    if (raw["video"] != null) {
      this.video = EmbedVideo(raw["video"] as RawApiMap);
    }

    if (raw["image"] != null) {
      this.image = EmbedThumbnail(raw["image"] as RawApiMap);
    }

    if (raw["footer"] != null) {
      this.footer = EmbedFooter(raw["footer"] as RawApiMap);
    }

    if (raw["thumbnail"] != null) {
      this.thumbnail = EmbedThumbnail(raw["thumbnail"] as RawApiMap);
    }

    if (raw["provider"] != null) {
      this.provider = EmbedProvider(raw["provider"] as RawApiMap);
    }

    fields = [
      if (raw["fields"] != null)
        for (var obj in raw["fields"]) EmbedField(obj as RawApiMap)
    ];
  }

  @override
  EmbedBuilder toBuilder() =>
    EmbedBuilder()
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
      ..fields = this.fields.map((field) => field.toBuilder()).toList();
}
