part of nyxx;

/// Builds up embed object.
/// All fields are optional except of [title]
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
  int color;

  /// Timestamp of embed content
  DateTime timestamp;

  /// Embed Footer
  EmbedFooterBuilder footer;

  /// Image Url
  String imageUrl;

  /// Thumbnail Url
  String thumbnailUrl;

  /// Video url
  String videoUrl;

  /// Author aka provider
  EmbedProviderBuilder provider;

  /// Author of embed
  EmbedAuthorBuilder author;

  /// Embed custom fields;
  List<Map<String, dynamic>> _fields;

  EmbedBuilder() {
    _fields = List();
  }

  void addAuthor(Function(EmbedAuthorBuilder author) func) {
    this.author = EmbedAuthorBuilder();
    func(this.author);
  }

  void addFooter(Function(EmbedFooterBuilder footer) func) {
    this.footer = EmbedFooterBuilder();
    func(this.footer);
  }

  /// Adds field to embed. [name] and [content] fields are required. Inline is set to false by default.
  void addField({String name, String content, bool inline = false}) {
    _fields.add(EmbedFieldBuilder(name, content, inline)._build());
  }

  /// Added field to embed using [EmbedFieldBuilder]
  void addFieldBuilder(EmbedFieldBuilder field) => _fields.add(field._build());

  @override

  /// Builds object to Map() instance;
  Map<String, dynamic> _build() {
    Map<String, dynamic> tmp = Map();

    if (title != null) tmp["title"] = title;
    if (type != null) tmp["type"] = type;
    if (description != null) tmp["description"] = description;
    if (url != null) tmp["url"] = url;
    if (timestamp != null) tmp["timestamp"] = timestamp.toIso8601String();
    if (color != null) tmp["color"] = color;
    if (footer != null) tmp["footer"] = footer._build();
    if (imageUrl != null) tmp["image"] = <String, dynamic>{"url": imageUrl};
    if (thumbnailUrl != null)
      tmp["thumbnail"] = <String, dynamic>{"url": thumbnailUrl};
    if (videoUrl != null) tmp["video"] = <String, dynamic>{"url": videoUrl};
    if (provider != null) tmp["provider"] = provider._build();
    if (author != null) tmp["author"] = author._build();
    if (_fields.length > 0) tmp["fields"] = _fields;

    return tmp;
  }
}
