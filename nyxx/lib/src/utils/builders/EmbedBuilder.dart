part of nyxx;

/// Builds up embed object.
class EmbedBuilder extends Builder {
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
    this.fields = [];
  }

  /// Creates an instance of [EmbedBuilder] from json.
  EmbedBuilder.fromJson(Map<String, dynamic> raw) {
    this.title = raw["title"] as String?;
    this.description = raw["description"] as String?;
    this.url = raw["url"] as String?;
    this.color = raw["color"] != null ? DiscordColor.fromInt(raw["color"] as int) : null;
    this.timestamp = raw["timestamp"] != null ? DateTime.parse(raw["timestamp"] as String) : null;
    this.footer = raw["footer"] != null
        ? EmbedFooterBuilder.fromJson(raw["footer"] as Map<String, String?>)
        : null;
    this.imageUrl = raw["image"]["url"] as String?;
    this.thumbnailUrl = raw["thumbnail"]["url"] as String?;
    this.author = raw["author"] != null
      ? EmbedAuthorBuilder.fromJson(raw["author"] as Map<String, String?>)
      : null;

    this.fields = [];
    for(final rawFields in raw["fields"] as List<dynamic>) {
      this.fields.add(EmbedFieldBuilder.fromJson(rawFields as Map<String, dynamic>));
    }
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
    this.fields.add(_constructEmbedFieldBuilder(
      name: name,
      content: content,
      builder: builder,
      field: field,
      inline: inline
    ));
  }

  /// Replaces field where [name] witch provided new field.
  void replaceField({dynamic? name,
      dynamic? content,
      bool inline = false,
      Function(EmbedFieldBuilder field)? builder,
      EmbedFieldBuilder? field}) {

    final index = this.fields.indexWhere((element) => element.name == name);
    this.fields[index] = _constructEmbedFieldBuilder(
        name: name,
        content: content,
        builder: builder,
        field: field,
        inline: inline
    );
  }

  EmbedFieldBuilder _constructEmbedFieldBuilder(
      {dynamic? name,
        dynamic? content,
        bool inline = false,
        Function(EmbedFieldBuilder field)? builder,
        EmbedFieldBuilder? field}) {
    if (field != null) {
      return field;
    }

    if (builder != null) {
      final tmp = EmbedFieldBuilder();
      builder(tmp);
      return tmp;
    }

    return EmbedFieldBuilder(name, content, inline);
  }

  /// Total length of all text fields of embed
  int get length =>
    (this.title?.length ?? 0) +
        (this.description?.length ?? 0) +
        (this.footer?.length ?? 0) +
        (this.author?.length ?? 0) +
        (fields.isEmpty ? 0 : fields.map((embed) => embed.length).reduce((f, s) => f + s));

  @override

  /// Builds object to Map() instance;
  Map<String, dynamic> build() {
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
      if (footer != null) "footer": footer!.build(),
      if (imageUrl != null) "image": <String, dynamic>{"url": imageUrl},
      if (thumbnailUrl != null) "thumbnail": <String, dynamic>{"url": thumbnailUrl},
      if (author != null) "author": author!.build(),
      if (fields.isNotEmpty) "fields": fields.map((builder) => builder.build()).toList()
    };
  }
}
