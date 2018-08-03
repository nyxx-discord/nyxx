part of nyxx;

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

  /// Builds object to Map() instance;
  Map<String, dynamic> _build() {
    Map<String, dynamic> tmp = new Map();

    if (name != null) tmp["name"] = name;
    if (content != null) tmp["value"] = content;

    if (inline != null)
      tmp["inline"] = inline;
    else
      tmp["inline"] = false;

    return tmp;
  }
}
