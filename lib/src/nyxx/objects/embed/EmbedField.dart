part of nyxx;

/// Single instance of Embed's field. Can contain null elements.
class EmbedField implements Convertable<EmbedFieldBuilder> {
  /// Field name
  String name;

  /// Contents of field (aka value)
  String content;

  /// Indicates of field is inlined in embed
  bool inline;

  EmbedField._new(Map<String, dynamic> raw) {
    this.name = raw['name'] as String;
    this.content = raw['value'] as String;
    this.inline = raw['inline'] as bool;
  }

  @override
  String toString() => "[$name] $content";

  @override
  int get hashCode =>
      name.hashCode * 37 + content.hashCode * 37 + inline.hashCode * 37;

  @override
  bool operator ==(other) => other is EmbedField
      ? other.name == this.name &&
          other.content == this.content &&
          other.inline == this.inline
      : false;

  @override
  EmbedFieldBuilder toBuilder() => EmbedFieldBuilder(this.name, this.content, this.inline);
}
