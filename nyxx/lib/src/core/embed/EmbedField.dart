part of nyxx;

/// Single instance of Embed's field. Can contain null elements.
class EmbedField implements IEmbedField{
  /// Field name
  late final String name;

  /// Contents of field (aka value)
  late final String content;

  /// Indicates of field is inlined in embed
  late final bool? inline;

  /// Creates an instance of [EmbedField]
  EmbedField(RawApiMap raw) {
    this.name = raw["name"] as String;
    this.content = raw["value"] as String;
    this.inline = raw["inline"] as bool?;
  }

  @override
  EmbedFieldBuilder toBuilder() => EmbedFieldBuilder(this.name, this.content, this.inline);
}
