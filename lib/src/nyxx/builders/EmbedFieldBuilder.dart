part of nyxx;

/// Builder for embed Field.
class EmbedFieldBuilder implements Builder {
  /// Field name/title
  dynamic name;

  /// Field content
  dynamic content;

  /// Whether or not this field should display inline
  bool inline;

  /// Constructs new instance of Field
  EmbedFieldBuilder([this.name, this.content, this.inline]);

  int get length {
    return name.toString().length + content.toString().length;
  }

  @override

  /// Builds object to Map() instance;
  Map<String, dynamic> _build() {
    if(this.name.toString().length > 256)
      throw new Exception("Field name is too long. (256 characters limit)");

    if(this.content.toString().length > 1024)
      throw new Exception("Field content is too long. (1024 characters limit)");

    Map<String, dynamic> tmp = Map();

    if (name != null)
      tmp["name"] = name.toString();
    else
      tmp["name"] = "\u200B";

    if (content != null)
      tmp["value"] = content.toString();
    else
      tmp["value"] = "\u200B";

    if (inline != null)
      tmp["inline"] = inline;
    else
      tmp["inline"] = false;

    return tmp;
  }
}
