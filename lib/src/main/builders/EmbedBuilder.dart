part of discord;

/// Builds up embed object.
/// All fields are optional except of [title]
class EmbedBuilder {
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
  int timestamp;

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

  /// Bootstraper for [EmbedBuilder], takes title as required property
  EmbedBuilder(this.title) {
    _fields = new List();
  }

  void addField({String name, String value, bool inline = false}) {
    _fields.add(new EmbedFieldBuilder(name, value, inline).build());
  }

  void addFieldBuilder(EmbedFieldBuilder field) {
    _fields.add(field.build());
  }

  Map<String, dynamic> build() {
    Map<String, dynamic> tmp = new Map();

    if(title != null)
      tmp["title"] = title;

    if(type != null)
      tmp["type"] = type;

    if(description != null)
      tmp["description"] = description;

    if(url != null)
      tmp["url"] = url;

    if(color != null)
      tmp["color"] = color;

    if(footer != null)
      tmp["footer"] = footer.build();

    if(imageUrl != null)
      tmp["image"] = <String, dynamic> { "url": imageUrl };

    if(thumbnailUrl != null)
      tmp["thumbnail"] = <String, dynamic> { "url": thumbnailUrl };

    if(videoUrl != null)
      tmp["video"] = <String, dynamic> { "url": videoUrl };

    if(provider != null)
      tmp["provider"] = provider.build();

    if(author != null)
      tmp["author"] = author.build();

    if(_fields.length > 0)
      tmp["fields"] = _fields;

    return tmp;
  }
}

/// Builder for embed Field.
class EmbedFieldBuilder {
  /// Field name/title
  String name;

  /// Field content
  String content;

  /// Whether or not this field should display inline
  bool inline;

  /// Constructs new instance of Field
  EmbedFieldBuilder(this.name, this.content, this.inline);

  Map<String, dynamic> build() {
    Map<String, dynamic> tmp = new Map();

    if(name != null)
      tmp["name"] = name;

    if(content != null)
      tmp["value"] = content;

    if(inline != null)
      tmp["inline"] = inline;
    else
      tmp["inline"] = false;

    return tmp;
  }
}

/// Build new instance of Embed's footer
class EmbedFooterBuilder {
  /// Fotter text
  String text;

  /// Url of footer icon. Supports only http(s) for now
  String iconUrl;

  Map<String, dynamic> build() {
    Map<String, dynamic> tmp = new Map();

    if (text != null)
      tmp["text"] = text;

    if (iconUrl != null)
      tmp["icon_url"] = iconUrl;

    return tmp;
  }
}

/// Builds new instance of provider
class EmbedProviderBuilder {
  /// Name of provider
  String name;

  /// Url of provider
  String url;

  Map<String, dynamic> build() {
    Map<String, dynamic> tmp = new Map();

    if (name != null)
      tmp["name"] = name;

    if (url != null)
      tmp["url"] = url;

    return tmp;
  }
}

/// Build new instance of Author
class EmbedAuthorBuilder {
  /// Author name
  String name;

  /// Author url
  String url;

  /// Author icon url
  String iconUrl;

  Map<String, dynamic> build() {
    Map<String, dynamic> tmp = new Map();

    if (name != null)
      tmp["name"] = name;

    if (url != null)
      tmp["url"] = url;

    if (iconUrl != null)
      tmp["icon_url"] = iconUrl;

    return tmp;
  }
}
