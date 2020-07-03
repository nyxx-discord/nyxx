part of nyxx;

/// Builds up embed object.
class EmbedBuilder implements Builder {
  /// Embed title
  String? title;

  /// Embed type
  String? type;

  /// Embed description.
  String? description;

  /// Url of Embed
  String? url;

  /// Color code of the embed
  DiscordColor? color;

  /// Timestamp of embed content
  DateTime? timestamp;

  /// Embed Footer
  EmbedFooterBuilder? footer;

  /// Image Url
  String? imageUrl;

  /// Thumbnail Url
  String? thumbnailUrl;

  /// Author of embed
  EmbedAuthorBuilder? author;

  /// Embed custom fields;
  late final List<EmbedFieldBuilder> fields;

  /// Creates clean instance [EmbedBuilder]
  EmbedBuilder() {
    fields = [];
  }

  /// Adds author to embed.
  void addAuthor(void Function(EmbedAuthorBuilder author) builder) {
    this.author = EmbedAuthorBuilder();
    builder(this.author!);
  }

  /// Adds footer to embed
  void addFooter(void Function(EmbedFooterBuilder footer) builder) {
    this.footer = EmbedFooterBuilder();
    builder(this.footer!);
  }

  /// Adds field to embed. [name] and [content] fields are required. Inline is set to false by default.
  void addField(
      {dynamic? name,
      dynamic? content,
      bool inline = false,
      Function(EmbedFieldBuilder field)? builder,
      EmbedFieldBuilder? field}) {
    if (field != null) {
      fields.add(field);
      return;
    }

    if (builder != null) {
      final tmp = EmbedFieldBuilder();
      builder(tmp);
      fields.add(tmp);
      return;
    }

    fields.add(EmbedFieldBuilder(name, content, inline));
  }

  /// Replaces field where [name] witch provided new field.
  void replaceField({dynamic? name,
      dynamic? content,
      bool inline = false,
      Function(EmbedFieldBuilder field)? builder,
      EmbedFieldBuilder? field}) {

    this.fields.removeWhere((element) => element.name == name);
    this.addField(name: name, content: content, inline: inline, builder: builder, field: field);
  }

  /// Total lenght of all text fields of embed
  int get length =>
    (this.title?.length ?? 0) +
        (this.description?.length ?? 0) +
        (this.footer?.length ?? 0) +
        (this.author?.length ?? 0) +
        (fields.isEmpty ? 0 : fields.map((embed) => embed.length).reduce((f, s) => f + s));

  @override

  /// Builds object to Map() instance;
  Map<String, dynamic> _build() {
    if (this.title != null && this.title!.length > 256) {
      throw EmbedBuilderArgumentException._new("Embed title is too long (256 characters limit)");
    }

    if (this.description != null && this.description!.length > 2048) {
      throw EmbedBuilderArgumentException._new("Embed description is too long (2048 characters limit)");
    }

    if (this.fields.length > 25) {
      throw EmbedBuilderArgumentException._new("Embed cannot contain more than 25 fields");
    }

    if (this.length > 6000) {
      throw EmbedBuilderArgumentException._new("Total length of embed cannot exceed 6000 characters");
    }

    return <String, dynamic>{
      if (title != null) "title": title,
      if (type != null) "type": type,
      if (description != null) "description": description,
      if (url != null) "url": url,
      if (timestamp != null) "timestamp": timestamp!.toIso8601String(),
      if (color != null) "color": color!._value,
      if (footer != null) "footer": footer!._build(),
      if (imageUrl != null) "image": <String, dynamic>{"url": imageUrl},
      if (thumbnailUrl != null) "thumbnail": <String, dynamic>{"url": thumbnailUrl},
      if (author != null) "author": author!._build(),
      if (fields.isNotEmpty) "fields": fields.map((builder) => builder._build()).toList()
    };
  }
}
