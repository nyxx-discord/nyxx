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
  List<Map<String, dynamic>> _fields;

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
      _fields.add(field._build());
      return;
    }

    if (builder != null) {
      var tmp = EmbedFieldBuilder();
      builder(tmp);
      _fields.add(tmp._build());
      return;
    }

    _fields.add(EmbedFieldBuilder(name, content, inline)._build());
  }

  @override

  /// Builds object to Map() instance;
  Map<String, dynamic> _build() {
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
    if (_fields.length > 0) tmp["fields"] = _fields;

    return tmp;
  }
}
