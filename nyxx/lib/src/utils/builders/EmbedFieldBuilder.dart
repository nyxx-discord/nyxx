part of nyxx;

/// Builder for embed Field.
class EmbedFieldBuilder extends Builder {
  /// Field name/title
  dynamic? name;

  /// Field content
  dynamic? content;

  /// Whether or not this field should display inline
  bool? inline;

  /// Constructs new instance of Field
  EmbedFieldBuilder([this.name, this.content, this.inline]);

  /// Creates a [EmbedFieldBuilder] from raw json
  EmbedFieldBuilder.fromJson(Map<String, dynamic> raw) {
    this.name = raw["name"];
    this.content = raw["value"];
    this.inline = raw["inline"] as bool?;
  }

  /// Length of current field
  int get length => name.toString().length + content.toString().length;

  @override

  /// Builds object to Map() instance;
  Map<String, dynamic> build() {
    if (this.name.toString().length > 256) {
      throw EmbedBuilderArgumentException._new("Field name is too long. (256 characters limit)");
    }

    if (this.content.toString().length > 1024) {
      throw EmbedBuilderArgumentException._new("Field content is too long. (1024 characters limit)");
    }

    return <String, dynamic>{
      "name": name != null ? name.toString() : "\u200B",
      "value": content != null ? content.toString() : "\u200B",
      "inline": inline ?? false,
    };
  }
}
