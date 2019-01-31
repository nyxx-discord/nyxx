part of nyxx;

/// Builds up embed object.
class EmbedBuilder implements Builder {
  /// Embed title
  String title;

  /// Embed type
  String type;

  /// Embed description.
  String description;

  /// Url of Embed
  String url;

  /// Color code of the embed
  DiscordColor color;

  /// Timestamp of embed content
  DateTime timestamp;

  /// Embed Footer
  EmbedFooterBuilder footer;

  /// Image Url
  String imageUrl;

  /// Thumbnail Url
  String thumbnailUrl;

  /// Author of embed
  EmbedAuthorBuilder author;

  /// Embed custom fields;
  List<EmbedFieldBuilder> _fields;

  EmbedBuilder() {
    _fields = List();
  }

  /// Adds author to embed.
  void addAuthor(void builder(EmbedAuthorBuilder author)) {
    this.author = EmbedAuthorBuilder();
    builder(this.author);
  }

  /// Adds footer to embed
  void addFooter(void builder(EmbedFooterBuilder footer)) {
    this.footer = EmbedFooterBuilder();
    builder(this.footer);
  }

  /// Adds field to embed. [name] and [content] fields are required. Inline is set to false by default.
  void addField(
      {dynamic name,
      dynamic content,
      bool inline = false,
      Function(EmbedFieldBuilder field) builder,
      EmbedFieldBuilder field}) {
    if (field != null) {
      _fields.add(field);
      return;
    }

    if (builder != null) {
      var tmp = EmbedFieldBuilder();
      builder(tmp);
      _fields.add(tmp);
      return;
    }

    _fields.add(EmbedFieldBuilder(name, content, inline));
  }

  int get length {
    return (this.title?.length ?? 0) + (this.description?.length ?? 0) + (this.footer?.length ?? 0) + (this.author?.length ?? 0) + _fields.map((embed) => embed.length).reduce((f, s) => f + s);
  }

  @override

  /// Builds object to Map() instance;
  Map<String, dynamic> _build() {
    if(this.title != null && this.title.length > 256)
      throw new Exception("Embed title is too long (256 characters limit)");

    if(this.description != null && this.description.length > 2048)
      throw new Exception("Embed description is too long (2048 characters limit)");

    if(this._fields.length > 25)
      throw new Exception("Embed cannot contain more than 25 fields");

    if(this.length > 6000)
      throw new Exception("Total length of embed cannot exceed 6000 characters");

    Map<String, dynamic> tmp = Map();

    if (title != null) tmp["title"] = title;
    if (type != null) tmp["type"] = type;
    if (description != null) tmp["description"] = description;
    if (url != null) tmp["url"] = url;
    if (timestamp != null) tmp["timestamp"] = timestamp.toIso8601String();
    if (color != null) tmp["color"] = color._value;
    if (footer != null) tmp["footer"] = footer._build();
    if (imageUrl != null) tmp["image"] = <String, dynamic>{"url": imageUrl};
    if (thumbnailUrl != null)
      tmp["thumbnail"] = <String, dynamic>{"url": thumbnailUrl};
    if (author != null) tmp["author"] = author._build();
    if (_fields.length > 0) tmp["fields"] = _fields.map((builder) => builder._build()).toList();

    return tmp;
  }
}
